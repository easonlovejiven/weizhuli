#========================>>用户基本信息根据(uids or names)

#UID", "昵称", "位置", "性别", "粉丝", "关注", "微博", "注册时间", "认证类型", "认证原因"
  #(1)手动抛(不通过接口或者平台)
  filename = "3000粉丝信息2.csv"
  CSV.open filename,"wb" do |csv|
    csv << %w{UID 昵称 位置 性别 粉丝 关注 微博 注册时间 认证类型 认证原因}
    @sex = "" #性别
    @tpye_name = "" #认证类型
    @uids = open '/home/rails/Desktop/3000-uid'#文件的路径
    @uids = @uids.read
    @uids = @uids.strip.split("\n")
    @uids.each do |uid|
      begin
        weibo_account = WeiboAccount.where("uid = ?",uid)
        if !weibo_account.blank?
          screen_name = weibo_account[0].screen_name #昵称
          location = weibo_account[0].location #位置
          #weibo_account[0].gender == 0 ? @sex = "女" : @sex = "男"
          @sex = weibo_account[0].human_gender #在(模板)weibo_account里有详解
          followers_count = weibo_account[0].followers_count #粉丝
          friends_count = weibo_account[0].friends_count #关注
          statuses_count = weibo_account[0].statuses_count #微博数量
          created_at = weibo_account[0].created_at.strftime("%Y-%m-%d %H:%M:%S") #用户创建(注册)时间
          verified_type = weibo_account[0].verified_type #认证类型
          #调用认证类型的方法
          @type_name = weibo_account[0].human_verified_type #这块儿怎样将数组转换成文字格式
          @name_str = "" #存放认证类型
          #将认证类型的这个数组循环遍历  
          @type_name.each do |name|
            @name_str += name+","
          end
           @name_str = @name_str[0,@name_str.length-1]
          csv << [uid,screen_name,location,@sex,followers_count,friends_count,statuses_count,created_at,@name_str,nil]
        end
        rescue Exception =>e
        if e.message =~ /User does not exists/ #=~ 用于正则表达式匹配
           csv << [uid,"此用户已被屏蔽"]
        end
      end
    end
  end

#===================================>>

  #不通过接口或者平台
  filename = "凯西基本信息补充3.csv"
  CSV.open filename,"wb" do |csv|
    csv << %w{UID 昵称 微博连接 位置 性别 粉丝 关注 微博 注册时间 认证类型 认证原因}
    @sex = "" #性别
    @tpye_name = "" #认证类型
    @uids = open '/home/rails/Desktop/names'#文件的路径
    @uids = @uids.read
    @uids = @uids.strip.split("\n")
    @uids.each do |name|
      begin
        weibo_account = WeiboAccount.where("screen_name = ?",name)
        if !weibo_account.blank?
          uid = weibo_account[0].uid
          location = weibo_account[0].location #位置
          url = "http://weibo.com/#{uid}"
          #weibo_account[0].gender == 0 ? @sex = "女" : @sex = "男"
          @sex = weibo_account[0].human_gender
          followers_count = weibo_account[0].followers_count #粉丝
          friends_count = weibo_account[0].friends_count #关注
          statuses_count = weibo_account[0].statuses_count #微博数量
          created_at = weibo_account[0].created_at.strftime("%Y-%m-%d %H:%M:%S") #用户创建(注册)时间
          verified_type = weibo_account[0].verified_type #认证类型
          #调用认证类型的方法
          type_name = weibo_account[0].human_verified_type #这块儿怎样将数组转换成文字格式
          name_str = "" #存放认证类型
          #将认证类型的这个数组循环遍历  
          type_name.each do |name|
            if !name.blank?
              name_str += name+","
            end
          end
          csv << [uid,name,url,location,@sex,followers_count,friends_count,statuses_count,created_at,name_str,nil]
          elsif
            csv << [nil,name,nil,nil,nil,nil,nil,nil,nil,nil,nil]
        end
        rescue Exception =>e
        if e.message =~ /User does not exists!/ #=~ 用于正则表达式匹配
           csv << [uid,"此用户已被屏蔽"]
        end
      end
    end
  end
