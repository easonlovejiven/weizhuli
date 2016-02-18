 #用户http://weibo.com/2637370927/CauV7wruw?from=page_1006062637370927_profile&wvr=6&mod=weibotime&type=comment#_rnd1427678963361
#(1)用户基本信息(只针对库里边的信息)
  name = "intel-"
  filename = "#{name}user-infor.csv"
  CSV.open filename,"wb" do |csv|	
    csv << %w{UID 昵称 位置 性别 粉丝 关注 微博 注册时间 认证类型 认证原因}
    uids = open "intel-fans"
    uids = uids.read
    uids = uids.strip.split("\n")
    uids = uids.uniq
    uids.each{|uid|
      wa = WeiboAccount.find_by_uid(uid)
      if !wa.blank?
        #认证类型
        type_name = wa.human_verified_type #这块儿怎样将数组转换成文字格式
          name_str = "" #存放认证类型
          #将认证类型的这个数组循环遍历
          type_name.each do |name|
            if !name_str.blank?
              name_str += name+","
            end
          end
           name_str = name_str[0,name_str.length-1]
          if !wa.created_at.blank?
            csv << [uid,wa.screen_name,wa.location,wa.human_gender,wa.followers_count,wa.friends_count,wa.statuses_count,wa.created_at.strftime("%Y-%m-%d %H:%M:%S"),name_str]
            else
              csv << [uid,wa.screen_name,wa.location,wa.human_gender,wa.followers_count,wa.friends_count,wa.statuses_count,"没有注册时间",name_str]
          end
        else
          csv << [uid,"取不到用户信息"]
        end
    }
  end
  
  #平台
  name = "信息"
  filename = "#{name}user-infor.csv"
  task = GetUserTagsTask.new
  CSV.open filename,"wb" do |csv|
  csv << %w{UID 昵称 位置 性别 粉丝 关注 微博 注册时间 认证类型 认证原因}
    uids = open "uids"
    uids = uids.read
    uids = uids.strip.split("\n")
    uids = uids.uniq
    uids.each{|uid|
        account = task.load_weibo_user(uid.to_i)
        if account.blank?
            cvs << [uid]
            next
        end
        csv << account.to_row
      }
  end
  #1,客户端输入：A，B
  
  
  #接口导出用户基本信息(针对库里没有的用户信息)
  name = "2.8W用户信息"
  filename = "#{name}.csv"
  CSV.open filename,"wb" do |csv|
    task = GetUserTagsTask.new
    csv << WeiboAccount.to_row_title(:full)+["近1条微博时间"] 
    uids = open "uids"
    uids = uids.read
    uids = uids.strip.split("\n")
    uids = uids.uniq
    uids.each{|uid|
     begin #解决异常
      debugger
         res = task.stable{task.api.users.show(uid:uid)}
         if !res.blank?
            account = task.save_weibo_user(res)
         else
          csv << [uid,"此用户已屏蔽"]
          next
         end
      rescue Exception=>e
        csv << [uid,"信息有异常"]
        next
      end
     csv << account.to_row(:full)
     }
  end
  
  #用户活跃度情况(只针对库里边儿的用户信息)
  name = "28"
  filename = "#{name}活跃度.csv"
  CSV.open filename,"wb" do |csv|
  task = GetUserTagsTask.new
  csv << %w{uid 平均转发率 平均评论率 平均转发 平均评论 活跃度 原创占比 日均发帖量 近七天发贴量}
  #if names[0].to_i == 0
    #uids = ReportUtils.names_to_uids(names,true)
  #end
  uids = open "28-uid"
  uids = uids.read
  uids = uids.strip.split("\n")
  uids = uids.uniq
  uids.each do|uid|
     row = []
     uid = uid.strip
     weiboEvaluates = WeiboUserEvaluate.where("uid = ?",uid).first
     if weiboEvaluates.nil? || weiboEvaluates.origin_rate == -1
        begin
        weiboEvaluates= WeiboAccount.find_by_uid(uid).update_evaluates
        rescue IRB::Abort
            raise $!
          rescue Exception=>e
            puts e.message
              csv << [uid]
            next
        end
     end
     evaluates = weiboEvaluates.forward_average + weiboEvaluates.comment_average
     row << uid
     row << weiboEvaluates.forward_rate/100.0
     row << weiboEvaluates.forward_rate/100.0
     row << weiboEvaluates.forward_average/100.0
     row << weiboEvaluates.comment_average/100.0
     row << evaluates/100.0
     row << weiboEvaluates.origin_rate
     row << weiboEvaluates.day_posts
     row << weiboEvaluates.day_posts_in_week
     csv << row
    end
  end
  
  #根据微薄昵称导出用户id(针对库里取不到的信息)
  
  task = GetUserTagsTask.new
  name = ""
  filename = "#{name}name_by_uid.csv"
  CSV.open filename,"wb" do |csv|
    names = open "names"
    names = names.read
    names = names.strip.split("\n")
    names = names.uniq
    names.each do |name|
      begin
        res = task.stable{task.api.users.show(screen_name:name)}
        if !res.blank?
          csv << [res.id]
        end
      end
      rescue Exception=>e
        puts e.message
          csv << [name,"没有这个昵称"]
        next
      end
    end
  end
  #####微薄
  #监控微薄列表(只针对监控的主帐号)
  name = ""
  filename = "#{name}微薄列表.csv"
    start_time = ""
    end_time = ""
    uids = open "a-uid"
    uids = uids.read
    uids = uids.strip.split("\n")
    uids = uids.uniq
    scope = WeiboDetail.where("uid in (?)",uids)
    scope = scope.where("post_at >= ?",start_time) if start_time
    scope = scope.where("post_at < ?",end_time) if end_time
    scope = scope.order("uid, post_at asc")
    accounts = {}
      csv << %w{UID 内容 时间 转发 评论 URL 来源 类型 原创}
      scope.each{|record|
        accounts[record.uid] ||= WeiboAccount.find_by_uid(record.uid)
        account = accounts[record.uid]
        c = MWeiboContent.find(record.weibo_id)
        next if c.nil?
        srouce = ActionView::Base.full_sanitizer.sanitize(c.source)
        type = case 
          when record.image? && record.video?
            "image + video"
          when record.image?
            "image"
          when record.video?
            "video"
          when record.music?
            "music"
          when record.vote?
            "vote"
          else
            "text"
        end
        origin = !record.forward
        post_at = record.post_at.strftime("%Y-%m-%d %H:%M:%S")
        csv << [account.screen_name, c.text,post_at, record.reposts_count, record.comments_count, record.url, srouce, type, origin]
      }
  end
  
  #提取微薄列表(从接口中取)
  #3.23-29，3.30-4.5，4.6-12，4.13-19，4.20-26，4.27-5.3，5.4-10，5.11-17，5.18-24
  #3.02-3.9,3.9-3.16,3.16-3.23
  name = ""
  filename = "#{name}234微薄列表-1.csv"
   CSV.open filename,"wb" do |csv|
   task = GetUserTagsTask.new
      start_time = "2015-03-02"
      end_time = "2015-03-09"
      csv << %w{name 微博内容 发布时间 转发数 评论数 互动总数 URL 原创 发布来源}
      uids = open "uids"
      uids = uids.read
      uids = uids.strip.split("\n")
      uids.each do |uid|
        uid = uid.strip
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
  end
  
  #提取微薄互动信息
  name = "500"
  filename = "#{name}-uid.csv"
  CSV.open filename,"wb" do |csv|
    task = GetUserTagsTask.new
    csv << %w{url 是否原创 uid 发布账号昵称 粉丝数 类型 来源} 
      @all_interactive = []
      urls = open "500-url"
      urls = urls.read
      urls = urls.strip.split("\n")
      urls = urls.uniq
      urls.each do |url|
      url = url.strip
      weibo_id = WeiboMidUtil.str_to_mid URI.parse(url).path.split("/").last#http://weibo.com/1902520272/AdgAY5a54  http://weibo.com/2637370927/AdYvTsFCh
      forward = []
      comment = []
      page = 1
      processing = true
        begin
          begin
            res = task.stable{task.api.statuses.repost_timeline(weibo_id.to_s,count:200,page:page)}#根据weibo_id查转发人信息count  
              if !res.blank?&&!res.reposts.blank?        
                 res.reposts.each do |line|  
                  if line.nil?
                     processing = false
                     break
                  end      
                 forward << line.user.id
                 end
               else
                processing = false
                break
               end         
          rescue Exception=>e
            puts e.message
          end
          page+=1
        end while processing == true
        page = 1
        processing = true
        begin
          begin     
              res = task.stable{task.api.comments.show(weibo_id,count:200,page:page)}#根据weibo_id查评论人信息   
              if !res.blank?&&!res.comments.blank?  
                 res.comments.each do |line| 
                  if line.nil?
                     processing = false
                     break
                  end               
                 comment << line.user.id
                 end
               else
                processing = false
                break
               end
           rescue Exception=>e
            puts e.message
           end
           page+=1 
        end while processing == true
      interactive = forward+comment
      @all_interactive += interactive
      begin #解决异常
       res = task.stable{task.api.statuses.show(id:weibo_id)}#http://weibo.com/2056744733/Ad6n2BxT4
       srouce = ActionView::Base.full_sanitizer.sanitize(res.source)
       csv << [url,res.retweeted_status.nil?? '是' :'否' ,res.user.id,res.user.screen_name,res.user.followers_count,WeiboListInteractiveUserExportor::human_verified_type(res.user.verified_type)*',',srouce]
      rescue Exception=>e
        if e.message =~ / does not exist!/
          rows << [url]
        else
          raise e
        end
      end
    end
  end
    
  name = "活动贴"
  filename = "#{name}互动人信息列表.csv"
  CSV.open filename,"wb" do |csv|
    task = GetUserTagsTask.new
    csv << %w{url 是否原创 uid 发布账号昵称} 
      @all_interactive = []
      urls = open "500-url"
      urls = urls.read
      urls = urls.strip.split("\n")
      urls = urls.uniq
      urls.each do |url|
      url = url.strip
      weibo_id = WeiboMidUtil.str_to_mid URI.parse(url).path.split("/").last#http://weibo.com/1902520272/AdgAY5a54  http://weibo.com/2637370927/AdYvTsFCh
      forward = []
      comment = []
      page = 1
      processing = true
        begin
          begin
            res = task.stable{task.api.statuses.repost_timeline(weibo_id.to_s,count:200,page:page)}#根据weibo_id查转发人信息count  
              if !res.blank?&&!res.reposts.blank?        
                 res.reposts.each do |line|  
                  if line.nil?
                     processing = false
                     break
                  end      
                 forward << line.user.id
                 end
               else
                processing = false
                break
               end         
          rescue Exception=>e
            puts e.message
          end
          page+=1
        end while processing == true
        page = 1
        processing = true
        begin
          begin     
              res = task.stable{task.api.comments.show(weibo_id,count:200,page:page)}#根据weibo_id查评论人信息   
              if !res.blank?&&!res.comments.blank?  
                 res.comments.each do |line| 
                  if line.nil?
                     processing = false
                     break
                  end               
                 comment << line.user.id
                 end
               else
                processing = false
                break
               end
           rescue Exception=>e
            puts e.message
           end
           page+=1 
        end while processing == true
      interactive = forward+comment
      @all_interactive += interactive
      begin #解决异常
       res = task.stable{task.api.statuses.show(id:weibo_id)}#http://weibo.com/2056744733/Ad6n2BxT4
       srouce = ActionView::Base.full_sanitizer.sanitize(res.source)
       csv << [url,res.retweeted_status.nil?? '是' :'否' ,res.user.id,res.user.screen_name]
      rescue Exception=>e
        if e.message =~ / does not exist!/
          rows << [url]
        else
          raise e
        end
      end
    end
    
  #互动人信息(针对所有)
  name = "母亲节"
  filename = "#{name}互动人信息.csv"
  CSV.open filename,"wb" do |csv|
  urls = open "mother-url"
  urls = urls.read
  urls = urls.strip.split("\n")
  urls = urls.uniq
    task = GetUserTagsTask.new
    csv << WeiboAccount.to_row_title(:full)
    uniq_uids = []
    @all_interactive = []
    urls.each do|url|
        url = url.strip
        weibo_id = WeiboMidUtil.str_to_mid url.split("/").last#http://weibo.com/1902520272/AdgAY5a54  http://weibo.com/2637370927/AdYvTsFCh
  #http://weibo.com/2803301701/AiivFxLc4
        forward = []
        comment = []
        page = 1
        processing = true
          begin
            begin
              res = task.stable{task.api.statuses.repost_timeline(weibo_id,count:200,page:page)}#根据weibo_id查转发人信息count
                if !res.blank?
                   res.reposts.each do |line|
                     row = []
                    if line.nil?
                       processing = false
                       break
                    end
                    forward << line.user.id

                    if !uniq_uids.include?(line.user.id)
                      uniq_uids << line.user.id 
                      row = WeiboAccount.to_row(line.user)
                      csv << row
                    end
                   end
                 else
                  processing = false
                  break
                 end
            rescue Exception=>e
              next
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
                    comment << line.user.id

                    if !uniq_uids.include?(line.user.id)
                      uniq_uids << line.user.id
                      row = WeiboAccount.to_row(line.user)
                      csv << row
                    end
                   end
                 else
                  processing = false
                  break
                 end
             rescue Exception=>e
              next
             end
             page+=1
          end while processing == true
      end
  end
  
  #监控帐号微博互动内容列表(根据urls)
  name = "河阳"
  filename = "#{name}监控帐号互动内容列表.csv"
  urls = open "urls"
  urls = urls.read
  urls = urls.strip.split("\n")
  urls = urls.uniq
     #接口提取 api 通过url 转发 评论的内容 查出这些人说了些什么
  task = GetUserTagsTask.new
    te = TextEvaluate.new
    csv << WeiboAccount.to_row_title(:full)+%w{内容 互动时间 互动微博连接 动作 正负面 正负面匹配词 有效性}
       
      urls.each do|url|
      
        url = url.strip
        weibo_id = ::WeiboMidUtil.str_to_mid url.split("/").last
        commentcount = 0
        forward_weibo = WeiboForward.where("weibo_id = ?",weibo_id)
        comment_weibo = WeiboComment.where("weibo_id = ?",weibo_id)
          if !comment_weibo.nil?
            comment_weibo.each do |comment|
               row = []
               account = task.load_weibo_user(comment.comment_uid.to_s)
               comment.blank? ? commentat = '' : commentat = comment.comment_at.strftime("%Y-%m-%d %H:%M:%S")
               url = "http://weibo.com/#{comment.uid}/#{WeiboMidUtil.mid_to_str(comment.comment_id.to_s)}"
               c  = MComment.find(comment.comment_id)
               next if c.nil?
               eva,eva_word = te.evaluate(c.text)
               valid = te.valid(c.text)
               row = account.to_row(:full) + [url,c.text,commentat,'评论',eva,eva_word,valid]
               csv << row
            end
          end
          if !forward_weibo.nil?
            forward_weibo.each do |forward|
              row = []
              account = task.load_weibo_user(forward.forward_uid.to_s)
              forward.blank? ? forwardat = '': forwardat = forward.forward_at.strftime("%Y-%m-%d %H:%M:%S")
              url = "http://weibo.com/#{forward.forward_uid}/#{WeiboMidUtil.mid_to_str(forward.forward_id.to_s)}"
              c =  MForward.find(forward.forward_id)
              next if c.nil?
               eva,eva_word = te.evaluate(c.text)
               valid = te.valid(c.text)
              row = account.to_row(:full) + [url,c.text,forwardat,'转发',eva,eva_word,valid]
               csv << row
            end
          end
      end
   end
   
  #接口提取微博互动内容列表(根据urls)
  #抓取互动用户的二次转发
  name = "双帐号"
  filename = "#{name}接口提取微博互动内容列表.csv"
  CSV.open filename,"wb" do |csv|
  urls = open "500-url"
  urls = urls.read
  urls = urls.strip.split("\n")
  urls = urls.uniq
  task = GetUserTagsTask.new
    csv << %w{uid 互动内容 内容有效性 互动时间 互动微博连接 动作 二次转发}
       
      urls.each do|line|
      
      url = line.strip
      weibo_id = WeiboMidUtil.str_to_mid URI.parse(url).path.split("/").last# http://weibo.com/1795839430/AhbvtnvrV http://weibo.com/1795839430/AhmhfkBY5
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
                 csv << [line.user.id,line.text,fake_content, DateTime.parse(line.created_at).strftime("%Y-%m-%d %H:%S"),url,'转发',line.reposts_count]
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
     
     #接口提取 api 通过url 转发 评论的内容 查出这些人说了些什么
  filename = "B.csv"
  CSV.open filename,"wb" do |csv|
  task = GetUserTagsTask.new
  csv << %w{uid 内容 正负面 无效内容 互动时间 互动微博连接 动作}
      urls = open '500-url'#文件的路径
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
   
  #接口提取微薄的转发和评论及互动数(单个获取)
  filename = "test互动1.csv"
  CSV.open filename,"wb" do |csv|
  task = GetUserTagsTask.new
  #存放批量微薄的id
  csv << %w{URL 转发 评论 互动}
    urls = open 'test-url'#文件的路径
    urls = urls.read
    urls = urls.strip.split("\n")
    urls.each do |url|
      url = url.strip
      weibo_id = WeiboMidUtil.str_to_mid URI.parse(url).path.split("/").last
      res = task.stable{task.api.statuses.count(ids:weibo_id)}
      csv << [url,res[0].reposts,res[0].comments,res[0].reposts+res[0].comments]
    end
  end
  
  #接口提取微薄的转发和评论及互动数(批量获取)
  filename = "test互动.csv"
  CSV.open filename,"wb" do |csv|
  task = GetUserTagsTask.new
  weibo_ids = ""
  #存放批量微薄的id
  csv << %w{转发 评论 互动}
    urls = open 'test-url'#文件的路径
    urls = urls.read
    urls = urls.strip.split("\n")
    urls.each do |url|
      url = url.strip
      weibo_id = WeiboMidUtil.str_to_mid URI.parse(url).path.split("/").last
      weibo_id += ","
      weibo_ids += weibo_id.to_s
    end
    weibo_ids = weibo_ids[0,weibo_ids.size-1]
    res = task.stable{task.api.statuses.count(ids:weibo_ids)}
    res.each{|line|
      csv << [line.reposts,line.comments,line.reposts+line.comments]
    }
  end
