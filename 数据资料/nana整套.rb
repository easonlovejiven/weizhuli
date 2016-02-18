  @@name = "芯品汇"
  #中国,2637370247,芯品汇，2637370927
  start_time = "2015-08-31"
  end_time = "2015-09-07"
  uid = 2637370247
  filename = "#{@@name}微薄列表.csv"
   CSV.open filename,"wb" do |csv|
   task = GetUserTagsTask.new
    csv << %w{name 微博内容 发布时间 转发数 评论数 互动总数 URL 原创 发布来源}
      top_id = nil
      task.paginate(:per_page=>100) do |page|
      begin
        res = task.stable{task.api.statuses.user_timeline(uid:uid,count:100, page:page)}
        processing = true
        if page == 1
          if Time.parse(res['statuses'][0].created_at) < Time.parse(res['statuses'][1].created_at)
          top_id = res['statuses'][0].id
          end
         end
        res['statuses'].each{|w|
          if w.id == top_id
            srouce = ActionView::Base.full_sanitizer.sanitize(w.source) #去出所有的标签
            url = "http://weibo.com/#{uid}/#{WeiboMidUtil.mid_to_str(w.id.to_s)}"
            post_at = Time.parse(w.created_at).strftime("%Y-%m-%d %H:%M")
            scount = w.reposts_count + w.comments_count
            origin = !w.retweeted_status
            csv << [w.user.screen_name, w.text,post_at, w.reposts_count, w.comments_count,scount, url,origin, srouce]
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
            csv << [w.user.screen_name, text, post_at, w.reposts_count, w.comments_count,scount, url,origin, srouce]
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
  end
  weibo_list_file = "#{@@name}微薄列表.csv"
  #buzz声量得到urls
  urls = [] # init urls
  CSV.open(weibo_list_file).each{|line|
    if line[6] != "URL"
      urls << line[6]
    end
  }

=begin
  urls = open "xph-url"
  urls = urls.read
  urls = urls.strip.split("\n")
=end
  #BUZZ声量
  require 'rseg'
  Rseg.load
  filename = "#{@@name}-buzz.csv" #针对每条微博的关键词量
  #全局变量统计关键词数量
    keywords = open "keywords"
    keywords = keywords.read
    keywords = keywords.strip.split("\n")
    words_stats = {}
    keywords.each{|word|
      word = word.strip
      words_stats[word] = 0
    }
  CSV.open filename,"wb" do |csv|
    csv << %w{URL BUZZ声量}
    urls = urls.uniq
    urls.each do |url|
      weibo_id = WeiboMidUtil.str_to_mid URI.parse(url.strip).path.split("/").last
      forwards = WeiboForward.where("weibo_id = ?",weibo_id)
      comments = WeiboComment.where("weibo_id = ?",weibo_id)
       # 转发
      if !forwards.blank?
        forwards.each do |forward|
          #得到一个用户信息对象
          forward_text = MForward.find_by_id(forward.forward_id)
          if !forward_text.blank?
            ftext = forward_text.text.strip
            @str = ""
            keywords.each{|word|
              @key = word.strip
              if ftext.include?(@key)
                @str += @key
                @str = @str += ","
                words_stats[@key] += 1
              end
            }
          end
        end
      end
    
      # 评论
      if !comments.blank?
        comments.each do |comment|
          #得到一个用户信息对象
          comment_text = MComment.find_by_id(comment.comment_id)
          if !comment_text.blank?
            @str = ""
            ctext = comment_text.text.strip
            keywords.each{|word|
              @key = word.strip
              if ctext.include?(@key)
                @str += @key
                @str = @str += ","
                words_stats[@key] += 1
              end
            }
          end
        end
      end
      num = words_stats.values.sum
      #每循环一个连接都要清空一下values
      keywords.each{|w|
        @key = w.strip
        words_stats[@key] = 0
      }
      csv << [url,num]
    end
  end
  
  #得到微薄的互动内容
  filename = "#{@@name}互动内容.csv"
  CSV.open filename,"wb" do |csv|
  task = GetUserTagsTask.new
  csv << %w{uid 内容 正负面 无效内容 互动时间 互动微博连接 动作}
      urls = urls.uniq
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
                 csv << [line.user.id,line.text,fake_content, DateTime.parse(line.created_at).strftime("%Y-%m-%d %H:%S"),url,'转发']
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
                 csv << [line.user.id,line.text,fake_content, DateTime.parse(line.created_at).strftime("%Y-%m-%d %H:%S"),url,'评论']
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
  
  #@主帐号数和新增粉丝数
  filename = "#{@@name}@数&新增粉丝数.csv"
  CSV.open filename,"wb" do |csv|
    csv << %w{名称 @数量 新增粉丝数}
    num = 0
    contents = []
    name = "英特尔"
    CSV.open("#{@@name}互动内容.csv").each{|line|
      if line[6] != "微博内容"
        contents << line[1]
      end
    }
    contents.each{|content|
      if content.include?("@英特尔#{@@name}")
        num += 1
      end
    }
    new_fans = WeiboUserRelation.where("uid = ? and follow_time between ? and ?",uid,start_time,end_time).count
    csv << [name+@@name,num,new_fans]
  end
  
  #将CSV转换成xlsx文件
  Axlsx::Package.new do |p|
  
    p.workbook.add_worksheet(:name => "#{@@name}-buzz" ) do |sheet|
      old_csv = CSV.open "#{@@name}-buzz.csv"
      lines = old_csv.read
      lines.each{|row|
        sheet.add_row row
      }
    end
    
    p.workbook.add_worksheet(:name => "#{@@name}@数$新增粉丝数" ) do |sheet|
      old_csv = CSV.open "#{@@name}@数&新增粉丝数.csv"
      lines = old_csv.read
      lines.each{|row|
        sheet.add_row row
      }
    end
      p.serialize('英特尔芯品汇.xlsx')
  end
