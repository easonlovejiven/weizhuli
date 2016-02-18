  name ="芯品汇"
  filename = "#{name}前3000粉丝信息.csv"
  CSV.open filename,"wb" do |csv|
    task = GetUserTagsTask.new
    csv << WeiboAccount.to_row_title(:full) + %w{平均转发率 平均评论率 平均转发 平均评论 活跃度 原创占比 日均发帖量 近七天发贴量 关注时间}
    uids = [972897,14387396,33753503]
    #uids = open "xph-uid"
    #uids = uids.read
    #uids = uids.strip.split("\n")
    uids.each do|uid|
      begin
       #res = task.stable{task.api.users.show(uid:uid)} #用于提取最后一条微博时间
       
         row = []
         account = task.load_weibo_user(uid)
         weiboEvaluates = WeiboUserEvaluate.where("uid = ?",uid).first
         if weiboEvaluates.nil? || weiboEvaluates.origin_rate == -1
            weiboEvaluates= WeiboAccount.find_by_uid(uid).update_evaluates #更新一下用户的活跃度信息
         end
         evaluates =   weiboEvaluates.forward_average + weiboEvaluates.comment_average
         row << weiboEvaluates.forward_rate/100.0
         row << weiboEvaluates.forward_rate/100.0
         row << weiboEvaluates.forward_average/100.0
         row << weiboEvaluates.comment_average/100.0
         row << evaluates/100.0
         row << weiboEvaluates.origin_rate
         row << weiboEvaluates.day_posts
         row << weiboEvaluates.day_posts_in_week
         
         #取出关注时间
         #z_uid = 2637370927
         #wur = WeiboUserRelation.where("uid = ? and by_uid = ?",z_uid,uid)
         #follow_time = wur[0].follow_time.strftime("%Y-%m-%d %H:%M:%S")
         #row << follow_time
         #最后一条微薄时间
         
         if !account.blank?
          csv << account.to_row(:full) + row
          elsif #这个帐号可能是库里边儿没有的
            csv << [uid,'找不到信息']
         end
      rescue Exception=>e
            if e.message =~ /User does not exists!/
              csv << [uid,"此用户不存在"]
            next
          end
        end
      end
    end
    