#============================>>用户基本信息(根据uid)完美收关
  #用户的备注信息是在Mong数据库当中的(有些用户可能不存在)
  filename = "3000粉丝信息.csv"
  CSV.open filename,"wb" do |csv|
    task = GetUserTagsTask.new #最近一条微博时间要从接口当中提取
    csv << %w{UID 昵称 位置 性别 粉丝 关注 微博 注册时间 认证信息(认证类型) 认证原因 备注 标签 近一条微博时间(当前这个用户发布的最后一条微博的时间)}

    @uids = open '/home/rails/Desktop/3000-uid'
    @uids = @uids.read
    @uids = @uids.strip.split("\n")
    @uids = @uids.uniq
    @uids.each do |uid|

      begin
        res = task.stable{task.api.users.show(uid:uid)} #有些用户库里边儿能取到,但接口中取不到(1,网络连接问题;2,该用户被屏蔽了;)
      
        weibo_account = WeiboAccount.where("uid = ?",uid)
        if !weibo_account.blank?
          screen_name = weibo_account[0].screen_name #昵称
          location = weibo_account[0].location #位置
          #weibo_account[0].gender == 0 ? @sex = "女" : @sex = "男"
          @sex = weibo_account[0].human_gender
          followers_count = weibo_account[0].followers_count #粉丝
          friends_count = weibo_account[0].friends_count #关注
          statuses_count = weibo_account[0].statuses_count #微博数量
          created_at = weibo_account[0].created_at.strftime("%Y-%m-%d %H:%M:%S") #用户创建(注册)时间
          #调用认证类型的方法(不用传递任何参数,它可以根据调用的这个方法的对象去导出认证类型)
          @type_name = weibo_account[0].human_verified_type
          @name_str = "" #存放认证类型
          #将认证类型的这个数组循环遍历  
          @type_name.each do |name|
          #@type_name 有可能 ["微博女郎", nil] 有一个空值
            if !name.blank?         
              @name_str += name+","
            end
          end
           @name_str = @name_str[0,@name_str.length-1]
        end
        #用户备注信息(在MongoDB里边儿的MUser.description里)
        #用户最近一条微博时间
        time = DateTime.parse(res.status.created_at).strftime("%Y-%m-%d %H:%S")
        muser = MUser.find_by_id(uid.to_i) #这块儿要注意了,必须要把uid转换成整形的
        if !muser.blank?
          length = muser.tags.size
          if length == 0
            csv << [uid,screen_name,location,@sex,followers_count,friends_count,statuses_count,created_at,@name_str,nil,muser.description,nil,time]
          elsif length > 0
            tag_str = ""
            muser.tags.each do |t|
              tag_str += t + ","
            end
              tag_str = tag_str[0,tag_str.length-1]
            csv << [uid,screen_name,location,@sex,followers_count,friends_count,statuses_count,created_at,@name_str,nil,muser.description,tag_str,time]
          end
        end
        rescue Exception=>e
        if e.message =~ /User does not exists/ #异常信息
          weibo = WeiboAccount.find_by_uid(uid)
          csv << [uid,weibo.screen_name,weibo.location,weibo.gender,weibo.followers_count,weibo.friends_count,weibo.statuses_count,weibo.created_at.strftime("%Y-%m-%d %H:%M:%S"),@name_str,nil,tag_str,"此用户已被屏蔽"]
         else
          raise e
        end
      end
    end
  end
  
  #信息
  
    filename = "类型.csv"
    CSV.open filename,"wb" do |csv|
      old = open "gaibian"
      old = old.read
      old = old.strip.split("\n")
      old.each{|type|
        debugger
        begin
          type = JSON.parse(type).join(",")
          rescue Exception=>e
          debugger
          csv << [type]
        end
      }
    end
    
    filename = "类型2.csv"
    CSV.open filename,"wb" do |csv|
      old = open "gaibian"
      old = old.read
      old = old.strip.split("\n")
      old.each{|type|
        begin
          debugger
          type = JSON.parse(type).join(",")
          rescue Exception
            debugger
        end
        csv << [type]
      }
    end

  #=============================================>>用户互动量(根据uids和name进行导出)

  filename = "用户活跃度-3964.csv" #完美收关
  CSV.open filename,"wb" do |csv| #也可以根据screen_name 进行查询
    csv << %w{uid 平均转发率 平均评论率 平均转发 平均评论 活跃度 原创占比 日均发帖量 近七天发贴量}
      #要通过接口去提取这个用户转发或者评论的最近100条微博
      #思路:先获取这个用户的所有转发和评论的微博信息
      task = GetUserTagsTask.new
      @uids = open 'uids-3964'
      @uids = @uids.read
      @uids = @uids.strip.split("\n")
      @uids = @uids.uniq
      @uids.each do |uid|
        we = WeiboUserEvaluate.find_by_uid(uid)
        if !we.blank? #在这块儿要做个非空判断
          avg_forward_rate = we.forward_rate/100.0 #平均转发率
          avg_comment_rate = we.comment_rate/100.0 #平均评论率
          avg_forward_average = we.forward_average/100.0 #平均转发数
          avg_comment_average = we.comment_average/100.0 #平均评论数
          evaluates = avg_forward_average+avg_comment_average #活跃度
          origin_rate = we.origin_rate #原创占比
          day_posts = we.day_posts #日均发贴量
          day_posts_in_weeks = we.day_posts_in_week #近七天发贴量
          csv << [uid,avg_forward_rate,avg_comment_rate,avg_forward_average,avg_comment_average,evaluates,origin_rate,day_posts,day_posts_in_weeks]
      end
    end
  end

  #===============================================>微博用户 以及与 监控帐户互动 信息 导出(根据uids)

  filename = "每个用户与主号是否有二次转发2.csv"
  CSV.open filename,"wb" do |csv|
    uid_url = '/home/rails/Desktop/intel-uids'
    start_time = '2014-09-01'
    end_time = '2014-09-28'
    target_uid = 2637370927 #主号
    return if uids.blank?
    task = GetUserTagsTask.new
    csv << WeiboAccount.to_row_title + %w{活跃度 原微博链接  原微博发布时间 原微博内容 原微博内容分类 转发微博连接 转发时间 总转发 总评论 二次转发 二次评论  转发占比 动作} 
    uids = open uid_url
    uids = uids.read
    uids = uids.strip.split("\n")
    uids = uids.uniq
    uids.each do |uid|
    uids.each{|uid|
      begin
        uid = uid
        account =  task.load_weibo_user(uid)
        evaluates = account.user_quality
        evaluate =0
        if !evaluates.nil?
          evaluate = evaluates.forward_average + evaluates.comment_average #用户的活跃度
        end
        commentcount = 0
        forward_weibo = WeiboForward.where("uid = ? and forward_uid = ? and forward_at between ? and ?",target_uid,uid,start_time,end_time)
        comment_weibo = WeiboComment.where("uid = ? and comment_uid = ? and comment_at between ? and ?",target_uid,uid,start_time,end_time)

       if !(comment_weibo.count ==0)
        comment_weibo.each do |comment|
          comment_at = comment.comment_at.strftime("%Y-%m-%d %H:%M:%S")
          comment_url = "http://weibo.com/#{comment.comment_uid}/#{WeiboMidUtil.mid_to_str(comment.comment_id.to_s)}"
          record=WeiboDetail.where("weibo_id = ?",comment.weibo_id).first         
          c=MWeiboContent.find(comment.weibo_id)
          srouce=''
          text=''
          if !c.nil?
            srouce=ActionView::Base.full_sanitizer.sanitize(c.source)
            text=c.text
          end
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
          origin=!record.origin
          post_at = record.post_at.strftime("%Y-%m-%d %H:%M:%S")
          begin
            f=task.stable{task.api.statuses.show(id:comment.comment_id)}
            freposts_count =f.reposts_count
            fcomments_count = f.comments_count
          rescue Exception=>e
             if e.message =~ / does not exists!/
               freposts_count =0
               fcomments_count = 0
             end
          end
          csv << account.to_row + [evaluate/100.0,record.url, post_at,text,type,comment_url, comment_at,record.reposts_count.to_s ,record.comments_count.to_s,freposts_count, fcomments_count, freposts_count.to_f/record.reposts_count.to_f,'评论']
         end
        end

     if !(forward_weibo.count == 0)  
        forward_weibo.each do |forward|
          forward_at=forward.forward_at.strftime("%Y-%m-%d %H:%M:%S")
          forward_url="http://weibo.com/#{forward.forward_uid}/#{WeiboMidUtil.mid_to_str(forward.forward_id.to_s)}"
          record=WeiboDetail.find_by_weibo_id(forward.weibo_id)
          c=MWeiboContent.find(forward.weibo_id)
          srouce=''
          text=''
          if !c.nil?
            srouce=ActionView::Base.full_sanitizer.sanitize(c.source)
            text=c.text
          end
          type=case 
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
          origin = !record.origin
          post_at = record.post_at.strftime("%Y-%m-%d %H:%M:%S")
          begin
            f = stable{api.statuses.show(id:forward.forward_id)}
            freposts_count =f.reposts_count
            fcomments_count = f.comments_count
          rescue Exception=>e
             if e.message =~ / does not exists!/
               freposts_count =0
               fcomments_count = 0
             end
          end
         csv << account.to_row + [evaluate/100.0,record.url, post_at,text,type,forward_url, forward_at,record.reposts_count.to_s ,record.comments_count.to_s,freposts_count, fcomments_count, freposts_count.to_f/record.reposts_count.to_f,'转发']
        end
      end
      rescue Exception =>e
        if e.message =~ /target weibo does not exists!/ #=~ 用于正则表达式匹配
           csv << [uid]
        end
      end
}
    end
  end
  #===============================================>根据微博名称导出uids
  filename = "uids_by_names.csv" #完美收关
  CSV.open filename,"wb" do |csv|
    csv << %w{昵称 UID}
    @uids = open '/home/rails/Desktop/name'#文件的路径
    @uids = @uids.read
    @uids = @uids.strip.split("\n")
    @uids.each do |name|
      weibo_account = WeiboAccount.find_by_screen_name(name)
      csv << [name,weibo_account.uid]
    end
  end

  #==============================================>微博互动
  
  filename = "接口提取关键词微博(keywords,time,sum).csv" #有待解决
  CSV.open filename,"wb" do |csv|
    csv << %w{UID 昵称 位置 性别 粉丝 关注 微博 注册时间 认证信息 认证原因 keyword 微博url 发布时间 内容 来源 转发数 评论数}
  end

  #=============================================>监控帐号微博列表(根据uids)
  filename = "监控帐号提取微博列表(根据uids).csv"
    @uids = [2295615873,2637370927,2637370247]
    @start_time = "2014-09-10"
    @end_time = "2014-09-15"
  CSV.open filename,"wb" do |csv|
    csv << %w{UID/昵称 内容 时间 转发 评论 URL 来源 类型 原创}
    @uids.each do |uid|
      @screen_name = WeiboAccount.find_by_uid(uid).screen_name #监控帐号昵称
      w_ds = WeiboDetail.where("uid = ? and post_at between ? and ?",uid,@start_time,@end_time)
      w_ds.each do |w_d|  
        @mwc = MWeiboContent.find(w_d.weibo_id) #得到微博的内容
        @text = @mwc.text
        @post_at = w_d.post_at.strftime("%Y-%m-%d %H:%M:%S")
        @forward_count = w_d.reposts_count
        @comment_count = w_d.comments_count
        @url = "http://weibo.com/"+uid.to_s+"/"+WeiboMidUtil.mid_to_str(w_d.weibo_id.to_s)#得到微博的url
        @srouce = ActionView::Base.full_sanitizer.sanitize(@mwc.source) #每条微博的来源
        
        #微博类型
        @type = case 
          when w_d.image? && w_d.video?
            "image + video"
          when w_d.image?
            "image"
          when w_d.video?
            "video"
          when w_d.music?
            "music"
          when w_d.vote?
            "vote"
          else
            "text"
        end

        #original 原创
        @original = !w_d.forward
        csv << [@screen_name,@text,@post_at,@forward_count,@comment_count,@url,@srouce,@type,@original]
      end
    end
  end

  #================================================>接口提取微博列表(根据uids)

  z_uid = 
  start_time = '2014-10-01'
  end_time = '2014-10-20'
  filename =  '接口提取微博列表.csv'
   task = GetUserTagsTask.new
      csv << %w{name 微博内容 发布时间 转发数 评论数 互动总数 URL 原创 发布来源  }
        puts "Processing uid : #{z_uid}"
        top_id = nil
        task.paginate(:per_page=>100) do |page|
          begin
            res = task.stable{task.api.statuses.user_timeline(uid:z_uid,count:100, page:page)}
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
                rows << [w.user.screen_name, w.text,post_at, w.reposts_count, w.comments_count,scount, url,origin, srouce]
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
  
