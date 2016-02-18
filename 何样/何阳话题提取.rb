  #@一只学霸(3461350924)、@学生那点小事(1660815495)、@中国传媒大学学生会(2050042435)、@学生来吐槽(2517830513)、@复旦大学(1729332983)这些帐号的近一个月的有互动的粉丝
  #找出这些粉丝的每个粉丝的前100条微博(微博内容里边儿带有##的话题的统计)

  #先获取这段时间内这个用户发布的所有微博及微博ID

  filename = '来福小院流浪动物救助.csv'
  CSV.open filename,"wb" do |csv|
   start_time = '2014-07-15'
   end_time = '2014-10-15'
   task = GetUserTagsTask.new
      csv << %w{UID name 微博内容 发布时间 转发数 评论数 互动总数 URL 原创 发布来源}
      uids = [2517830513]
      uids.each{|uid|
        puts "Processing uid : #{uid}"
        top_id = nil
        task.paginate(:per_page=>100) do |page|

          begin
            res = task.stable{task.api.statuses.user_timeline(uid:uid,count:100, page:page)}
            processing = true
            if page == 1
              if Time.parse(res['statuses'][0].created_at)< Time.parse(res['statuses'][1].created_at)
              top_id = res['statuses'][0].id
              end
             end
            res['statuses'].each{|w|
#debugger
              if w.id == top_id
                srouce = ActionView::Base.full_sanitizer.sanitize(w.source) #去出所有的标签
                url = "http://weibo.com/#{uid}/#{WeiboMidUtil.mid_to_str(w.id.to_s)}"
                post_at = Time.parse(w.created_at).strftime("%Y-%m-%d %H:%M")
                scount = w.reposts_count + w.comments_count
                origin = !w.retweeted_status
                csv << [w.user.uid,w.user.screen_name, w.text,post_at, w.reposts_count, w.comments_count,scount, url,origin, srouce]
                next
              end
              puts w.created_at
              next if end_time && Time.parse(w.created_at) > end_time
              if Time.parse(w.created_at) > start_time
                srouce = ActionView::Base.full_sanitizer.sanitize(w.source) #去出所有的标签
                url = "http://weibo.com/#{uid}/#{WeiboMidUtil.mid_to_str(w.id.to_s)}"
                post_at = Time.parse(w.created_at).strftime("%Y-%m-%d %H:%M")
                scount = w.reposts_count + w.comments_count
                origin = !w.retweeted_status
                text = w.text
                text += "\n----------------------------\n"+w.retweeted_status['text'] if !origin

                csv << [w.user.uid,w.user.screen_name, text, post_at, w.reposts_count, w.comments_count,scount, url,origin, srouce]
              else
                processing = false
                break
              end
            }
            processing  &&  page<=20 ? res.total_number : 0
          rescue Exception=>e
            0
          end
        end
      }
  end

  z_uid = 1490832227
  start_time = '2014-01-01'
  end_time = '2014-10-15'
  filename = '好狗好猫流浪狗义工团.csv'
  task = GetUserTagsTask.new
  CSV.open filename,"wb" do |csv|
    csv << %w{uid 内容 无效内容 互动时间 互动微博连接 动作}
    urls = open '/home/rails/Desktop/yzxb-url'#文件的路径
    urls = urls.read
    urls = urls.strip.split("\n")
    urls.each do |url|
      url = url.strip
      weibo_id = WeiboMidUtil.str_to_mid URI.parse(url).path.split("/").last# http://weibo.com/1795839430/AhbvtnvrV http://weibo.com/1795839430/AhmhfkBY5
      puts url
      page = 1
      processing = true
        begin
          begin
            res = task.stable{task.api.statuses.repost_timeline(weibo_id.to_s,count:200,page:page)}#根据weibo_id查转发人信息count

              if !res.blank?
                 res.reposts.each do |line|
                  if line.nil?
                     processing = false
                     break
                  end
                 url = "http://weibo.com/#{line.retweeted_status.user.id}/#{WeiboMidUtil.mid_to_str(line.retweeted_status.id.to_s)}"
                 fake_content = line.text == "转发微博" || line.text.gsub(/\[[^\]]+\]/,"").blank?
                 time = DateTime.parse(line.created_at).strftime("%Y-%m-%d %H:%S")
                 if time > start_time && time < end_time
                  csv << [line.user.id,line.text,fake_content, DateTime.parse(line.created_at).strftime("%Y-%m-%d %H:%S"),url,'转发']
                 end
                 end
               else
                processing = false
                break
               end
          rescue SystemExit, Interrupt,IRB::Abort
            raise

          rescue SystemExit, Interrupt,IRB::Abort
            raise

          rescue Exception=>e
            puts e.message
          end
          page+=1
        end while processing == true
       processing == true
       page = 1
        begin
          begin
            res = task.stable{task.api.comments.show(weibo_id,count:200,page:page)}#根据weibo_id查评论人信息
              if !res.comments.blank?
                 res.comments.each do |line|

                  if line.nil?
                     processing = false
                     break
                  end
                   url = "http://weibo.com/#{line.status.user.id}/#{WeiboMidUtil.mid_to_str(line.status.id.to_s)}"
                 fake_content = line.text == "转发微博" || line.text.gsub(/\[[^\]]+\]/,"").blank?
                  time = DateTime.parse(line.created_at).strftime("%Y-%m-%d %H:%S")
                  if time > start_time && time < end_time
                   csv << [line.user.id,line.text,fake_content, DateTime.parse(line.created_at).strftime("%Y-%m-%d %H:%S"),url,'评论']
                  end
                 end
               else
                processing = false
                break
               end
          rescue SystemExit, Interrupt,IRB::Abort
            raise

           rescue Exception=>e
            puts e.message
           end
           page+=1
        end while processing == true

    end
  end

  #跑出粉丝的

  filename = '一只学霸粉丝.csv'
  CSV.open filename,"wb" do |csv|
     task = GetUserTagsTask.new
       csv << ['主号uid']+ WeiboAccount.to_row_title(:full)
       uids = [3461350924]
       uids.each do|id|
          target_id = id
          begin
          friend_ids = task.stable{task.api.friendships.followers_ids(:uid=>target_id, :count=>5000).ids}
          rescue Exception=>e
            puts 'error:类'
            if e.message =~ / for this time/
              sleep(300)
            end
            csv << [target_id]
            next
          end
          friend_ids.each do|uid|
            begin
              account = task.load_weibo_user(uid)
            rescue Exception=>e
              if e.message =~ / for this time/
                sleep(300)
              end
              csv << [target_id,uid]
              next
            end
            next if account.blank?
            csv << [target_id]+ account.to_row(:full)
          end
       end
  end

  #将那个时间段内有互动的uid去重

  filename = 'yzxb-hudong.csv'
  CSV.open filename,"wb" do |csv|
    csv << %w{UID}
    uids = open '/home/rails/Desktop/yzxb-hd-uids'#文件的路径
    uids = uids.read
    uids = uids.strip.split("\n")
    uids = uids.uniq
    uids.each do |uid|
      csv << [uid]
    end
  end

  #与粉丝对比找到有互动的粉丝

  filename = 'fensi-hudong'
  CSV.open filename,"wb" do |csv|
    csv << %w{UID}
    num = 0
    uids = open '/home/rails/Desktop/uniq-hd-uids'#文件的路径
    uids = uids.read
    uids = uids.strip.split("\n")
    uids = uids.uniq

    uidss = open '/home/rails/Desktop/yzxb-fs-uids'#文件的路径
    uidss = uidss.read
    uidss = uidss.strip.split("\n")
    uidss = uidss.uniq

    uidss.each do |uid|
      if uids.include?(uid)
        csv << [uid]
      end
    end
  end

  #找出每条用户的前100条微博

  filename = '一只学霸有互动的粉丝的前100微博.csv'
  task = GetUserTagsTask.new
  num = 0
  CSV.open filename,"wb" do |csv|
    csv << %w{UID MID 发布时间}
    uids = open '/home/rails/Desktop/fensi-hudong'#文件的路径
    uids = uids.read
    uids = uids.strip.split("\n")
    uids = uids.uniq
    uids.each do |uid|
      uid = uid.strip
      res = task.api.statuses.user_timeline(uid:uid,count:100,page:1)
      res['statuses'].each do |re|
        time = DateTime.parse(re.created_at).strftime("%Y-%m-%d %H:%S")
        csv << [uid,re.mid,time]
      end
    end
  end

  task = GetUserTagsTask.new
  filename = '一只学霸根据weibo_id跑出内容.csv'
  CSV.open filename,"wb" do |csv|
    csv << %w{UID 微博ID 话题数量}
    num = 0
    old_csv = CSV.open '/home/rails/server/weibo-marketing/一只学霸有互动的粉丝的前100微博.csv'
    lines = old_csv.read
    lines.each do |line|
      begin
        uid = line[0]
        weibo_id = line[1]
        weibo = task.api.statuses.show(id:weibo_id)
        if weibo.text.include?("#")
          num += 1
          csv << [uid,weibo_id,num]
        end
        rescue Exception =>e
        puts e.message  #打印出异常信息
        if e.message =~ /target weibo does not exist!/ #=~ 用于正则表达式匹配
           csv << [uid,weibo_id,'目标微博不存在']
        end
      end
    end
  end

  require 'rseg'
  Rseg.load
  filename = '情绪统计.csv'
  task = GetUserTagsTask.new
  CSV.open filename,"wb" do |csv|
    csv << %w{关键词 数量}
    @quan = open '/home/rails/Desktop/quan.rb'#文件的路径
    @quan = @quan.read
    @quan = @quan.strip.split("\n")
    old_csv = CSV.open '/home/rails/Desktop/contents.csv'#(这个csv文件是没有对内容正负面影响进行统计的csv文件)
    lines = old_csv.read
    lines.each do |line|
      content = line[0]
      if !content.blank?
        words = Rseg.segment content.to_s #关键词提取
        eva = 0
        @quan.each{|w|
          good = w.strip
          if words.include?(good)
            eva += 1
            break;
          end
          csv << [good,eva]
        }
      end
    end
  end


  # 文件位置在当前生成的文件夹下
  filename = "产品名称2.csv"
  CSV.open filename,"wb" do |csv|
    csv << %w(用户ID 名称)
    uids = Product.all.pluck("id")
    uids = uids.uniq
    uids.each{|uid|
      name = Product.find(uid).name
      csv << [uid,name]
    }
  end
