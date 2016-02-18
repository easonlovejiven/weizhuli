
  #判断一批人是否是主号的粉丝

  filename = "王思聪.csv"
    CSV.open filename,"wb" do |csv|
      csv << %w{UID 是否是粉丝 时间}
      z_uid = 1826792401
      uids = open "/home/rails/Desktop/uids"
      uids = uids.read
      uids = uids.strip.split("\n")
      uids.each do |uid|
        wur = WeiboUserRelation.where("uid = ? and by_uid = ?",uid,z_uid)
        if wur.blank? 
          csv << [uid,'不是',nil]
          elsif 
            time = wur[0].follow_time.strftime("%Y-%m-%d %H:%M:%S")
            csv << [uid,'是',time]
        end
      end
    end

  #关注的帐号
    
  filename = "3281037352-uids信息-包含.csv"
  CSV.open filename,"wb" do |csv|
    csv << %w{UID 昵称}
    old_csv = CSV.open "3281037352-uids信息.csv"
    old_csv.each do |line|
      content = line[9] 
      if !content.blank?
        if content.include?("万达集团") || content.include?("万达文化产业集团")
          csv << [line[0],line[1]]
        end
      end
    end
  end

    filename = "凯西基本信息补充2.csv"
    CSV.open filename,"wb" do |csv|
    task = GetUserTagsTask.new
    csv << WeiboAccount.to_row_title(:full)+["近1条微博时间"] 
    names = open '/home/rails/Desktop/names'#文件的路径
    names = names.read
    names = names.strip.split("\n")
    names.each do |name|
           begin #解决异常      
               res = task.stable{task.api.users.show(screen_name:name)}
               if !res.blank?
                  account = task.save_weibo_user(res)
               else
                  csv << [name]
                  next
               end
            rescue Exception=>e
                  puts e.message
                  if e.message =~ /User does not exists!/
                    csv << [name,"此用户已被屏蔽"]
                  next
            end
            if res.status.nil?
              csv << account.to_row(:full)
              next
            end
           csv << account.to_row(:full) + [DateTime.parse(res.status.created_at).strftime("%Y-%m-%d %H:%S")]
      end
    end
  end

  #接口取关注帐号

  task = GetUserTagsTask.new
  filename = "万达关注列表.csv"
  CSV.open filename,"wb" do |csv|
    csv << %w{UID}
      begin
      #返回uid关注的用户uids
        ids = task.api.friendships.friends_ids(uid:3281037352).ids
        ids.each{|id|
          csv << [id]
        }
        rescue Exception =>e
          puts e.message
          debugger
          next
      end
  end

  #看这些帐号是否包含几个帐号
  
  task = GetUserTagsTask.new
  filename = "wu"
  CSV.open filename,"wb" do |csv|
    csv << %w{UID 万达}

    uids = open "xin-uids"
    uids = uids.read
    uids = uids.strip.split("\n")
  
    gz_uids = open "you-uids"
    gz_uids = gz_uids.read
    gz_uids = gz_uids.strip.split("\n")

    uids.each do |uid|
      if !gz_uids.include?(uid)
        csv << [uid,"关注"]
      end
    end
  end

  #凯西常用一些uid与一些url的互动内容情况
  
  filename = "凯西互动内容.csv"
  CSV.open filename,"wb" do |csv|
    task = GetUserTagsTask.new
    
    csv << %w{uid 内容 微博连接 动作}
    
      urls = open 'urls'#文件的路径
      urls = urls.read
      urls = urls.strip.split("\n")

      uids = open 'uids'#文件的路径
      uids = uids.read
      uids = uids.strip.split("\n")
      
      urls.each do |url|
        url = url.strip
        weibo_id = WeiboMidUtil.str_to_mid URI.parse(url).path.split("/").last #得到微博的帐号
          #转发
          res = task.stable{task.api.statuses.repost_timeline(weibo_id)} #得到微博记录
          if !res.blank?
              res.reposts.each do |line|
                content = line.text
                uids.each do |uid|
                  uid = uid.to_i
                  if uid == line.user.id
                    csv << [uid,content,url,'转发']
                  end
                end
              end
            end
          #评论
          res = task.stable{task.api.comments.show(weibo_id)} #得到微博记录
          if !res.blank?
              res.comments.each do |line|
                content = line.text
                uids.each do |uid|
                  uid = uid.to_i
                  if uid == line.user.id
                    csv << [uid,url,'评论']
                  end
                end
            end
          end
      end
  end
  
  #最终互动内容(接口提取指定用户指定微薄的互动数)
  
  filename = "凯西互动情况.csv"
  CSV.open filename,"wb" do |csv|
    task = GetUserTagsTask.new
    
    csv << %w{URL 转发 评论 互动总数}
    
      urls = open 'urls'#文件的路径
      urls = urls.read
      urls = urls.strip.split("\n")

      uids = open 'uids'#文件的路径
      uids = uids.read
      uids = uids.strip.split("\n")
      
      urls.each do |url|
        url = url.strip
        weibo_id = WeiboMidUtil.str_to_mid URI.parse(url).path.split("/").last #得到微博的帐号
          #转发
        fs = task.stable{task.api.statuses.repost_timeline(weibo_id)} #得到微博记录
        ms = task.stable{task.api.comments.show(weibo_id)} #得到微博记录
        
        if !fs.blank? && !ms.blank?
          csv << [url,fs.reposts.length,ms.comments.length,fs.reposts.length+ms.comments.length]
          elsif fs.blank? && !ms.blank?
            csv << [url,0,ms.comments.length,ms.comments.length]
            elsif !fs.blank? && ms.blank?
              csv << [url,ms.comments.length,0,ms.comments.length]
        end
      end
  end
  
  #库里边儿提取互动数据(以用户的帐号为准)
  
  filename = "微博互动.csv"
  CSV.open filename,"wb" do |csv|
    
    csv << %w{UID 转发 评论 互动数}

    uids = open 'uids'#文件的路径
    uids = uids.read
    uids = uids.strip.split("\n")
    uids = uids.uniq

    urls = open 'urls'#文件的路径
    urls = urls.read
    urls = urls.strip.split("\n")
    urls = urls.uniq

    uids.each do |uid|
      fs=0
      cs=0
      urls.each do |url|
        weibo_id = WeiboMidUtil.str_to_mid URI.parse(url.strip).path.split("/").last
        comment_num = WeiboComment.where("weibo_id = ?",weibo_id).where("comment_uid = ?",uid).count("distinct comment_id")
        cs += comment_num
        forward_num = WeiboForward.where("weibo_id = ?",weibo_id).where("forward_uid = ?",uid).count("distinct forward_id")
        fs += forward_num
      end
      csv << [uid,fs,cs,fs+cs]
    end
  end
  
  #以连接为准
  
  filename = "微博互动.csv"
  CSV.open filename,"wb" do |csv|
    
    csv << %w{UID 转发 评论 互动数}

    uids = open 'uids'#文件的路径
    uids = uids.read
    uids = uids.strip.split("\n")
    uids = uids.uniq

    urls = open 'urls'#文件的路径
    urls = urls.read
    urls = urls.strip.split("\n")
    urls = urls.uniq

    urls.each do |url|
      fs=0
      cs=0
      weibo_id = WeiboMidUtil.str_to_mid URI.parse(url.strip).path.split("/").last
      uids.each do |uid|
        comment_num = WeiboComment.where("weibo_id = ?",weibo_id).where("comment_uid = ?",uid).count("distinct comment_id")
        cs += comment_num
        forward_num = WeiboForward.where("weibo_id = ?",weibo_id).where("forward_uid = ?",uid).count("distinct forward_id")
        fs += forward_num
      end
      csv << [url,fs,cs,fs+cs]
    end
  end
  
  #互动内容优化(只获取一个评论或者转发)有转发了就不要评论了
  
  filename = "凯西互动内容.csv"
  CSV.open filename,"wb" do |csv|
    task = GetUserTagsTask.new
    
    csv << %w{uid 内容 微博连接 动作}
    
      urls = open 'urls'#文件的路径
      urls = urls.read
      urls = urls.strip.split("\n")

      uids = open 'uids'#文件的路径
      uids = uids.read
      uids = uids.strip.split("\n")
      
      urls.each do |url|
        url = url.strip
        weibo_id = WeiboMidUtil.str_to_mid URI.parse(url).path.split("/").last #得到微博的帐号
          #转发
          res = task.stable{task.api.statuses.repost_timeline(weibo_id)} #得到微博记录
          if !res.blank?
            if res.reposts.size >= 1
              re = res.reposts[0,1]
              re.each do |line|
                content = line.text
                uids.each do |uid|
                  uid = uid.to_i
                  if uid == line.user.id
                    csv << [uid,url,content,'转发']
                  end
                end
              end
            end
          end
          #评论
          res = task.stable{task.api.comments.show(weibo_id)} #得到微博记录
          #重新获取一次转发的记录
          if !res.nil?
            if res.comments.length >= 1
              com = res.comments[0,1]
              com.each do |line|
                content = line.text
                uids.each do |uid|
                  uid = uid.to_i
                  if uid == line.user.id
                    csv << [uid,url,content,'评论']
                  end
                end
              end
            end
          end
        end
  end
  
  
  #一些用户与中国两个帐号的信息和关注时间
  
  filename = 'intel关注时间.csv'
  CSV.ope老量老量n filename,"wb" do |csv|
    csv << %w{UID 关注时间}
    task = GetUserTagsTask.new
    uids = open 'xin-uids'#文件的路径
    uids = uids.read
    uids = uids.strip.split("\n")
    uids = uids.uniq
    uids.each do |uid|
      begin
        rel = WeiboUserRelation.where("uid = ? and by_uid = ?",2637370927,uid)
        if !rel.blank?
          follow_time = rel[0].follow_time.strftime("%Y-%m-%d %H:%M")
          csv << [uid,follow_time]
          elsif rel.nil?
            csv << [uid,'不是粉丝']
        end
      rescue Exception=>e
        if e.message =~ /User does not exists!/
          csv << [uid,"此用户已被屏蔽"]
        end
      end
    end 
  end
  
  filename = "you"
  CSV.open filename,"wb" do |csv|
    csv << %w{URL}
    urls = open "urlss"
    urls = urls.read
    urls = urls.strip.split("\n")
    urls = urls.uniq
    urls.each do |url|  
      csv << [url]
    end
  end
  
  
  #建波
  
  filename = "互动内容.csv"
  CSV.open filename,"wb" do |csv|
    task = GetUserTagsTask.new
    
    csv << %w{微博连接 评论日期 评论用户 互动内容}
    
    urls = open 'urls'
    urls = urls.read
    urls = urls.strip.split("\n")

    urls.each do |url|
      url = url.strip
      weibo_id = WeiboMidUtil.str_to_mid URI.parse(url).path.split("/").last #得到微博的帐号
      res = task.stable{task.api.comments.show(weibo_id)} #得到微博记录
      if !res.blank?
        res.comments.each do |line|
          content = line.text
          time = Time.parse(line.created_at).strftime("%Y-%m-%d %H:%M:%S")
          csv << [url,time,line.user.id,content]
        end
      end
    end
  end