#==================================================> 微博互动信息(根据url) 

  filename = "微博互动信息(根据urls).csv"
  CSV.open filename,"wb" do |csv|
    csv << %w{url 内容 转发数 评论数 互动数 互动人数 发布时间 是否原创 uid 发布账号昵称 粉丝数 类型 来源}
    @url = open '/home/rails/Desktop/url'#文件的路径
    @url = @url.read
    @url = @url.strip.split("\n")
    @url.each do |url|
      @weibo_id = WeiboMidUtil.str_to_mid(url.split("/").last) #得到这些url的weibo_id,注:要把weibo_id转换成整形的
      #得到微博对象
      mwc = MWeiboContent.find_by_id(@weibo_id.to_i)
      #微博详细信息对象
      w_d = WeiboDetail.find_by_weibo_id(@weibo_id.to_i)
      @uid = w_d.uid
      #微博用户
      w_a = WeiboAccount.find_by_uid(@uid)
      @text = mwc.text #得到微博的内容
      @forward_num = w_d.reposts_count #转发数量
      @comment_num = w_d.comments_count #评论数量
      #互动量
      @sum = w_d.reposts_count+w_d.comments_count
      
      comment_uids = []
      forward_uids = []
      hudong_uids = []
      @num = 0
      #评论的uid
      comments = WeiboComment.where("weibo_id = ?",@weibo_id.to_i)
      comments.each do |comment|
        comment_uids << comment.comment_uid
      end
      #转发的uid
      forwards = WeiboForward.where("weibo_id = ?",@weibo_id.to_i)
      forwards.each do |forward|
        forward_uids << forward.forward_uid
      end
      hudong_uids = comment_uids + forward_uids
      #每条微博的互动人数
      @num = hudong_uids.uniq.size
      @post_at = w_d.post_at.strftime("%Y-%m-%d %H:%M:%S") #发布日期
      @original = !w_d.forward ? '是' :'否' #是否原创
      @screen_name = w_a.screen_name #昵称
      #从接口当中提取粉丝数
      res = task.stable{task.api.statuses.show(id:weibo_id)}
      @follows = res.user.followers_count 
      @srouce = ActionView::Base.full_sanitizer.sanitize(mwc.source) #每条微博的来源
      @type_name = w_a.human_verified_type #认证类型(数组格式)
      @name_str = "" #  存放认证类型
      #将认证类型的这个数组循环遍历  
      @type_name.each do |name|
        @name_str += name + ","
      end
       @name_str = @name_str[0,@name_str.length-1]
      csv << [url,@text,@forward_num,@comment_num,@sum,@num,@post_at,@original,@uid,@screen_name,@follows,@name_str,@srouce]  
    end
  end

  #==================================================>>互动人信息(是监控帐号的直接从库里边儿取值)
  #后悔无期并不是监控帐号
  filename = "后悔无期(互动人列表).csv" #根据一些微博的url 只能从接口现抓(库里边儿只是监控的帐号) 有问题待解决
  CSV.open filename,"wb" do |csv|
    csv << %w{UID 昵称 位置 性别 粉丝 关注 微博 注册时间 认证信息 认证原因 备注}
    comment_uids = []
    forward_uids = []
    @hudong_uids = []
    @url = open '/home/rails/Desktop/hhwq-url'#文件的路径
    @url = @url.read
    @url = @url.strip.split("\n")
    @url.each do |url|
      @weibo_id = WeiboMidUtil.str_to_mid(url.split("/").last).to_i #得到这些url的weibo_id,注:要把weibo_id转换成整形的
      comments = WeiboComment.where("weibo_id = ?",@weibo_id)
      comments.each do |comment|
        comment_uids << comment.comment_uid
      end
      #转发的uid
      forwards = WeiboForward.where("weibo_id = ?",@weibo_id)
      forwards.each do |forward|
        forward_uids << forward.forward_uid
      end
      @hudong_uids = comment_uids + forward_uids
      @hudong_uids = @hudong_uids.uniq
        @hudong_uids.each do |uid|
          
          #res = task.stable{task.api.users.show(uid:uid)}
        
          weibo_account = WeiboAccount.where("uid = ?",uid)
          if !weibo_account.blank?
            screen_name = weibo_account[0].screen_name #昵称
            location = weibo_account[0].location #位置
            #weibo_account[0].gender == 0 ? @sex = "女" : @sex = "男"
            @sex = weibo_account[0].human_gender
            followers_count = weibo_account[0].followers_count #粉丝
            friends_count = weibo_account[0].friends_count #关注
            statuses_count = weibo_account[0].statuses_count #微博数量
            created_at = weibo_account[0].created_at.strftime("%Y-%m-%d %H:%M:%S") #用户创建(注册)时间
            #调用认证类型的方法(不用传递任何参数,它可以根据调用的这个方法的对象去导出认证类型)
            @type_name = weibo_account[0].human_verified_type
            @name_str = "" #存放认证类型
            #将认证类型的这个数组循环遍历  
            @type_name.each do |name|
              @name_str += name+","
            end
             @name_str = @name_str[0,@name_str.length-1]
          end
          #time = DateTime.parse(res.status.created_at).strftime("%Y-%m-%d %H:%S")
          muser = MUser.find_by_id(uid.to_i) #这块儿要注意了,必须要把uid转换成整形的
          if !muser.blank?
             csv << [uid,screen_name,location,@sex,followers_count,friends_count,statuses_count,created_at,@type_name,nil,muser.description]
        end
      end
    end
  end

  #==================================================>>互动人信息(不是监控帐号的要从接口当中取值)

  filename = "互动人信息.csv"
  CSV.open filename,"wb" do |csv|
    task = GetUserTagsTask.new
    csv << %w{UID 昵称 位置 性别 粉丝 关注 微博 注册时间 认证信息 认证原因 备注}
    @url = open '/home/rails/Desktop/urls'#文件的路径
    @url = @url.read
    @url = @url.strip.split("\n")
    @url.each do |url|
      url = url.strip
      weibo_id = WeiboMidUtil.str_to_mid(url.split("/").last).to_i #得到微博帐号
      res = task.stable{task.api.comments.show(weibo_id)}
      if !res.blank?
        if !res.reposts.blank?
          res.reposts.each do |forward|
            if !forward.blank?
              #csv << %w{UID 昵称 位置 性别 粉丝 关注 微博 注册时间 认证信息 认证原因 备注}
              uid = forward.user.id #用户帐号
              screen_name = forward.user.screen_name #用户昵称
              location = forward.user.location #用户位置
              sex = forward.user.gender == 0 ? '男' : '女' #性别
              followers_count = forward.user.followers_count #用户粉丝数量
              friends_count = forward.user.friends_count #用户关注量
              statuses_count = forward.user.statuses_count #此用户的微博数量
              created_at = forward.user.created_at #用户的注册时间
              #用户的认证信息
              @type_name = forward.user.human_verified_type
                @name_str = "" #存放认证类型
                #将认证类型的这个数组循环遍历  
                @type_name.each do |name|
                  @name_str += name+","
                end
                 @name_str = @name_str[0,@name_str.length-1]
              muser = MUser.find_by_id(uid.to_i) #这块儿要注意了,必须要把uid转换成整形的
              if !muser.blank?
                 csv << [uid,screen_name,location,@sex,followers_count,friends_count,statuses_count,created_at,@type_name,nil,muser.description]
            end
          end
        end
      end
      if !res.blank?
        if !res.comments.blank?
          res.comments.each do |comment|
            if !comment.blank?
              #csv << %w{UID 昵称 位置 性别 粉丝 关注 微博 注册时间 认证信息 认证原因 备注}
              uid = comment.user.id #用户帐号
              screen_name = comment.user.screen_name #用户昵称
              location = comment.user.location #用户位置
              sex = comment.user.gender == 0 ? '男' : '女' #性别
              followers_count = comment.user.followers_count #用户粉丝数量
              friends_count = comment.user.friends_count #用户关注量
              statuses_count = comment.user.statuses_count #此用户的微博数量
              created_at = comment.user.created_at #用户的注册时间
              #用户的认证信息
              @type_name = comment.user.human_verified_type
              @name_str = "" #存放认证类型
                #将认证类型的这个数组循环遍历  
              @type_name.each do |name|
                @name_str += name+","
              end
              @name_str = @name_str[0,@name_str.length-1]

              muser = MUser.find_by_id(uid.to_i) #这块儿要注意了,必须要把uid转换成整形的
              if !muser.blank?
                 csv << [uid,creen_name,location,@sex,followers_count,friends_count,statuses_count,created_at,@type_name,nil,muser.description]
            end
          end
        end
      end
    end
  end
 end
end

  #===========================================>>监控帐号微博互动内容列表(根据urls)
  
  filename = "监控帐号微博互动内容列表(根据urls).csv" #一条微博的互动人信息
  CSV.open filename,"wb" do |csv|
    task = GetUserTagsTask.new # 一些数据是要走接口才能提取出来的
    csv << WeiboAccount.to_row_title(:full) + %w{内容 互动时间 互动微博连接 动作}
    @url = open '/home/rails/Desktop/url'#文件的路径
    @url = @url.read
    @url = @url.strip.split("\n")
    @url.each do |line|
      url = line.strip #清除可能存在的空格
      weibo_id = WeiboMidUtil.str_to_mid(url.split("/").last).to_i #得到微博的id

      forwards = WeiboForward.where("weibo_id = ?",weibo_id)
      comments = WeiboComment.where("weibo_id = ?",weibo_id)

      # 转发
      if !forwards.blank?
        forwards.each do |forward|
          #得到一个用户信息对象
          account = task.load_weibo_user(forward.forward_uid.to_s)
          forward_text = MForward.find_by_id(forward.forward_id)
          #发布时间这块儿要判断一下转发或者评论是否为空
          forward.blank? ? forwardat = '' : forwardat = forward.forward_at.strftime("%Y-%m-%d %H:%M:%S")
          forward_url = "http://weibo.com/#{forward.uid}/"
          csv << account.to_row(:full) + [forward_text,forwardat,forward_url,'转发']
        end
      end
    
      # 评论
      if !comments.blank?
        comments.each do |comment|
          #得到一个用户信息对象
          account = task.load_weibo_user(comment.comment_uid.to_s)
          comment_text = MComment.find_by_id(comment.comment_id)
          #发布时间这块儿要判断一下转发或者评论是否为空
          comment.blank? ? commentat = '' : commentat = comment.comment_at.strftime("%Y-%m-%d %H:%M:%S")
          comment_url = "http://weibo.com/#{comment.uid}/"
          csv << account.to_row(:full) + [comment_text,commentat,comment_url,'评论']
        end
      end

    end
  end


  #===========================================>>接口提取微博互动内容列表(根据urls)
  filename = "Sumsung提取微博互动内容列表有效性分析BnHbtso6g最新3.csv"
  CSV.open filename,"wb" do |csv|
    task = GetUserTagsTask.new
    csv << %w{uid 内容 正负面 无效内容 互动时间 互动微博连接 动作}
      #@url = open '/home/rails/Desktop/urls'#文件的路径
      #@url = @url.read
      #@url = @url.strip.split("\n")
      url = 'http://weibo.com/2031482343/BnHbtso6g'
      url = url.strip
      #http://weibo.com/2031482343/BnJGcBDOC
      #http://weibo.com/2031482343/BnHbtso6g
        page = 1
        while true
          weibo_id = WeiboMidUtil.str_to_mid URI.parse(url).path.split("/").last #得到微博的帐号
          #转发
          res = task.stable{task.api.statuses.repost_timeline(weibo_id.to_s,page:page,count:20)} #得到微博记录
          if !res.blank?
            break if res.reposts.blank?
            #if !res.reposts.blank?
              res.reposts.each do |line|
                #互动微博连接
                url = "http://weibo.com/#{line.retweeted_status.user.id}/#{WeiboMidUtil.mid_to_str(line.retweeted_status.id.to_s)}"
                content = line.text
                #正负面
                te = TextEvaluate.new 
                eva,eva_word = te.evaluate(content)
                #微博无效内容
                fake_content = line.text == "转发微博" || line.text.gsub(/\[[^\]]+\]/,"").blank?
                csv << [line.user.id,content,eva,fake_content, DateTime.parse(line.created_at).strftime("%Y-%m-%d %H:%S"),url,'转发']
              end
            page+=1
            end
        end
          #评论
        page = 1
        while true
          res = task.stable{task.api.comments.show(weibo_id.to_s,page:page,count:20)} #得到微博记录
          if !res.blank?
            break if res.comments.blank?
            #if !res.comments.blank?
              res.comments.each do |line|
                #互动微博连接
                url = "http://weibo.com/#{line.status.user.id}/#{WeiboMidUtil.mid_to_str(line.status.id.to_s)}"
                #正负面
                content = line.text
                te = TextEvaluate.new 
                eva,eva_word = te.evaluate(content)
                #微博无效内容
                fake_content = line.text == "转发微博" || line.text.gsub(/\[[^\]]+\]/,"").blank?
                csv << [line.user.id,content,eva,fake_content, DateTime.parse(line.created_at).strftime("%Y-%m-%d %H:%S"),url,'评论']
              end
            page+=1    
            end
          end
  end

  #====================================>>查看一些人与特定主号的互动(根据uid主号,和uids)

  filename = "查看一些人与监控帐号互动.csv"
  CSV.open filename,"wb" do |csv|
    rows << %w{uid 转发主号次数 评论主号次数 互动}
    uid = "2637370927"
    @uids = open '/home/rails/Desktop/uids'#文件的路径
    @uids = @uids.read
    @uids = @uids.strip.split("\n")
    @uids.each do |uid|
      uid = line.strip
      forwards = WeiboForward.where("uid = ? and forward_uid = ?",target_uid,uid).count
      comments = WeiboComment.where("uid = ? and comment_uid = ?",target_uid,uid).count      
      rows << [uid,forwards,comments,forwards+comments]
  end

  #=====================================>> 根据uid,uids,starttime,endtime求出转发数,评论数,互动数
  
  filename = "查看一些人与监控帐号互动.csv"
  CSV.open filename,"wb" do |csv|
    csv << %w{uid 转发主号次数 评论主号次数 互动}
    target_uid = "2637370927"
    starttime = "2014-09-01"
    endtime = "2014-09-29"
    $uids.each do |uid|
      uid = uid.strip
      forwards = WeiboForward.where("uid = ? and forward_uid = ? and forward_at between ? and ?",target_uid,uid,starttime,endtime).count
      comments = WeiboComment.where("uid = ? and comment_uid = ? and comment_at between ? and ?",target_uid,uid,starttime,endtime).count      
      csv << [uid,forwards,comments,forwards+comments]
    end
  end

  #=======================================>> 根据url导出微博的暴光亮

  filename = "根据url导出微博的暴光亮.csv"
  task = GetUserTagsTask.new
  CSV.open filename,"wb" do |csv|
    csv << %w{URL 暴光量}
    urls = open open '/home/rails/Desktop/urls'
    urls = urls.read
    urls = urls.strip.split("\n")
      urls.each do |url|
        @compare_uids = {}
        number  = 0
        weibo_id = WeiboMidUtil.str_to_mid URI.parse(url).path.split("/").last
        page = 1
        processing = true
          begin
            begin
              res = task.stable{task.api.statuses.repost_timeline(weibo_id.to_s,count:200,page:page)}#根据weibo_id查转发人信息count  
                if !res.blank?        
                   res.reposts.each do |line| 
                     row = [] 
                    if line.nil?
                       processing = false
                       break
                    end
                    @compare_uids[line.user.id.to_s] ||= [1,{'uid' =>line.user.id,'followers_count' =>line.user.followers_count}]
                   !@compare_uids[line.user.id.to_s].nil? if @compare_uids[line.user.id.to_s][0] +=1
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
                   @compare_uids[line.user.id.to_s] ||= [1,{'uid' =>line.user.id,'followers_count' =>line.user.followers_count}]
                   !@compare_uids[line.user.id.to_s].nil? if @compare_uids[line.user.id.to_s][0] +=1
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
         @compare_uids.keys.each do |uid|
            number += @compare_uids[uid][1]['followers_count']
         end  
        csv << [url,number]  
        end
      end

  #=========================================>> 粉丝块儿(监控帐号粉丝列表(根据uids))
  
  filename = "监控帐号粉丝列表.csv" #根据UID列表 导出粉丝 详情列表
  CSV.open filename,"wb" do |csv|
  task = GetUserTagsTask.new
  
    csv << WeiboAccount.to_row_title(:quality) + %w{关注时间 与主号互动次数}
        uid = 2637370927
        start_time = '2014-09-10'
        end_time = '2014-09-25'
        count = 0
        m = MonitWeiboAccount.find_by_uid(uid)
        relations = WeiboUserRelation.where("uid = ? and follow_time between ? and ?",uid,start_time,end_time)
        if !relations.blank?
          relations.each do |rel|
             if !rel.by_uid.blank?
              begin
                a = task.load_weibo_user(rel.by_uid)
                rescue Exception=>e
                  if e.message =~ / does not exists!/
                    csv << [uid]
                  next
                 if !a.blank?
                    forwards = WeiboForward.where("uid = ? and forward_uid=?",uid,rel.by_uid).count
                    comments = WeiboComment.where("uid = ? and comment_uid=?",uid,rel.by_uid).count
                    row = a.to_row(:quality)
                    row.unshift m.screen_name
                    follow_time = rel.follow_time ? rel.follow_time.strftime("%Y-%m-%d %H:%M") : nil
                    row << follow_time
                    row << forwards + comments
                    csv << row
                    count += 1
                end
            end
          end
        end
    end  
  end 

  #==================================>>接口提取粉丝列表(根据接口提取)
  
  filename = "后会无期马达加斯加粉丝列表.csv" #接口提取主号的前2000粉丝
  task = GetUserTagsTask.new
  CSV.open filename,"wb" do |csv|
    csv << ['主号uid']+ WeiboAccount.to_row_title(:full)
    begin
      z_uid = 3030975747 #intel主号
      friend_ids = task.stable{task.api.friendships.followers_ids(:uid=>z_uid, :count=>5000).ids} #2000个粉丝的uid
      rescue Exception=>e
        puts 'error:类'
        if e.message =~ / for this time/
          sleep(300)
        end
          rows << [z_uid]
        next
      end
      friend_ids.each do |uid|
        begin
          account = task.load_weibo_user(uid)
          rescue Exception=>e
            if e.message =~ / for this time/
              sleep(300)
            end
            csv << [z_uid,uid]
            next
          end
          next if account.blank?
          csv << [z_uid]+ account.to_row(:full)
        end
  end 

  #============================================>>判断一批人是否关注主号

  filename = "这些人是否关注主号(问题).csv"
  CSV.open filename,"wb" do |csv|
    csv << %w{uid 之前粉主号时间 之前是否是粉丝（Y/N） 现在是否是主号粉丝（Y/N） 主号是否关注他（Y/N）}
    z_uid = 2637370927
    task = GetUserTagsTask.new
    uids = open '/home/rails/Desktop/ceshi'#文件的路径
    uids = uids.read
    uids = uids.strip.split("\n")
    uids.each{|uid|
        uid = uid.strip
        fans = WeiboUserRelation.where("uid = ? and by_uid = ?",z_uid,uid).first
        begin
          res = task.api.friendships.show(source_id:uid,target_id:z_uid)
          issourcefans = res.source.followed_by ? "Y" : "N"
          istargetfans = res.source.following ? "Y" : "N"
          if fans.blank?
           csv << [uid,'',"N",istargetfans, issourcefans ]
          else
           followedtime = fans.follow_time.to_s
           isfans = fans.nil?? "N" :"Y"
           csv << [uid,followedtime,isfans,istargetfans, issourcefans]
          end
          rescue Exception=>e
          puts e
          csv << [uid,'','','','']
        end
    }
  end

  #================================>> 判断一批人是否关注一些主号
  
  filename = "判断一批人是否关注一些主号.csv"
  CSV.open filename,"wb" do |csv|
    task = GetUserTagsTask.new
    target_uids = [2637370247,2637370927,3318508000] #主号uids
    source_uids = open open '/home/rails/Desktop/uids'
    source_uids = source_uids.read
    source_uids = source_uids.strip.split("\n")
    row = []
    row << "uid"
    target_uids.each do |id|
      begin
        name = task.load_weibo_user(id).screen_name
      rescue Exception=>e
        row << "" 
        next 
      end
      row << "现在是否是#{name}"
    end
    csv << row
    source_uids.each{|uid|
      uid = uid
      row2 = []
      row2 << uid
      begin
        ids = task.api.friendships.friends_ids(uid:uid,count:5000).ids
      rescue Exception=>e
          row2 << ""
          if e.message =~ / for this time/
            sleep(300)
          end
          next
     end
     target_uids.each do |id|
        istargetfans = ids.include?(id.to_i) ? "Y" : "N"
        row2 << istargetfans
     end
     csv << row2
    }
    end
  end

  #==========================================>>其他
  
  filename = "time之前(商用频道)互动次数.csv" #可以是其它的主号 kol类(统计kol类的互动用户的互动次数)
  CSV.open filename,"wb" do |csv|
    csv << %w{zero 1-5次 5-10次 10-20次 20以上}
    zero = 0
    one = 0
    two = 0
    three = 0
    four = 0
    date = '2014-08-08'
    #关联的用户
    kols = WeiboUserAttribute.find_by_sql <<-EOF
            select  uid uid  from weibo_user_attributes where  keyword_id = 85 or keyword_id= 86 or keyword_id = 88 or keyword_id = 90    or      keyword_id = 91  or keyword_id = 92
EOF
    kols.each do |line|
      uid = line.uid  
      forwards = WeiboForward.where("uid = ? and forward_uid = ? and forward_at <= ? ",2295615873,uid,date)
      comments = WeiboComment.where("uid = ? and comment_uid = ? and comment_at <= ? ",2295615873,uid,date)
      if (forwards.count + comments.count) == 0
        zero += 1
        end
        if (forwards.count + comments.count) >0 &&  (forwards.count + comments.count) <=5
           one += 1
        end
        if (forwards.count + comments.count) >5 &&  (forwards.count + comments.count) <=10
          two +=1
        end
        if (forwards.count + comments.count) >10 &&  (forwards.count + comments.count) <=20
           three +=1
        end
        if (forwards.count + comments.count) >20
         four +=1
        end
    end
    csv << [zero,one,two,three,four]  
  end

  #==============================>> 商用频道ITDM,KOL互动列表(根据keyword_id) 关键词的id

  filename = "商用频道ITDM,KOL互动列表(根据keyword_id).csv"
  CSV.open filename,"wb" do |csv|
    start_time = '2014-09-01'
    end_time = '2014-09-24'
    keyword_ids = [77,85,86,88,90,91,92]
    target = 2295615873 #英特尔商用频道
    csv = WeiboAccount.to_row_title + %w{互动 互动时间 互动内容 二次转发}
    WeiboUserAttribute.where("weibo_user_attributes.keyword_id in (?)", keyword_ids).all.each{|wua|
      wa = WeiboAccount.find_by_uid(wua.uid) #可能有重复的用户
      next if wa.nil?
      row = wa.to_row
      WeiboForward.where(uid:target,forward_uid:wa.uid).where("forward_at between ? and ?",start_time, end_time).each{|f|
        mf = MForward.find(f.forward_id)
        row = row.clone
        if mf
          row << "转发"
          row << f.forward_at.strftime("%Y-%m-%d %H:%M")
          row << mf.text
          row << mf.reposts_count
          csv << row
        end
      }
      WeiboComment.where(uid:target,comment_uid:wa.uid).where("comment_at between ? and ?",start_time, end_time).each{|f|
        mf = MComment.find(f.comment_id)
        row = row.clone
        if mf
          row << "评论"
          row << f.comment_at.strftime("%Y-%m-%d %H:%M")
          row << mf.text
          csv << row
        end
      }
    }
  end

  #统计三个数组每个元素出现的次数
  filename = "统计.csv"
  CSV.open filename,"wb" do |csv|
    csv << %w{UID 次数 数量}

    hyzys = open open '/home/rails/Desktop/hyzy'
    hyzys = hyzys.read
    hyzys = hyzys.strip.split("\n")
    hyzys = hyzys.uniq

    qtlqs = open open '/home/rails/Desktop/qtlq'
    qtlqs = qtlqs.read
    qtlqs = qtlqs.strip.split("\n")
    qtlqs = qtlqs.uniq

    hhwqs = open open '/home/rails/Desktop/hhwq'
    hhwqs = hhwqs.read
    hhwqs = hhwqs.strip.split("\n")
    hhwqs = hhwqs.uniq

    zongs = []
    zongs = hyzys+qtlqs+hhwqs
    zongs = zongs.uniq

    times = 0
    zongs.each do |a|
      if hyzys.include?(a.to_s) ||  qtlqs.include?(a.to_s) || hhwqs.include?(a.to_s)
        times = 1
        if hyzys.include?(a.to_s) && qtlqs.include?(a.to_s) || qtlqs.include?(a.to_s) && hhwqs.include?(a.to_s) || hhwqs.include?(a.to_s) && hyzys.include?(a.to_s)
          times = 2
          if hyzys.include?(a.to_s) && qtlqs.include?(a.to_s) && hhwqs.include?(a.to_s)
            times = 3
          end
        end
      end
    csv << [a,times,zongs.s]
    end 
  end
  

  

