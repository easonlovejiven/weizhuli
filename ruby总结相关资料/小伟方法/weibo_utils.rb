9号到17号。和我们的互动情况
#通过url 转换成 weibo_id
weibo_ids = urls.map{|url| WeiboMidUtil.str_to_mid url.split("/").last}
#根据url类型 位置（范范）微博类型
filename = "微博类型.csv"
  CSV.open filename,"wb" do |csv|
    csv << %w{url 类型 位置}
    path = File.join(Rails.root,"db/url1")#从file拿weibo_id
      File.open(path,"r").each do|url|
      url = url.strip
      weibo_id = WeiboMidUtil.str_to_mid url.split("/").last
      debugger
      category = Post.find_by_weibo_id(weibo_id)
       if category.nil?
          csv << [weibo_id]
          next
        end
       csv << [weibo_id,category.category,category.geo]
    end
  end

filename = "微博类型.csv"
  CSV.open filename,"wb" do |csv|
    csv << %w{url 位置   }
    path = File.join(Rails.root,"db/url1")#从file拿weibo_id
      File.open(path,"r").each do|url|
      url = url.strip
      weibo_id = WeiboMidUtil.str_to_mid url.split("/").last
      category = Post.find_by_weibo_id(weibo_id)
       if category.nil?
          csv << [url]
          next
        end
       csv << [url,category.geo,category.tag1,category.tag2,category.tag3,category.tag4]
    end
  end
#通过 mysql  查询出 导出 内容  ITDM
filename  = "data/intel_fans_location.csv"
CSV.open(filename,"wb") do|csv|
      csv << %w{地域 总数 }
   records = WeiboUserRelation.find_by_sql <<-EOF
   select wa.location location, count(1) count from weibo_user_relations wur left join weibo_accounts wa on wur.by_uid = wa.uid where wur.uid  = '2637370927' group by wa.location
EOF
  records.each do |record|
    csv << [record.location,record.count]
 end
end
#根据粉丝人查活跃度》=1 微博 》50 人信息(张桢)
filename  = "data/intel_fans_list.csv"
task = GetUserTagsTask.new
CSV.open(filename,"wb") do|csv|
      csv << WeiboAccount.to_row_title(:full)
   records = WeiboUserRelation.find_by_sql <<-EOF
   SELECT  wur.by_uid FROM  weibo_user_relations  wur  LEFT JOIN weibo_accounts wa  ON wur.by_uid = wa.uid LEFT JOIN weibo_user_evaluates wue on wue.uid = wur.by_uid  WHERE wur.uid =  2637370927 and wa.statuses_count  >= 50 and (wue.forward_rate+wue.comment_average)/100.0 >= 1
EOF
  records.each do |record|
    uid = record.by_uid
    begin
    account = task.load_weibo_user uid
    rescue Exception =>e
      if e.message =~ /User does not exists!/
         csv << [uid]
          next
       end
     end
    csv << account.to_row(:full)
 end
end
records = WeiboUserRelation.find_by_sql <<-EOF
   SELECT  wur.by_uid FROM  weibo_user_relations  wur  LEFT JOIN weibo_accounts wa  ON wur.by_uid = wa.uid LEFT JOIN weibo_user_evaluates wue on wue.uid = wur.by_uid  WHERE wur.uid =  2637370927 and wa.statuses_count  >= 50 and (wue.forward_rate+wue.comment_average)/100.0 >= 1 limit 10
EOF
SELECT  count(1) FROM  weibo_user_relations  wur  LEFT JOIN weibo_accounts wa  ON wur.by_uid = wa.uid LEFT JOIN weibo_user_evaluates wue on wue.uid = wur.by_uid  WHERE wur.uid =  2637370927 and wa.statuses_count  >= 50 and (wue.forward_rate+wue.comment_average)/100.0 >= 1 ;

#从文件读uid 查看是否是 关注 一个 主号
filename  = "data/intel_isfans-1.csv"
CSV.open(filename,"wb") do|csv|
      csv << %w{uid 是否是英特尔商用频道粉丝 }
path = File.join(Rails.root,"db/uid")
           intel = '2637370927'

        File.open(path,"r").each do|uid|
          uid << uid.strip
         fans = WeiboUserRelation.where("uid = ? and by_uid = ?",intel,uid)
         isfans = fans.blank? ? '不是' : '是'
         csv << [uid,isfans,fans.first.follow_time]

end
end
#根据name提粉丝信息
 filename  = "data/fans.csv"
CSV.open(filename,"wb") do|csv|
      csv << %w{name uid 粉丝数 }
path = File.join(Rails.root,"db/name3")

        File.open(path,"r").each do|name|
           puts name
          name = name.strip
         fans = WeiboAccount.where("screen_name = ?",name).first

         csv << [name,fans.uid,fans.friends_count]

end
end
#通过名字提取微薄列表  并每条微博加上发微博人与英特尔中国互动次数 加从接口 #1193305621  水
           path = File.join(Rails.root,"db/name")
           intel = '2637370927'
           start_time = Time.new(2013,9,13)
           end_time = Time.new(2013,9,16)
           filename  = "data/IansWorld-20130913-20130915.csv"
          names = []
        File.open(path,"r").each do|name|
          names << name.strip
            end
            uids = ReportUtils.names_to_uids(names)
            return if uids.blank?
           #ReportUtils.export_weibo_list_to_csv_by_name_for_Interface(
           # names,
          #"data/75_weibo_list_0912.csv",Time.new(2013,9,10),Time.new(2013,9,12)
          task = GetUserTagsTask.new
        CSV.open(filename,"wb"){|csv|
          csv << %w{name  原创 微博内容 发布时间 转发数 评论数 URL 发布来源 微博类型 与英特尔中国转发	 与英特尔中国评论 } #
        uids.each{|uid|
                 forwards = WeiboForward.where("uid = ? and forward_uid = ?",intel,uid).where("forward_at between ?     and ?",start_time,end_time).count
                  comments = WeiboComment.where("uid = ? and comment_uid = ?",intel,uid).where("comment_at between ? and ?",start_time,end_time).count
          puts "Processing uid : #{uid}"
          top_id = nil
        task.paginate(:per_page=>100) do |page|
          begin
              res = task.stable{task.api.statuses.user_timeline(uid:uid,count:100, page:page)}# tast.api 连接 接口 ，statuses.user_timeline连接  这个表， uid 要 查的uid  ，count一页显示多少 个 ， page，第几页
              res2 = task.stable{task.api.statuses.user_timeline(uid:uid,count:100, page:page,feature:2)}['statuses'].map(&:id)
              res3 = task.stable{task.api.statuses.user_timeline(uid:uid,count:100, page:page,feature:3)}['statuses'].map(&:id)
              res4 = task.stable{task.api.statuses.user_timeline(uid:uid,count:100, page:page,feature:4)}['statuses'].map(&:id)
              if page == 1
              if Time.parse(res['statuses'][0].created_at)< Time.parse(res['statuses'][1].created_at)
              top_id = res['statuses'][0].id
              end
              end
              processing = true
              res['statuses'].each{|w|
              next if w.id == top_id
              next if end_time && Time.parse(w.created_at) > end_time && start_time < Time.parse(w.created_at)
              if Time.parse(w.created_at) > start_time
                srouce = ActionView::Base.full_sanitizer.sanitize(w.source)
                url = "http://weibo.com/#{uid}/#{WeiboMidUtil.mid_to_str(w.id.to_s)}"
                origin = !w.retweeted_status#是否是原创
                types = []
                types << 'image' if res2.include?(w.id)
                types << 'video' if res3.include?(w.id)
                types << 'music' if res4.include?(w.id) # types*","
                types << 'text'  if types.blank?
                post_at = Time.parse(w.created_at).strftime("%Y-%m-%d %H:%M") #时间格式设置
                csv << [w.user.screen_name,origin,w.text,post_at, w.reposts_count, w.comments_count, url,types*",",srouce,forwards,comments]
              else
                processing = false
                break
              end
            }
            processing ? res.total_number : 0
          rescue Exception=>e
            puts e.message
          end
        end
      }
    } && nil
  #75人 从接口 通过名字提取 从接口查出，昵称 地域	 粉丝数	 互动率 	评论中国次数 	转发中国次数	 总互动次数 	自己微博被转发次数	 自己微博被评论次数	 自己微博总互动次数）  9.10-9.22 是否
   path = File.join(Rails.root,"db/name0")
           intel = '2637370927'
           start_time = Time.new(2013,9,9)
           end_time = Time.new(2013,10,7)
           filename  = "75_互动-20130909-20131006.csv"
          names = []
        File.open(path,"r").each do|name|
          names << name.strip
            end
            uids = ReportUtils.names_to_uids(names,true)
            return if uids.blank?
          task = GetUserTagsTask.new
        CSV.open(filename,"wb"){|csv|
          csv << %w{昵称 地域	 粉丝数	 互动率 	评论中国次数 	转发中国次数	 总互动次数 	自己微博被转发次数	 自己微博被评论次数	 自己微博总互动次数
 }
        uids.each{|uid|
           myforwards = 0
           mycomments = 0
           weibo_count = 0
                  forwards = WeiboForward.where("uid = ? and forward_uid = ?",intel,uid).where("forward_at between ?     and ?",start_time,end_time).count
                  comments = WeiboComment.where("uid = ? and comment_uid = ?",intel,uid).where("comment_at between ? and ?",start_time,end_time).count
          puts "Processing uid : #{uid}"
         top_id = nil
        task.paginate(:per_page=>100) do |page|
          begin
              res = task.stable{task.api.statuses.user_timeline(uid:uid,count:100, page:page)}# tast.api 连接 接口 ，statuses.user_timeline连接  这个表， uid 要 查的uid  ，count一页显示多少 个 ， page，第几页
               if page == 1
              if Time.parse(res['statuses'][0].created_at)< Time.parse(res['statuses'][1].created_at)
              top_id = res['statuses'][0].id
              end
              end
              processing = true
              res['statuses'].each{|w|
              next if w.id == top_id
              next if end_time && Time.parse(w.created_at) > end_time
              if Time.parse(w.created_at) > start_time
                weibo_count = weibo_count+1
                myforwards = w.reposts_count
                mycomments = w.comments_count
                puts weibo_count
              else
                processing = false
                break
              end
            }
            processing ? res.total_number : 0
          rescue Exception=>e
          end
        end
          weibo = WeiboAccount.find_by_uid(uid)
          WeiboAccount.find_by_uid(uid).update_evaluates

          weiboEvaluates = WeiboUserEvaluate.select('forward_average,comment_average ').where("uid = ?",uid)
          evaluates = (weiboEvaluates[0].forward_average/100.0 + weiboEvaluates[0].comment_average/100.0)
           csv << [weibo.screen_name,weibo.location,weibo.followers_count,evaluates,comments,forwards,comments+forwards,myforwards,mycomments,myforwards+mycomments]
      }
    } && nil



#通过名字 从 接口里面提 微博 列表export_weibo_list uids, filename, start_time, end_time 活跃度



#根据name读取与英特尔中国互动次数  互动微博地址 金融街购物中心微博:1924531943(小文)
 @intel = 1924531943
 @url = []
CSV.open "data/hudong_list20131008.csv", "wb" do |csv|
      csv << %w{UID 姓名  互动次数	 互动微博地址 }
path = File.join(Rails.root,"db/name0")
      names = []
      File.open(path,"r").each do|name|


          name =  name.strip
uid = ReportUtils.names_to_uids([name])
forwards = WeiboForward.where("uid = ? and forward_uid = ? ",@intel,uid[0])
comments = WeiboComment.where("uid = ? and comment_uid = ? ",@intel,uid[0])
if !forwards.nil?
 forwards.each do|forward|
    weibo = WeiboDetail.where("weibo_id = ?",forward.weibo_id).first
    @url << weibo.url
 end
end
if !comments.nil?
 comments.each do|comment|
    weibo = WeiboDetail.where("weibo_id = ?",comment.weibo_id).first
    @url << weibo.url
 end
end

 forward_count = WeiboForward.where("uid = ? and forward_uid = ? ",intel,uid[0],).count
 comment_count = WeiboComment.where("uid = ? and comment_uid = ? ",intel,uid[0]).count
  puts name
  csv << [uid[0], name,forward_count+comment_count,@url.uniq*","]
end
end







#从接口提取 一个人的粉丝（存库里） 

task = GetUserTagsTask.new
    friend_ids = task.api.friendships.followers_ids(:uid=>uid, :count=>5000).ids
    #task.api.friendships.followers_ids 粉丝
    #task.api.friendships.friends_ids 关注ren
  friend_ids.each do|uid|

   uids = uid.to_s.strip
  begin
    res = task.stable{task.api.users.show(uids)}

   task.save_weibo_user(a)
    rescue Exception=>e
    e.message
    end
  end


#从接口提取 一个人的粉丝（存库里）

task = GetUserTagsTask.new
path = File.join(Rails.root, "db/uid")
 File.open(path,"r").each do|uid|
   uids = uid.to_s.strip
   begin
    res = task.stable{task.api.users.show(uids)}
    task.save_weibo_user(a)
    rescue Exception=>e
       next
    end
  end
  #res= task.stable{task.api.friendships.friends.bilateral.ids(uid:1422775437,count:50,page:1)}
#从接口里面提取一个人粉丝列表uid 并从数据库里面查这给人的信息 导入Csv
  filename = "data/可口可乐粉丝列表.csv"
CSV.open filename,"wb" do |csv|
  csv << %w{uid	 name   地址 	 性别	  听众	  收听	 微博数	  创建时间	 认证类型  	转发率 	平均转发	 评论率	  平均评论	 注册类型
}
  task = GetUserTagsTask.new
    friend_ids = task.api.friendships.followers_ids(:uid=>1795839430, :count=>5000).ids
    #task.api.friendships.followers_ids ·ÛË¿
    #task.api.friendships.friends_ids ¹Ø×¢µÄ
row = []
  friend_ids.each do|uid|
  uids = uid
   account = WeiboAccount.find_by_uid(uids)
          next if account.blank?

   csv << [account.uid,account.screen_name,account.location, account.gender, account.followers_count, account.friends_count, account.statuses_count, account.favourites_count, account.created_at, account.verified, account.verified_type
]
  #begin
   # res = task.stable{task.api.users.show(uid)}
   #task.save_weibo_user(a)
    #rescue Exception=>e
    #end
  end
end
#找出被屏蔽的帐号
task = GetUserTagsTask.new
filename = "data/被屏蔽的帐号1.csv"
path = File.join(Rails.root, "db/uid")
CSV.open filename,"wb" do |csv|
 csv << %w{uid}
 number = 1
 File.open(path,"r").each do|uid|
    uid = uid.strip
    puts '第#{number}'
    begin
    res = task.stable{task.api.users.show(uid)}
    rescue Exception =>e
          if e.message =~ / does not exist!/
             csv << [uid]
          end
    end
    number+=1
 end
end

#根据 uid 并从数据库里面查这给人的信息 导入Csv
 filename = "data/微博信息.csv"
CSV.open filename,"wb" do |csv|
  csv << WeiboAccount.to_row_title(:full)
  path = File.join(Rails.root, "db/uid")
 File.open(path,"r").each do|uid|
  uids = uid
   account = WeiboAccount.find_by_uid(uids)
          next if account.blank?
   accounts = account.to_row(:full)

   csv << accounts
  end
end
# 2获得url 

def analyse_links(['2295615873'],'2013-08-26','2013-09-01')
  all_links = []
  links = []
  ws = WeiboDetail.where("uid in (?) and post_at between ? and ?",['2295615873'], '2013-08-26','2013-09-01').all
  ws.each{|w|
    mw = MWeiboContent.find w.weibo_id
    urls = mw.text.scan(/(http:\/\/t\.cn\/[A-Za-z0-9]{5,7})/).flatten
    urls.each{|url|
      next if all_links.include? url
      url = url[0..18] if url.size>19
      all_links << url
      links << [w.uid,w.post_at.to_date.to_s, url]
      puts "%s\t%s\t%s" % [w.uid,w.post_at.to_date.to_s, url]
    }
  }
  links
end
 #1.点击量
def get_click(url)
  res = Net::HTTP.post_form(URI("http://weiboyi.com/apiController.php"),{shortUrl:url,type:"clickNum"})
  result = JSON.parse res.body
  #puts result
  result["clicks"]
end


# 3.# 商用 频道短链接点击量统计
links = analyse_links ['2295615873'],"2013-8-25","2013-9-1"


links.each_with_index{|ar,index|
  uid, date,url = ar
  clicks = get_click(url)
  if ar.size > 3
    ar[3] = clicks
  else
    ar << clicks
  end
  #puts "%s\t%s" % [index, ar.inspect]
  puts "%s\t%s\t%s"% [date,url,clicks]
} && nil

#通过name导出uid
filename = "uid.csv"
CSV.open filename,"wb" do |csv|
  csv << %w{uid}
path = File.join(Rails.root, "db/name0")
 uids = []
 File.open(path,"r").each do|line|
 name = line.strip
  uid =  WeiboAccount.find_by_screen_name(name,true).uid
  csv << [uid]
end
end
#从接口 更新 用户活跃度
path = File.join(Rails.root, "db/uid")
 File.open(path,"r").each do|line|
 task = task = GetUserTagsTask.new
 uid = line.strip
 task.load_weibo_user(uid)
 #WeiboAccount.find_by_uid(uid).update_evaluates
end

#更新粉丝列表，粉丝入库   
path = File.join(Rails.root, "db/uid5")
File.open(path,"r").each do|line|
    uid= line.strip
    rel = WeiboUserRelation.where(uid:2637370247,by_uid:uid).first
      rel = WeiboUserRelation.new(uid:2637370247,by_uid:uid) if rel.nil?
      rel.follow_time = Time.now
      rel.save!
    end
end

#WeiboUserAttribute itdm 入库
#<WeiboUserAttribute id: 1, user_id: 1, uid: 0,
#keyword_id: 77, weight: nil, created_at: "2013-06-22 17:00:51",
# updated_at: "2013-06-22 17:00:51">
path = File.join(Rails.root, "db/uid1")
File.open(path,"r").each do|line|
    uid= line.strip
    rel = WeiboUserAttribute.where(user_id:1,keyword_id:77,uid:uid).first
      rel = WeiboUserAttribute.new(user_id:1,keyword_id:77,uid:uid) if rel.nil?
      rel.weight = nil
      rel.created_at = Time.now
      rel.updated_at = Time.now
      rel.save!
    end
end

#根据uid查活跃度
filename = "活跃度20130925.csv"
CSV.open filename,"wb" do |csv|
  csv << %w{uid  活跃度}
path = File.join(Rails.root, "db/uid")
 File.open(path,"r").each do|line|
 row = []
 uid = line.strip
 weiboEvaluates = WeiboUserEvaluate.select('forward_average,comment_average ').where("uid = ?",uid)#2474528550

 evaluates = (weiboEvaluates[0].forward_average/100.0 + weiboEvaluates[0].comment_average/100.0)
 puts evaluates
 row << uid
 row << evaluates
 csv << row
  end
end
#通过uid 接口  查 这个人在一定时间内发 微薄 原创微博数 和转发微博数

    filename = "isorigin2.csv"
    CSV.open(filename,"wb"){|csv|
      csv << %w{uid 原创微博数 转发微博数 }
     path = File.join(Rails.root, "db/uid1")
    task = GetUserTagsTask.new
    File.open(path,"r").each{|uid|
         @isorigin = 0
         @noorigin = 0
        uid = uid.strip
        start_time = Time.new(2013,12,9)
        end_time  = Time.new(2013,12,18)
        puts "Processing uid : #{uid}"
        task.paginate(:per_page=>100) do |page|
          begin
            res = task.stable{task.api.statuses.user_timeline(uid:uid,count:100, page:1)}
            processing = true
            res['statuses'].each{|w|
              next if end_time && Time.parse(w.created_at) > end_time
              if Time.parse(w.created_at) > start_time
                !w.retweeted_status ? (@isorigin = @isorigin +1) : (@noorigin = @noorigin+1)
              else
                processing = false
                break
              end
            }
            processing ? res.total_number : 0
          rescue Exception=>e
            if e.message =~ /User does not exists!/
                 csv << [uid]
            end
          end
        end
         csv << [uid,@isorigin,@noorigin]
      }
    } && nil

    task = GetUserTagsTask.new
    filename = "isorigin6.csv"
    CSV.open(filename,"wb"){|csv|
      csv << %w{uid 微博数}
      path = File.join(Rails.root, "db/uid")
      start_time = '2013-12-09'
      end_time = '2013-12-18'
    File.open(path,"r").each{|uid|
        puts "Processing uid : #{uid}"
        uid = uid.strip
        top_id = nil
        number = 0
        task.paginate(:per_page=>100) do |page|
          begin
            res = task.stable{task.api.statuses.user_timeline(uid:uid,count:100, page:page)}
            processing = true
           if !res['statuses'][0].nil?
              if page == 1
                if Time.parse(res['statuses'][0].created_at)< Time.parse(res['statuses'][1].created_at)
                top_id = res['statuses'][0].id
                end
               end
              res['statuses'].each{|w|
                next if w.id == top_id
                puts w.created_at
                next if end_time && Time.parse(w.created_at) > end_time
                if Time.parse(w.created_at) > start_time
                   number+=1
                else
                  processing = false
                  break
                end
              }
           end
            processing ? res.total_number : 0
          rescue Exception=>e
            0
          end
        end
        csv << [uid,number]
      }

    }
 #根据uid 查出 原创数 原创微博总转发 原创微博总评论 转发英特尔次数	评论英特尔次数（范范）75人 
   filename = "13人原创微博——与中国互动20130923.csv"
    CSV.open(filename,"wb"){|csv|
      csv << %w{uid  原创数 原创微博总转发 原创微博总评论 转发英特尔次数  评论英特尔次数}
     path = File.join(Rails.root, "db/uid")
   task = GetUserTagsTask.new
    File.open(path,"r").each{|uid|
         @start_time = Time.new(2013,9,16)
        @end_time  = Time.new(2013,9,23)
         @isorigin = 0
         @forwards = 0
         @comments = 0
        uid = uid.strip
        page = 1

        processing = true
        begin
          begin
            res = task.stable{task.api.statuses.user_timeline(uid:uid,count:100, page:page)}
            res['statuses'].each{|w|
               next if @end_time && Time.parse(w.created_at) > @end_time
              if Time.parse(w.created_at) > @start_time
                if !w.retweeted_status
                @isorigin = @isorigin +1
                @forwards += w.reposts_count
                @comments += w.comments_count
                end
               else
                processing = false
                break
                end
            }

          rescue Exception=>e
            puts e.message
          end

          page+=1
        end while processing == true
       comment = WeiboComment.where("uid = ? and comment_uid = ?",'2637370927',uid).count
       forward = WeiboForward.where("uid = ? and forward_uid = ?",'2637370927',uid).count
         csv << [uid,@isorigin,@forwards,@comments,comment,forward]
      }
    } && nil

#活跃度 ，关注时间

filename = "evaluates_20130911.csv"
CSV.open filename,"wb" do |csv|
  csv << %w{uid 活跃度 关注时间}
path = File.join(Rails.root, "db/uid1")
 File.open(path,"r").each do|line|
 row = []
 uid = line.strip
 weiboEvaluates = WeiboUserEvaluate.select('forward_average,comment_average,').where("uid = ?",uid)
 evaluates = weiboEvaluates[0].forward_average + weiboEvaluates[0].comment_average
 wur = WeiboUserRelation.select('follow_time').where("uid = ? and by_uid = ?",'2637370927','2436530991')
 unless wur.blank?
 time = wur[0].follow_time
 end
 puts evaluates
 row << uid
 row << evaluates
 unless wur.blank?
 row <<  time
 row <<
 end
 csv << row
  end

end


#根据uid查询 关注英特尔中国的时间 #金融街购物中心微博:1924531943

filename = "tem_fans_time.csv"

CSV.open filename,"wb" do |csv|
  csv << %w{uid time}
path = File.join(Rails.root, "db/uid")
 File.open(path,"r").each do|line|
 row = []
 by_uid = line.strip
 weibotime = WeiboUserRelation.select('follow_time').where("uid = ? and by_uid = ?",'1924531943',by_uid)
 puts weibotime[0].follow_time
 row << by_uid
 row << weibotime[0].follow_time
 csv << row
  end

end


#根据uid 查询 是不是 intel  的 粉丝 金融街：1924531943 商用频道：2295615873   中国： 2637370927 国际：3869439663 



#根据uid 查询 是否关注 是主号  的 粉丝 http://weibo.com/1795839430/AhbvtnvrV http://weibo.com/1942473263/Ahr2cco18 http://weibo.com/2637370927/AhsuoFOTg
filename = "是否关注-1-1.csv"
task = GetUserTagsTask.new
CSV.open filename,"wb" do |csv|
  csv << %w{uid 是否主号 }
path = File.join(Rails.root,"db/uid1")
  File.open(path,"r").each do|line|
  uid = line.strip
  intel = '2637370247'#中国：2637370927 商用频道 2295615873
  begin
  res = task.api.friendships.show(source_id:uid,target_id:intel)
  rescue Exception=>e
   puts e.message
   csv << [uid]
   next
  end
  #if res.source.following
  #    WeiboUserRelation.where(:uid=>intel,:by_uid=>uid) .first_or_create(:uid=>intel,:by_uid=>uid,:follow_time=>Time.now.to_date,:created_at=>Time.now.to_date)
  # end
  csv << [uid,res.source.following ? "是":"否"]
  end
end
res = task.api.friendships.show(source_id:uid,target_id:2295615873)
# 读office文件  打印出来 

 require 'rubygems'
 require 'roo'

   HOURLY_RATE = 123.45
   path = File.join(Rails.root,"data/接口提取微博列表(根据uids)_20131128154748.xlsx")
   oo = Roo::Excelx.new(path)
   oo.default_sheet = oo.sheets.first
   5.upto(12) do |line| #5是打印的数  12是第12行打印
     name       = oo.cell(line,'B')

      puts "#{name}"
  end



#根据screen_name 查询 标识
path = File.join(Rails.root,"db/name")
    CSV.open "uid.csv", "wb" do |csv|

    csv << %w{}
    File.open(path,"r").each do|line|
      screen_name = line.strip
          account = WeiboAccount.find_by_screen_name(screen_name)
          next if account.blank?
          row = account.to_row(:full)

          u = MUser.find screen_name
          unless u.nil?
          tags = u.tags * ","

          row << tags
          end

          csv << row
      end
    end


#export weibo list to csv by uids for file ReportUtils.export_weibo_list_to_csv(uid,filename)
  #ReportUtils.export_weibo_list_to_csv_by_uids_file("db/15Wuids")
  def self.export_weibo_list_to_csv_by_uids_file(filepath,filename)
    path = File.join(Rails.root, "db/15Wuids")
    CSV.open filename, "wb" do |csv|

    csv << %w{}
    File.open(path,"r").each do|line|
      uid = line.strip
          account = WeiboAccount.find_by_uid(uid)
          next if account.blank?
          row = account.to_row

          u = MUser.find uid
          unless u.nil?
          tags = u.tags * ","

          row << tags
          end

          csv << row
      end
    end

  end


# 查询和 中国 互动人信息 互动时间
#uid = '2637370927'
filename = "weibo_weibo_list_by__ok.csv"
  CSV.open filename,"wb" do |csv|
    csv << %w{uid name location}
#3620546325922080 WeiboForward.where("weibo_id= ?",'3620546325922080').distinct(by_uid)
    WeiboDetail.where("uid = ?",2637370247).where("post_at between ? and ?",'2013-9-9','2013-9-10').each{|weibo|
    forwards = WeiboForward.where("weibo_id= ?",weibo.weibo_id)
    comments = WeiboComment.where("weibo_id= ?",weibo.weibo_id)
    intel = '2637370927'
    forwards.each{|forward|
      uid = forward.forward_uid
      a = WeiboAccount.find_by_uid(uid)
      next if a.nil?
      row = a.to_row

      rel = WeiboUserRelation.where(uid:intel,by_uid:uid).first
      rel = rel ? "是": "不是"

      row << rel
      row << weibo.url
      row << weibo.post_at.strftime("%Y-%m-%d %H:%S")
      row << weibo.weibo_id
      row << "转发"
      csv << row
    }
    comments.each{|comment|
      uid = comment.comment_uid
      a = WeiboAccount.find_by_uid(uid)
      next if a.nil?
      row = a.to_row
      puts row
      rel = WeiboUserRelation.where(uid:intel,by_uid:uid).first
      rel = rel ? "是": "不是"
      row << rel
      row << weibo.url
      row << weibo.post_at.strftime("%Y-%m-%d %H:%S")
      row << weibo.weibo_id
      row << "评论"
      csv << row
    }
  }
  
  #互动人信息 互动时间 
  filename = "weibo_weibo_list_by__ok.csv"
  CSV.open filename,"wb" do |csv|
    csv << %w{uid }
#3620546325922080 WeiboForward.where("weibo_id= ?",'3620546325922080').distinct(by_uid)
    forwards = WeiboForward.where("uid = ?  and forward_at between ? and ?",2637370927 ,'2014-06-23','2014-06-30')
    comments = WeiboComment.where("uid = ?   and comment_at between ? and ?",2637370927 ,'2014-06-23','2014-06-30')
    forwards.each{|forward|
      uid = forward.forward_uid
      csv << [uid]
    }
    comments.each{|comment|
      uid = comment.comment_uid
      csv << [uid]
    }
  end
#根据url查询和 中国 互动人uid 查出时间(范范)
filename = "hudong_list_by_weibo_id_and_uid2013-0922.csv"
  CSV.open filename,"wb" do |csv|
    csv << %w{uid 总共评论 总共转发 互动时间 url}
    path1 = File.join(Rails.root,"db/uid") #从file拿uid
    path2 = File.join(Rails.root,"db/url")#从file拿weibo_id
      File.open(path1,"r").each do|uid|
          uid  = uid.strip
          forward = 0
          comment = 0
      File.open(path2,"r").each do|url|
      url = url.strip
      weibo_id = WeiboMidUtil.str_to_mid url.split("/").last  #
      forwards = WeiboForward.where("weibo_id= ? and forward_uid=?",weibo_id,uid).first
      comments = WeiboComment.where("weibo_id= ? and comment_uid=?",weibo_id,uid).first
       forwards.blank? ? (forward=forward) : (forward +=1)
       comments.blank? ? (comment=comment) : (comment +=1)
      (csv << [uid,comment,forward,forwards.forward_at,url]) unless   (forwards.blank?)
      (csv << [uid,comment,forward,comments.comment_at,url]) unless   (comments.blank?)
      end

    end
  end
#根据 url 查 uid中与 url互动 数
filename = "hudong20130925.csv"
  CSV.open filename,"wb" do |csv|
    csv << %w{url 互动}
    path1 = File.join(Rails.root,"db/uid") #从file拿uid
    path2 = File.join(Rails.root,"db/url")#从file拿weibo_id
     File.open(path2,"r").each do|url|
           url = url.strip
          forward = 0
          comment = 0
         weibo_id = WeiboMidUtil.str_to_mid url.split("/").last  #
      File.open(path1,"r").each do|uid|
          uid  = uid.strip

      forwards = WeiboForward.where("weibo_id= ? and forward_uid=?",weibo_id,uid).first
      comments = WeiboComment.where("weibo_id= ? and comment_uid=?",weibo_id,uid).first
       forwards.blank? ? (forward=forward) : (forward +=1)
       comments.blank? ? (comment=comment) : (comment +=1)
      end
     csv << [url,comment+forward]
    end
  end


#关注 中国 粉丝列表 关注时间
CSV.open("attention_weibo_fans_list20130918.csv","wb"){|csv|

  csv << %w{uid name 地址 性别 听��� 收听 微博数	 创建时间 认证类型 转发率	 平均转发 评论率	 平均评论 注册类型 关注时间 }
  intel = '2637370927'
   row = []
   relation = WeiboUserRelation.where("uid = ?",'2637370927').where("follow_time between ? and ? ",'2013-09-09','2013-09-15')
   relation.each do |relations|
       weibo = WeiboAccount.find_by_uid(relations.by_uid)
       next if weibo.blank?
       row = weibo.to_row

       row << relations.follow_time
       csv << row
   end
}
#关注 中国 粉丝列表 关注时间  活跃度
CSV.open("attention_weibo_fans_list20130918.csv","wb"){|csv|

  csv << %w{uid name 地址 性别 听众 收听 微博数	 创建时间 认证类型 转发率	 平均转发 评论率	 平均评论 注册类型}
path = File.join(Rails.root,"db/uid")
  row = []
  File.open(path,"r").each do|line|
  by_uid = line.strip
  intel = '2637370927'
  weibo = WeiboAccount.find_by_uid(by_uid)

  attention_time = WeiboUserRelation.where("by_uid = ? and uid = ?"by_uid,2637370927)

  evaluates = WeiboUserEvaluate.find_by_uid(by_uid)
  next if evaluates.blank?
  forward = WeiboForward.where("uid = ? and forward_uid = ?",intel,by_uid).count
  comment = WeiboComment.where("uid = ? and comment_uid = ?",intel,by_uid).count
  time = attention_time[0].follow_time
  unless evaluates.nil?
  evaluate = evaluates.forward_average + evaluates.comment_average
  end
  interactive = forward[0] + comment[0]
  row = []
  row << time
  row << evaluate
  row << interactive
  csv << row
end
}





 #1范范平台方法:  UID 昵称 认证类型 认证信息  粉丝数 活跃度 与中国互动（评论/转发）

             start_time = Time.new(2013,9,10)
             end_time = Time.new(2013,9,23)
             filename  = "test.csv"
             names = []

             intel = '2637370927'
             uids = ReportUtils.names_to_uids(names,true)
             return if uids.blank?
             task = GetUserTagsTask.new
        CSV.open(filename,"wb"){|csv|
          csv << %w{UID 昵称 认证类型 认证信息  粉丝数 活跃度 与中国互动（评论/转发） }

        uids.each{|uid|
           uid = uid
           weibo_count = 0
           puts "Processing uid : #{uid}"
           top_id = nil
        task.paginate(:per_page=>100) do |page|
          begin
              res = task.stable{task.api.statuses.user_timeline(uid:uid,count:100, page:page)}# tast.api 连接 接口 ，statuses.user_timeline连接  这个表， uid 要 查的uid  ，count一页显示多少 个 ， page，第几页
              if page == 1
              if Time.parse(res['statuses'][0].created_at)< Time.parse(res['statuses'][1].created_at)
              top_id = res['statuses'][0].id
              end
              end
              processing = true
              res['statuses'].each{|w|
              next if w.id == top_id
              next if end_time && Time.parse(w.created_at) > end_time
              if Time.parse(w.created_at) > start_time
                weibo_count = weibo_count+1
                puts weibo_count
              else
                processing = false
                break
              end
            }
            processing ? res.total_number : 0
            rescue Exception=>e
           end
        end
           forwards = WeiboForward.where("uid = ? and forward_uid = ?",intel,uid).where("forward_at between ? and ?",start_time,end_time).count
           comments = WeiboComment.where("uid = ? and comment_uid = ?",intel,uid).where("comment_at between ? and ?",start_time,end_time).count
           weibo = WeiboAccount.find_by_uid(uid)
           verified_type = weibo.human_verified_type.uniq*","
           a ||= MUser.find(uid)
           verified_reason = a.try(:verified_reason)
           weibo.update_evaluates
           evaluates = WeiboUserEvaluate.find_by_uid(uid)
           evaluate = evaluates.forward_average + evaluates.comment_average
           csv << [uid,weibo.screen_name,verified_type,verified_reason,weibo.followers_count,evaluate/100.0,forwards.to_s+"/"+comments.to_s]
      }
    } && nil
#2范范平台方法: UID 昵称  活跃度 时间 微博内容分类 微博连接 微博内容 总转/评 二次转/评率

             start_time = Time.new(2013,9,10)
             end_time = Time.new(2013,9,23)
             filename  = "test.csv"
             names = [IansWorld,chandler0328]# 数组
             intel = '2637370927'

             uids = ReportUtils.names_to_uids(names,true)
             return if uids.blank?
             task = GetUserTagsTask.new
        CSV.open(filename,"wb"){|csv|
          csv << %w{UID 昵称  活跃度 时间 微博内容分类 微博连接 微博内容 总转/评 二次转/评率  }

        uids.each{|uid|

             uid = uid
             account =  WeiboAccount.find_by_uid(uid)
             comment_weibo = WeiboComment.where("uid = ? and comment_uid = ?",'2637370927',uid)
             next if comment_weibo.blank?
             weibo.update_evaluates
             evaluates = WeiboUserEvaluate.find_by_uid(uid)
             evaluate = evaluates.forward_average + evaluates.comment_average
             commentcount = 0
           comment_weibo.each do |comment|

             record = WeiboDetail.where("weibo_id = ?",comment.weibo_id)
             c = MWeiboContent.find(comment.weibo_id)
             next if c.nil?
             srouce = ActionView::Base.full_sanitizer.sanitize(c.source)
             type = case
                when record[0].image? && record[0].video?
                  "image + video"
                when record[0].image?
                  "image"
                when record[0].video?
                  "video"
                when record[0].music?
                  "music"
                when record[0].vote?
                  "vote"
                else
                  "text"
              end
          origin = !record[0].forward
          post_at = record[0].post_at.strftime("%Y-%m-%d %H:%M:%S")
          csv << [uid,account.screen_name,evaluate/100.0,post_at,type,record[0].url,c.text,record[0].reposts_count.to_s + "/" +record[0].comments_count]
       end
       forward_weibo = WeiboForward.where("uid = ? and forward_uid = ?",'2637370927',uid)
            next if forward_weibo.blank?


        forward_weibo.each do |forward|


            record = WeiboDetail.where("weibo_id = ?",forward.weibo_id)   #
            c = MWeiboContent.find(forward.weibo_id)
            next if c.nil?
            srouce = ActionView::Base.full_sanitizer.sanitize(c.source)
            type = case
              when record[0].image? && record[0].video?
                "image + video"
              when record[0].image?
                "image"
              when record[0].video?
                "video"
              when record[0].music?
                "music"
              when record[0].vote?
                "vote"
              else
                "text"
            end
        origin = !record[0].forward
        post_at = record[0].post_at.strftime("%Y-%m-%d %H:%M:%S")
        csv << [uid,account.screen_name,evaluate/100.0,post_at,type,record[0].url,c.text,record[0].reposts_count.to_s + "/" +record[0].comments_count,]

       end
      }
    } && nil


#根据uid查注册时间(范范)
        task = GetUserTagsTask.new
        filename  = "created_at1.csv"
        CSV.open(filename,"wb"){|csv|
          csv << %w{UID 注册时间 注册年份}
          path = File.join(Rails.root,"db/uid")
          row = []
          File.open(path,"r").each do|line|
            uid = line.strip
           #screen_name = line.strip
           #uid  = ReportUtils.names_to_uids([screen_name],true)[0]
           begin
           weibo = task.load_weibo_user(uid)
           rescue Exception =>e
             if e.message =~ / does not exist!/
                csv << [uid]
                next
             else
                csv << [uid]
                next
             end

           end
            csv << [uid,weibo.created_at,weibo.created_at.year]
          end
       }

3662599407359580

#接口 根据url查微博信息    url 内容 原创 发布时间 小时 周几 来源 评论数 	转发数  互动量(范范) 活跃度 
weibo_ids = urls.map{|url| WeiboMidUtil.str_to_mid url.split("/").last}
filename = "微博信息_jj-1-1.csv"
  task = GetUserTagsTask.new
  CSV.open filename,"wb" do |csv|
    csv << %w{url 内容 原创 发布时间  来源 评论数 	转发数  互动量 原微薄url}
    path = File.join(Rails.root,"db/url1")#从file拿weibo_id
    File.open(path,"r").each do|line|
      if line.blank?
        csv << [""]
        next
      end
      url = line.strip
      weibo_id = WeiboMidUtil.str_to_mid url.split("/").last
       begin
       res = task.stable{task.api.statuses.show(id:weibo_id)}#http://weibo.com/2812586933/Aq33jswEW
       res.retweeted_status.nil? ? origin = 'Y' : origin = 'N'
       source = ActionView::Base.full_sanitizer.sanitize(res.source)
       str = WeiboMidUtil.mid_to_str url.to_s
       url1 = ''
       if !res.retweeted_status.nil?
          str1 = WeiboMidUtil.mid_to_str res.retweeted_status.idstr
          url1 = 'http://weibo.com/'+res.retweeted_status.user.idstr+'/'+str1
       end
       csv << [url,res.text,origin,Time.parse(res.created_at),source,res.reposts_count,res.comments_count,res.reposts_count+res.comments_count,url1]
       rescue Exception =>e
          e.message =~ / does not exist!/
          csv << [url]
       end
  end
end
#拼url
filename = "范范-互动.csv"
  task = GetUserTagsTask.new
  CSV.open filename,"wb" do |csv|
    csv << %w{url}
    path = File.join(Rails.root,"db/uid")#从file拿weibo_id
    path1 = File.join(Rails.root,"db/url")#从file拿weibo_id
    File.open(path,"r").each do|line|
      uid = line.strip
      File.open(path1,"r").each do|line|
        url = line.strip
        str = WeiboMidUtil.mid_to_str url
        csv <<['http://weibo.com/'+uid+'/'+str.to_s]
      end
  end
end
#通过url 查微博信息 url 评论数 	转发数  互动量 参与 净参与人 粉丝数(范范) 
filename = "范范-14人-静参人数.csv"
  task = GetUserTagsTask.new
  CSV.open filename,"wb" do |csv|
    csv << %w{url 评论数 转发数 互动量 参与互动人数 粉丝数}
    path = File.join(Rails.root,"db/url")#从file拿weibo_id
      @all_interactive = []
      File.open(path,"r").each do|line|

      url = line.strip
      weibo_id = WeiboMidUtil.str_to_mid url.split("/").last#http://weibo.com/1902520272/AdgAY5a54  http://weibo.com/2637370927/AdYvTsFCh
      puts url
      forward = []
      comment = []
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
              if !res.comments.blank?
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
#debugger
      interactive = forward+comment
      @all_interactive += interactive
      begin #解决异常
       res = task.stable{task.api.statuses.show(id:weibo_id)}#http://weibo.com/2056744733/Ad6n2BxT4
       csv << [url,res.reposts_count,res.comments_count,res.reposts_count+res.comments_count,interactive.uniq.size,res.user.followers_count]
      rescue Exception=>e
        if e.message =~ / does not exist!/
          csv << [url]
        else
          raise e
        end
      end

    end
    csv << %w{上面微博总参与人数}
    csv << [@all_interactive.uniq.size]
    @all_interactive.uniq.size
  end
#转发了微博静参与人数粉丝和 Weibo 

filename = "范范-75人-静参人数.csv"
  task = GetUserTagsTask.new
  CSV.open filename,"wb" do |csv|
    csv << %w{url 转发静参与人数 静参与人粉丝和}
    path = File.join(Rails.root,"db/url")#从file拿weibo_id
      @all_interactive = []
      File.open(path,"r").each do|line|
      url = line.strip
      weibo_id = WeiboMidUtil.str_to_mid url.split("/").last#http://weibo.com/1902520272/AdgAY5a54  http://weibo.com/2637370927/AdYvTsFCh
      puts url

       page = 1
      processing = true
       begin
         begin
              res = task.stable{task.api.statuses.repost_timeline(weibo_id.to_s,count:200,page:page)}#根据weibo_id查转发人信息
                if !res.blank?
                   res.reposts.each do |line|
                    if line.nil?
                       processing = false
                       break
                    end
                   @all_interactive << line.user.name
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
  end
        uids = ReportUtils.names_to_uids(@all_interactive.uniq,true)
        fans = 0
        uids.each do |line|
            if WeiboAccount.find_by_uid(line).followers_count.nil?
                fans +=0
             else
             fans += WeiboAccount.find_by_uid(line).followers_count
            end
        end
     csv << [uids.size,fans]
end
 intel = ReportUtils.names_to_uids(['英特尔芯品汇'],true).first
#查看 转发 英特尔中国 人的 信息(大文)(张桢)
filename = "单独微博转发信息.csv"
  task = GetUserTagsTask.new
CSV.open filename,"wb" do |csv|
    title = WeiboAccount.to_row_title(:default)
    uids = []
    intel = '2833533023'#中国：2637370927 商用频道 2295615873
    title1 = ['关注时间','是否关注中国','现在是否关注中国']
    csv <<  title + title1
   forwards = WeiboForward.where("weibo_id = ?","3648904220619469")
   #forwards = WeiboForward.where("uid = ? and forward_at >= ? and forward_at < ?",'2637370927','2013-10-07','2013-10-12')
   forwards.each do |line|
      uids << line.forward_uid
   end
   uids.uniq.each do |line|
      uid = line
      rows = []
      weibo = WeiboAccount.find_by_uid(uid)

      rows = weibo.to_row(:default)
=begin
      relation = WeiboUserRelation.where("by_uid = ? and uid = ?",uid,intel)
      if !relation[0].nil?
        rows << relation[0].follow_time
        rows << '是'
        else
        rows << ''
        rows << '否'
      end

      begin
      res = task.api.friendships.show(source_id:uid,target_id:intel)
      rescue Exception=>e
       puts e.message
       rows << '这个帐号被屏蔽'
       next
      end
      rows << res.source.following ? "是":"否"
=end
      csv << rows
   end
end
#根据name 查 这个人基本信息（大文）

filename = "基本信息1.csv"
  task = GetUserTagsTask.new
CSV.open filename,"wb" do |csv|
 csv << WeiboAccount.to_row_title(:quality)
 path = File.join(Rails.root,"db/name1")
  File.open(path,"r").each do|line|
    name = line.strip
    uids = ReportUtils.names_to_uids([name],true)
      if uids.size ==0
        csv << [name]
        next
      end
      weibo = task.load_weibo_user(uids[0])
      csv << weibo.to_row(:quality)
  end
end
#根据时间查 新老粉丝 英特尔中国uid = '2637370927'(范范)
names = %w{
 英特尔中国天天事
英特尔新极客
英特尔商用频道
超极本
高通中国
Snapdragon骁龙
联想
ThinkPad
东芝电脑
戴尔中国
ASUS华硕
惠普电脑
杜蕾斯官方微博
戴尔促销
ARM中国
AMD中国
Acer宏碁
}
#饭团AMD	2027607132
names.each do |line|
filename = "英特尔芯品汇-新老粉丝2.1-4.21.csv"
CSV.open filename,"wb" do |csv|
  csv << %w{UID 昵称 位置 性别 粉丝数 关注数 微博数 注册时间 认证 认证原因 新老粉丝 微博URL  原微薄内容 原微博转发量 评论转发说的内容 发布时间 互动时间 MID 转发微博ID 动作}
 #UID	昵称	粉丝数	认证类型	认证原因		注册时间 是否关注中国	 关注中国时间	互动原微博链接	互动原微博内容 原微博转发量 	原微博发布时间	互动时间	互动时说的话	动作
    uids = []
    #intel = 2637370247#
    intel = ReportUtils.names_to_uids(['英特尔芯品汇'],true).first
    start_time = '2014-02-01'
    end_time = '2014-04-22'
    forwards = WeiboForward.where("uid = ?  and forward_at between ? and ? ",intel,start_time,end_time)
    comments = WeiboComment.where("uid = ?  and comment_at between ? and ? ",intel,start_time,end_time)
    forwards.each{|forward|
      row = []
      uid = forward.forward_uid
      a = WeiboAccount.find_by_uid(uid)
      next if a.nil?
      row = a.to_row
      weibo = WeiboDetail.find_by_weibo_id(forward.weibo_id)
      c = MWeiboContent.find(forward.weibo_id)
      centent = MForward.find(forward.forward_id)
      rel = WeiboUserRelation.where(uid:intel,by_uid:uid).first

      rel = rel ? (
              rel.follow_time ? (
                rel.follow_time >= start_time.to_date ? "新" : "老"
              ) : "老"
            ) : ""
      row << rel
      next if weibo.nil?
      weibo.url.nil?? row << '' : row << weibo.url
      row << c.text
      row << c.reposts_count
      centent.nil? ? row << "" : row << centent.text
      row << weibo.post_at.strftime("%Y-%m-%d %H:%S")
      row << forward.forward_at.strftime("%Y-%m-%d %H:%S")
      row << weibo.weibo_id
      row << forward.forward_id
      row << "转发"
      csv << row
    }
    comments.each{|comment|
      row = []
      uid = comment.comment_uid
      a = WeiboAccount.find_by_uid(uid)
      next if a.nil?
      row = a.to_row
      puts row
      weibo = WeiboDetail.find_by_weibo_id(comment.weibo_id)
      c = MWeiboContent.find(comment.weibo_id)
      centent = MComment.find(comment.comment_id)
      rel = WeiboUserRelation.where(uid:intel,by_uid:uid).first
      rel = rel ? (
              rel.follow_time ? (
                rel.follow_time >= start_time.to_date ? "新" : "老"
              ) : "老"
            ) : ""
      row << rel
      next if weibo.nil?
      weibo.url.nil?? row << '' : row << weibo.url
      row << c.text
      row << ''
      centent.nil? ? row << "" : row << centent.text
      row << weibo.post_at.strftime("%Y-%m-%d %H:%S")
      row << comment.comment_at.strftime("%Y-%m-%d %H:%S")
      row << weibo.weibo_id
      row << ''
      row << "评论"
      csv << row
    }
end

end



require 'benchmark'
Benchmark.bmbm(10) do |t|
t.report{WeiboAccount.first}
end




#通过uid 查 他与英特尔中国互动的 内容（张桢）if centent.text.nil??  text = "" : text = centent.text 2319965617
filename = "weibo-新老粉丝互动内容.csv"
 path = File.join(Rails.root,"db/uid")
CSV.open filename,"wb" do |csv|
      csv << %w{uid 互动内容 属性}
      File.open(path,"r").each do|line|
       uid = line.strip
       puts uid
       comments = WeiboComment.where("uid = ? and comment_uid = ?",'2637370927',uid)
       forwards = WeiboForward.where("uid = ? and forward_uid = ?",'2637370927',uid)
       if !comments.nil?
          comments.each do |comment|
               puts comment.comment_id
              centent = MComment.find(comment.comment_id)
              next if centent.nil?
          puts centent
              csv << [uid,centent.text,"评论"]
          end
        end
       if !forwards.nil?
          forwards.each do |forward|
              puts forward.forward_id
              centent = MForward.find(forward.forward_id)
              next if centent.nil?
              puts centent
              csv << [uid,centent.text,"转发"]
          end
        end
      end
end
#查 一个帐号 一段时间内互动人  ： kol 或  ITDM  （张桢）
#英特尔商用频道、思科数据中心、ThindPad、首席智库、CSDN云计算、IT经理世界杂志
#0701-0930 互动人数中，KOL和ITDM的互动人数占比
filename = "intel-互动人-kol-itdm-1103之前.csv"
CSV.open filename,"wb" do |csv|
    csv << %w[互动人 kol人 itdm人]
   uids = ReportUtils.names_to_uids(['英特尔商用频道'])#'英特尔商用频道','思科数据中心','ThinkPad','首席智库','CSDN云计算','IT经理世界杂志'
   uids.each do|uid|
    forwarduid = []
    commentuid = []
    itdmuid = []
    koluid = []
    date = '2013-11-10'
    @uid = []
    #start_time = Time.new(2013,10,20)
    #end_time = Time.new(2013,10,26)   #between ? and ?",start_time,end_time

      forwards = WeiboForward.where("uid = ? and forward_uid = ? and forward_at <= ?  ",2295615873,uid,date)
      comments = WeiboComment.where("uid = ? and comment_uid = ? and comment_at <= ? ",2295615873,uid,date)
      forwards.each{|forward|
        @uid << forward.forward_uid
      }
      comments.each{|comment|
        @uid << comment.comment_uid
      }

    itdms = WeiboUserAttribute.find_by_sql <<-EOF
     select  uid uid  from weibo_user_attributes where  keyword_id = 77
  EOF
    kols = WeiboUserAttribute.find_by_sql <<-EOF
     select  uid uid  from weibo_user_attributes where  keyword_id = 85 or keyword_id= 86 or keyword_id = 88 or keyword_id = 90
  EOF
    itdms.each do |line|
      itdmuid << line.uid
    end
    kols.each do |line|
      koluid << line.uid
    end

    kol = @uid.uniq & koluid
    itdm = @uid.uniq & itdmuid
    kol.uniq.each do |uid|
      csv << [uid,"kol"]
    end
    itdm.uniq.each do |uid|
     csv << [uid,"itdm"]
    end
    csv << [@uid.uniq.size,kol.size,itdm.size]#,itdm.size
  end
end
#导出 kol  itdm 更新粉丝信息
filename = "koluid.csv"

CSV.open filename,"wb" do |csv|

end
rows = []
path = File.join(Rails.root,"db/uid")
File.open(path,"r").each do|line|
rows << line.strip
end
#根据uid 查看 与商用频道互动次数(张桢) kol  itdm
filename = "itdms20140101-20140213.csv"
# path = File.join(Rails.root,"db/uid")
CSV.open filename,"wb" do |csv|
      csv << %w{zero 1-5次 5-10次 10-20次 20以上}
      zero = 0
      one = 0
      two = 0
      three = 0
      four = 0
      #date = '2013-12-21'
     itdms = WeiboUserAttribute.find_by_sql <<-EOF
     select  uid uid  from weibo_user_attributes where  keyword_id = 77
  EOF
    kols = WeiboUserAttribute.find_by_sql <<-EOF
     select  uid uid  from weibo_user_attributes where  keyword_id = 85 or keyword_id= 86 or keyword_id = 88 or keyword_id = 90
  EOF
     itdms.each do|line|
          uid = line.uid
          forwards = WeiboForward.where("uid = ? and forward_uid = ? and forward_at between ? and ? ",2295615873,uid,'2014-01-01','2014-02-14')#12 26  11 1
          comments = WeiboComment.where("uid = ? and comment_uid = ? and comment_at between ? and ?",2295615873,uid,'2014-01-01','2014-02-14')
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
#根据uid 查看 与商用频道互动次数(张桢) kol  itdm
filename = "kol互动数.csv"
 path = File.join(Rails.root,"db/uid4")
task = GetUserTagsTask.new
CSV.open filename,"wb" do |csv|
      csv <<  WeiboAccount.to_row_title(:quality) + %w{与商用频道11月互动 与商用频道12月互动  }
      zero = 0
      one = 0
      two = 0
      three = 0
      four = 0
      forwardcount = 0
      commentscount = 0
      File.open(path,"r").each do|line|
          uid = line.strip
 #debugger
            rows = []
            forwards = WeiboForward.where("uid = ? and forward_uid = ? ",2295615873,uid)
            comments = WeiboComment.where("uid = ? and comment_uid = ? ",2295615873,uid)
            account = task.load_weibo_user(uid)

            forwardmonth11 = forwards.where("forward_at >= ? and forward_at < ?",'2013-11-01','2013-12-01').count
            forwardmonth12 = forwards.where("forward_at >= ? and forward_at < ?",'2013-12-01','2014-01-01').count

            commentmonth11 = comments.where("comment_at >= ? and comment_at < ?",'2013-11-01','2013-12-01').count
            commentmonth12 = comments.where("comment_at >= ? and comment_at < ?",'2013-12-01','2014-01-01').count
            rows = account.to_row(:quality)
            rows << forwardmonth11 + commentmonth11
            rows << forwardmonth12 + commentmonth12
             csv << rows
      end
end
=begin
forwards = WeiboForward.where("uid = ? and forward_uid = ? and forward_at >= ? and forward_at <= ? ",2295615873,uid,start_time,end_time)
          comments = WeiboComment.where("uid = ? and comment_uid = ? and comment_at >= ? and comment_at <= ? ",2295615873,uid,start_time,end_time)
=end


#通过uid 查 转发 评论英特尔中国次数(张桢)
filename = "level2.csv"
 path = File.join(Rails.root,"db/uid")
CSV.open filename,"wb" do |csv|
      csv << %w{uid 转发中国数 评论中国数 互动}
      File.open(path,"r").each do|line|
        uid = line.strip
        forwards = WeiboForward.where("uid = ? and forward_uid = ? and forward_at between ?  and ?",2637370927,uid,'2013-11-14','2013-12-05').count
        comments = WeiboComment.where("uid = ? and comment_uid = ? and comment_at between ?  and ?",2637370927,uid,'2013-11-14','2013-12-05').count
      csv << [uid,forwards,comments,forwards+comments]
      end
end

filename = "蛟龙-粉丝地域.csv"
CSV.open filename,"wb" do |csv|
      csv << %w{uid 地域}
      relations = WeiboUserRelation.where(uid:2619244577)
          relations = relations.where("follow_time >= ?",'2013-10-07')
          relations = relations.where("follow_time < ?",'2013-10-14')
        task = GetUserTagsTask.new
      relations.each do|line|
      a = WeiboAccount.find_by_uid(line.by_uid)
            if a.nil?
              begin #解决异常
              res = task.stable{task.api.users.show(uid:line.by_uid)}
              csv << [line,res.screen_name,res.location]
              rescue Exception=>e
                if e.message =~ /User does not exists!/
                csv << [line]
                else
                csv << nil
                end
              end
           else
            csv << [a.uid,a.screen_name,a.location]
           end
      end
end


if record
          uids << record.uid
        elsif  auto_load
          begin#是否
          res = task.stable{task.api.users.show(screen_name:n)}
          task.save_weibo_user res
          uids << res.id
          rescue Exception
            raise $! unless $!.message =~ /exists/
            uids << nil
            bad_names << n
          end
        else
          uids << nil
          bad_names << n
        end
#通过uid 查看 UID基本信息 +	共同关注人数	昵称	认证类型	认证原因	是否是中国的粉丝	近3个月是否与中国互动过	微博原创占比	活跃度	评论中国次数	转发中国次数	主动@中国次数 

filename = "data/60人信息.csv"
  intel = 2637370927
  title = WeiboAccount.to_row_title(:full)
  time0 = Time.now.month
  time1 = Time.now.month - 1
  time2 = Time.now.month - 2
  time3 = Time.now.month - 3
  day =  Time.now.day
  title1 = [ '是否是中国的粉丝	',time3.to_s + '月' + day.to_s + '日-' + time2.to_s + '月' + day.to_s + '日' + '与中国互动次数',time2.to_s + '月' + day.to_s + '日-' + time1.to_s + '月' + day.to_s + '日' + '与中国互动次数',time1.to_s + '月' + day.to_s + '日-' + time0.to_s + '月' + day.to_s + '日' + '与中国互动次数','微博原创占比','活跃度','评论中国次数','转发中国次数','主动@中国次数']
 task = GetUserTagsTask.new
CSV.open filename,"wb" do |csv|
  csv << title + title1
  path = File.join(Rails.root, "db/uid")
 File.open(path,"r").each do|uid|

  accounts = []
  uid = uid.strip
  puts uid
#debugger
   begin
   account = task.load_weibo_user(uid)
   rescue Exception =>e
    if e.message =~ /User does not exists!/
       csv << [uid]
        next
     else
       csv << [nil]
       next
     end
   end
   accounts = account.to_row(:full)#
   accountcount = WeiboUserRelation.where("uid = ? and by_uid = ?",intel,uid).count > 0 ? "是" : "否"
   accounts << accountcount
   forwards1 = WeiboForward.where("uid = ? and forward_uid = ? and forward_at between ?   and ?",intel,uid,Time.now-3.month,Time.now-2.month).count
   comments1 = WeiboComment.where("uid = ? and comment_uid = ? and comment_at between ?   and ?",intel,uid,Time.now-3.month,Time.now-2.month).count
   forwards2 = WeiboForward.where("uid = ? and forward_uid = ? and forward_at between ?   and ?",intel,uid,Time.now-2.month,Time.now-1.month).count
   comments2 = WeiboComment.where("uid = ? and comment_uid = ? and comment_at between ?   and ?",intel,uid,Time.now-2.month,Time.now-1.month).count
   forwards3 = WeiboForward.where("uid = ? and forward_uid = ? and forward_at between ?   and ?",intel,uid,Time.now-1.month,Time.now).count
   comments3 = WeiboComment.where("uid = ? and comment_uid = ? and comment_at between ?   and ?",intel,uid,Time.now-1.month,Time.now).count
    accounts << forwards1 + comments1
    accounts << forwards2 + comments2
    accounts << forwards3 + comments3

   weiboEvaluates = WeiboUserEvaluate.where("uid = ?",uid).first
  begin
   if weiboEvaluates.blank? || weiboEvaluates.origin_rate == -1
      weiboEvaluates = account.update_evaluates
    end
   rescue Exception =>e
    if e.message =~ /User does not exists!/
       csv << [uid]
        next
     else
       csv << [nil]
       next
     end
   end

   accounts << weiboEvaluates.origin_rate/100.0
   accounts << (weiboEvaluates.forward_average + weiboEvaluates.comment_average)/100.0
   accounts << WeiboForward.where("uid = ? and forward_uid = ? ",intel,uid).count
   accounts << WeiboComment.where("uid = ? and comment_uid = ? ",intel,uid).count
   accounts << WeiboMention.where("uid = ? and mention_uid = ? ",intel,uid).count
   csv << accounts
  end
end




#与 @英特尔中国互动次数的据项：主动@、转发、评论（范范）75人：2013年9月10日零点至10月24日零点。

#14人：2013年9月21日零点至10月11日零点。
filename = "data/转发 评论 互动.csv" #9.30零点-10.14零点 10.14零点-11.4零点
  intel = 2637370247
  title = %w{uid 转发  评论 互动 主动AT}
CSV.open filename,"wb" do |csv|
  csv << title
  path = File.join(Rails.root, "db/uid")
  start_time = '2014-04-21'
  end_time = '2014-04-28'
 File.open(path,"r").each do|uid|
   accounts = []
   uid = uid.strip
   accounts << uid
   forwardcount = WeiboForward.where("uid = ? and forward_uid = ? and forward_at between ? and ? ",intel,uid,start_time,end_time).count
   commentcount = WeiboComment.where("uid = ? and comment_uid = ? and comment_at between ? and ? ",intel,uid,start_time,end_time).count
   accounts <<  forwardcount
   accounts <<  commentcount
   accounts <<  forwardcount + commentcount
   accounts << WeiboMention.where("uid = ? and mention_uid = ? and mention_at between ? and ? ",intel,uid,start_time,end_time).count
   csv << accounts
end
end
#根据uid 更新活跃度表看
path = File.join(Rails.root, "db/uid")
 CSV.open "原创占比1.csv","wb" do |csv|
 csv << %w{uid 原创占比 }
 File.open(path,"r").each do|uid|
   uid = uid.strip
   puts uid
#debugger
   account = WeiboAccount.find_by_uid(uid)
   weiboEvaluates = WeiboUserEvaluate.where("uid = ?",uid).first#3859985338
begin
   if account.nil?
      ReportUtils.uids_save_weibo [uid]
      account = WeiboAccount.find_by_uid(uid)
    end

   if weiboEvaluates.blank?
   weiboEvaluates = account.update_evaluates
   end
   # #3605490284
 rescue Exception =>e
    if e.message =~ /User does not exists!/
       csv << [uid]
        next
     else
       csv << [nil]
       next
     end
   end
    csv << [uid,weiboEvaluates.origin_rate/100.0]
end
end


#根据uid 查 基本信息;
filename = "基本信息-现在是中国粉丝-2.csv"
task = GetUserTagsTask.new
CSV.open filename,"wb" do |csv|
path = File.join(Rails.root, "db/uid2")
 title = WeiboAccount.to_row_title(:full)
 csv << title
File.open(path,"r").each do|uid|
   uid = uid.strip
   puts uid
    begin
     account = task.load_weibo_user(uid)
     rescue Exception =>e
       if e.message =~ / does not exist!/
          csv << [uid]
          next
       end

     end
    if account.blank?
        csv << [uid]
        next
    end
    csv << account.to_row(:full) #+ [account.bi_followers_count]
    end
end
#根据nick查uid 查 基本信息 
filename = "信息补充1.csv"
task = GetUserTagsTask.new
CSV.open filename,"wb" do |csv|
path = File.join(Rails.root, "db/uid1")
 title = WeiboAccount.to_row_title(:full)
 csv << title
File.open(path,"r").each do|name|
   uid = ReportUtils.names_to_uids([name.strip],true).first
    accounts = []
  puts uid
    begin
     account = task.load_weibo_user(uid)
     rescue Exception =>e
       if e.message =~ / does not exist!/
          csv << [uid]
          next
       end

     end
    if account.blank?
        csv << [uid]
        next
    end
    csv << account.to_row(:full)
    end
end

 #共同关注
task = GetUserTagsTask.new
path = File.join(Rails.root, "db/uid")
uids = []
CSV.open("data/1428共同关注_1113.csv","wb"){|csv|
File.open(path,"r").each do|uid|
   uid = uid.strip
 uids << uid
 end
  uids.each{|uid|
    begin
      ids = task.api.friendships.friends_ids(uid:uid,count:5000).ids
      ids.each{|id|
        csv << [id]
      }
    rescue
    end
  }

} && nil


# in shell
cat data/1428共同关注_1113.csv |sort| uniq -c| sort -nr > data/1428共同关注_1113_uniq.csv
cat data/1428共同关注_1113_uniq.csv | awk '{if($1>500)print($0)}' > data/1428共同关注_1113_filtered.csv


#通过uid 查询微博互动人用户基本信息 weibo_id = WeiboMidUtil.str_to_mid url.split("/").last 
filename = "3740495698334499.csv"  #3637213449765372
CSV.open filename,"wb" do |csv|
path = File.join(Rails.root, "db/uid")
 title = WeiboAccount.to_row_title(:quality)
 csv << title #+title1
  peoples = []
forwards = WeiboForward.where("weibo_id = ? ",3740495698334499)
comments = WeiboComment.where("weibo_id = ? ",3740495698334499)
forwards.each do |line|
    peoples << line.forward_uid
  end
comments.each do |line|
    peoples << line.comment_uid
  end

 peoples.uniq.each do|uid|

    #account = WeiboAccount.find_by_uid(uid)
    #if account.blank?
      csv << [uid]
      #next
    #end
    #accounts = account.to_row(:quality)
    #csv << accounts
    end
end
#

filename = "范范-互动.csv" 
  task = GetUserTagsTask.new
  CSV.open filename,"wb" do |csv|
    csv << %w{url 评论数 	转发数  互动量 粉丝数}
    path = File.join(Rails.root,"db/url")#从file拿weibo_id
      File.open(path,"r").each do|line|
      url = line.strip

      puts url
   #debugger
      #weibo_id = WeiboMidUtil.str_to_mid url.split("/").last
       begin
       res = task.stable{task.api.statuses.show(id:url)}#http://weibo.com/2056744733/Ad6n2BxT4
       csv << [url,res.reposts_count,res.comments_count,res.reposts_count+res.comments_count,res.user.followers_count]
       rescue Exception =>e
          if e.message =~ / does not exist!/
          csv << [url]
          else
          raise e
          end
    end
  end
end

# 通过 weibo_id 查询和 中国 互动人信息 互动时间  weibo_id = WeiboMidUtil.str_to_mid url.split("/").last身份     
#uid = '2637370927'  3620997485861479  3620984902910437 3620586716693828      3620984902910437  
filename = "近500条微博的互动人信息.csv"
  CSV.open filename,"wb" do |csv|
    title = WeiboAccount.to_row_title(:default)
    title1 = ['是否是中国粉丝','关注中国时间']
    csv << title +title1
#3620546325922080 WeiboForward.where("weibo_id= ?",'3620546325922080').distinct(by_uid)
    path = File.join(Rails.root,"db/weibo_id")#从file拿weibo_id
    File.open(path,"r").each do|line|
    weibo_id = line.strip
    forwards = WeiboForward.where("weibo_id= ?",weibo_id)
    comments = WeiboComment.where("weibo_id= ?",weibo_id)
    intel = '2637370927'
    forwards.each{|forward|
      uid = forward.forward_uid
      a = WeiboAccount.find_by_uid(uid)
      next if a.nil?
      row = a.to_row
      rel = WeiboUserRelation.where(uid:intel,by_uid:uid).first
      rel = rel ? "是": "不是"
      row << rel
      row << forward.forward_at.strftime("%Y-%m-%d %H:%S")
      row << "转发"
      csv << row
    }
    comments.each{|comment|
      uid = comment.comment_uid
      a = WeiboAccount.find_by_uid(uid)
      next if a.nil?
      row = a.to_row
      puts row
      rel = WeiboUserRelation.where(uid:intel,by_uid:uid).first
      rel = rel.blank? ? "是": "不是"
      row << rel
      row << comment.comment_at.strftime("%Y-%m-%d %H:%S")
      row << "评论"
      csv << row
    }
  end

end
#通过uid的 keywords 从页码获得（张桢）     加     
filename = "keywords.csv"
path = File.join(Rails.root,"db/uid")
  url = "http://www.tfengyun.com/user.php?action=keywords&userid="
  CSV.open filename,"wb" do |csv|
    csv << %w{uid keywords}
    File.open(path,"r").each do|line|
        uid = line.strip
        res = Net::HTTP.get URI.parse(url+uid.to_s)
        keyword = JSON.parse(res)
        csv << [uid] +keyword['keywords']
    end
end

#范范根据uids 查 weibo_ids 是否互动了

 filename = "非粉丝与礼品帖产生互动的人数.csv" #非粉丝与礼品帖产生互动的人数
 CSV.open filename,"wb" do |csv|
    number = 0

    path = File.join(Rails.root,"db/uid1")
    path1 = File.join(Rails.root,"db/url")#从file拿weibo_id
      File.open(path,"r").each do|line|
          uid = line.strip
          File.open(path1,"r").each do|line|
          url = line.strip
          puts url
             weibo_id = WeiboMidUtil.str_to_mid url.split("/").last
             forwards = WeiboForward.where("weibo_id= ? and forward_uid = ? ",weibo_id,uid).count
             comments = WeiboComment.where("weibo_id= ? and comment_uid = ? ", weibo_id,uid).count
             if forwards > 0 || comments > 0
                  number+=1
                  break
              end
          end
      end
     csv << [number]
 end
 #根据uid查活跃度 接口更新活跃度提取   
  task = GetUserTagsTask.new
filename = "活跃度-补充-2.csv"
CSV.open filename,"wb" do |csv|
 csv << %w{uid 平均转发率 平均评论率 平均转发 平均评论 活跃度 原创占比 日均发帖量 近七天发贴量}
 path = File.join(Rails.root, "db/uid2")
 File.open(path,"r").each do|line|
 row = []
 uid = line.strip
 puts uid
  weiboEvaluates = WeiboUserEvaluate.where("uid = ?",uid).first
  if weiboEvaluates.nil? || weiboEvaluates.origin_rate == -1
    begin
    account = task.load_weibo_user(uid)
    weiboEvaluates= account.update_evaluates
    rescue IRB::Abort
          raise $!
    rescue Exception=>e
      puts e.message
      csv << [uid]
      next
    end
  end
  evaluates =   weiboEvaluates.forward_average + weiboEvaluates.comment_average
  puts evaluates
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
#范范根据uids 查 与中国互动次数

 
 filename = "非粉丝各帐号与中国互动的总次数.csv"
 CSV.open filename,"wb" do |csv|
    number = 0
    csv << %w{uid 20130909-20130915 20130916-20130922 20130923-20130929 20130930-20131006 20131007-20131013 20131014-20131020}
    path = File.join(Rails.root,"db/uid1")#从file拿weibo_id
      File.open(path,"r").each do|line|
          uid = line.strip

             forwards1 = WeiboForward.where("uid = ? and forward_uid = ? and forward_at between ? and ?",2637370927,uid,'2013-09-09','2013-09-16').count
             comments1 = WeiboComment.where("uid = ? and comment_uid = ? and comment_at between ? and ?",2637370927,uid,'2013-09-09','2013-09-16').count

             forwards2 = WeiboForward.where("uid = ? and forward_uid = ? and forward_at between ? and ?",2637370927,uid,'2013-09-16','2013-09-23').count
             comments2 = WeiboComment.where("uid = ? and comment_uid = ? and comment_at between ? and ?",2637370927,uid,'2013-09-16','2013-09-23').count

             forwards3 = WeiboForward.where("uid = ? and forward_uid = ? and forward_at between ? and ?",2637370927,uid,'2013-09-23','2013-09-30').count
             comments3 = WeiboComment.where("uid = ? and comment_uid = ? and comment_at between ? and ?",2637370927,uid,'2013-09-23','2013-09-30').count

             forwards4 = WeiboForward.where("uid = ? and forward_uid = ? and forward_at between ? and ?",2637370927,uid,'2013-09-30','2013-10-07').count
             comments4 = WeiboComment.where("uid = ? and comment_uid = ? and comment_at between ? and ?",2637370927,uid,'2013-09-30','2013-10-07').count

             forwards5 = WeiboForward.where("uid = ? and forward_uid = ? and forward_at between ? and ?",2637370927,uid,'2013-10-07','2013-10-14').count
             comments5 = WeiboComment.where("uid = ? and comment_uid = ? and comment_at between ? and ?",2637370927,uid,'2013-10-07','2013-10-14').count

             forwards6 = WeiboForward.where("uid = ? and forward_uid = ? and forward_at between ? and ?",2637370927,uid,'2013-10-14','2013-10-21').count
             comments6 = WeiboComment.where("uid = ? and comment_uid = ? and comment_at between ? and ?",2637370927,uid,'2013-10-14','2013-10-21').count
             csv << [uid,forwards1+comments1,forwards2+comments2,forwards3+comments3,forwards4+comments4,forwards5+comments5,forwards6+comments6]
      end

 end
# 找到 intel china 带蓝V和橙V粉丝里
task = GetUserTagsTask.new
page = 1
intel = 2637370927
filename = "data/intel_unfollows.csv"
row = []
title = WeiboAccount.to_row_title(:quality)
title1 = ['关注中国的时间']
CSV.open(filename,"wb"){|csv|

  csv << title + title1
  begin
    rels = WeiboUserRelation.where(uid:intel).paginate(page:page,per_page:1000).each{|rel|


      begin
        account = task.load_weibo_user(rel.by_uid)
        if account.verified_type>=0 && account.verified_type <= 7
        res = task.api.friendships.show(source_id:rel.by_uid,target_id:rel.uid)
        row = account.to_row(:quality)
        row << rel.follow_time
        csv << row if !res.source.following
        end
      rescue IRB::Abort
        raise $!
      rescue Exception=>e
        puts e.message
      end

    }
    puts page
    page += 1
  end while page <= rels.total_pages

}
#目前 英特尔积分平台 上 绑定微博的人  与@英特尔中国 发生转发、评论,at次数（张桢）  9月25日 00：00之前   在 10月30日 00：00之前
filename = "8月25日之后俩月.csv"
 path = File.join(Rails.root,"db/uid")
CSV.open filename,"wb" do |csv|
      csv << %w{uid  8月25日之 后 俩月转发  8月25日之 后 俩月评论  8月25日之 后 俩月at  }
      File.open(path,"r").each do|line|
       uid = line.strip
      forwards1 = WeiboForward.where("uid = ? and forward_uid = ? and forward_at between ? and ?",2637370927,uid,'2013-08-25','2013-10-26').count
      comments1 = WeiboComment.where("uid = ? and comment_uid = ? and comment_at between ? and ?",2637370927,uid,'2013-08-25','2013-10-26').count
      mention = WeiboMention.where("uid = ? and mention_uid = ? and mention_at between ? and ?",2637370927,uid,'2013-08-25','2013-10-26').count

      csv << [uid,forwards1,comments1,mention]
      end
end
#根据uid查活跃度 接口更新活跃度提取

filename = "活跃度-中国-后备-.csv"
CSV.open filename,"wb" do |csv|
  csv << %w{uid 平均转发率 平均评论率 平均转发 平均评论 活跃度 原创占比 日均发帖量 近七天发贴量}
path = File.join(Rails.root, "db/uid")
 File.open(path,"r").each do|line|
 row = []
 uid = line.strip
 puts uid
 #weiboEvaluates = WeiboUserEvaluate.where("uid = ?",uid).first
 #if weiboEvaluates.nil? || weiboEvaluates.origin_rate == -1
  begin
  weiboEvaluates= WeiboAccount.find_by_uid(uid).update_evaluates
  rescue IRB::Abort
        raise $!
      rescue Exception=>e
        if e.message =~ / for this time/
          sleep(300)
        end
        puts e.message
        csv << [uid]
        next
      end
 #end
 evaluates =   weiboEvaluates.forward_average + weiboEvaluates.comment_average
 puts evaluates
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
#根据nick name 查活跃度
 #uids = []
 path = File.join(Rails.root, "db/uid")
 #File.open(path,"r").each do|line|
   #  nick = line.strip
    # uids << ReportUtils.names_to_uids([nick],true).first
 #end
filename = "9W活跃度.csv"
CSV.open filename,"wb" do |csv|
csv << %w{uid 平均转发率 平均评论率 平均转发 平均评论 活跃度 原创占比}
 File.open(path,"r").each do|line|
   row = []
   uid = line.strip
   puts uid
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
   evaluates =   weiboEvaluates.forward_average + weiboEvaluates.comment_average
   puts evaluates
   row << uid
   row << weiboEvaluates.forward_rate/100.0
   row << weiboEvaluates.forward_rate/100.0
   row << weiboEvaluates.forward_average/100.0
   row << weiboEvaluates.comment_average/100.0
   row << evaluates/100.0
   row << weiboEvaluates.origin_rate
   csv << row
 end
end
# 把 uid 放到 数组里面
  uids = []
 path = File.join(Rails.root, "db/name")
 File.open(path,"r").each do|line|
     uid = line.strip
     uids << uid
 end
# urls互动人信息列表、总的互动次数；(范范)
#uid = '2637370927'
filename = "超级本二月互动ren信息列表.csv"
  CSV.open filename,"wb" do |csv|
weibo_ids =[]
    title = WeiboAccount.to_row_title(:simple)
   # title1 = %w{与被本类微博互动次数}
    csv <<   title# + title1
#3620546325922080 WeiboForward.where("weibo_id= ?",'3620546325922080').distinct(by_uid)
    interactive = []
=begin
 path = File.join(Rails.root, "db/url")
 File.open(path,"r").each do|line|
     url = line.strip
     weibo_id = WeiboMidUtil.str_to_mid url.split("/").last
     weibo_ids <<  weibo_id
 end
=end
    #weibo_ids.each{|weibo_id|
    forwards = WeiboForward.where("uid = ? and forward_at between ? and ?",2637370247,'2014-02-01','2014-02-18')
    comments = WeiboComment.where("uid = ? and comment_at between ? and ?",2637370247,'2014-02-01','2014-02-18')
    #intel = '2637370927'
    forwards.each{|forward|
      interactive << forward.forward_uid
    }
     comments.each{|comment|
       interactive << comment.comment_uid
    }
  #}
    interactive.uniq.each{|uid|
      row = []
      a = WeiboAccount.find_by_uid(uid)
      next if a.nil?
      row = a.to_row(:simple)
      #forwardcount = WeiboForward.where("weibo_id in (?) and forward_uid = ?",weibo_ids,uid).count
      #commentscount = WeiboComment.where("weibo_id in (?) and comment_uid = ?",weibo_ids,uid).count
      #row <<  forwardcount + commentscount
      csv << row
    }

end
#根据 url导出 forward_id 二次转发（大文）
  filename = "weibo_id内容.csv"
 CSV.open filename,"wb" do |csv|
    csv << %w{MID UID  内容 创建时间 主微薄二次转发数}
#3620546325922080 WeiboForward.where("weibo_id= ?",'3620546325922080').distinct(by_uid)
    weibo_ids = ['http://weibo.com/2637370927/AfC5GEYq0'].map{|url| WeiboMidUtil.str_to_mid url.split("/").last}
    weibo_ids.each{|weibo_id|
    forwards = WeiboForward.where("weibo_id= ?",weibo_id)
    forwards.each{|forward|
     weibo_id = forward.forward_id
     puts weibo_id
      forward = MForward.find weibo_id
      next if forward.nil? || forward.retweeted_status['user'].nil?

      csv << [forward['user_id'],forward['text'],forward['created_at'],forward.retweeted_status['reposts_count'],forward.retweeted_status['comments_count']]
    }
}
end
#根据weibo_id 查二次转发
filename = "二次转发.csv"
  task = GetUserTagsTask.new
  CSV.open filename,"wb" do |csv|
    csv << %w{weibo_id  转发数 评论数  互动}
    path = File.join(Rails.root,"db/weibo_id")#从file拿weibo_id
      File.open(path,"r").each do|line|
      weibo_id = line.strip
      puts weibo_id
       begin
       res = task.stable{task.api.statuses.show(id:weibo_id)}#http://weibo.com/2056744733/Ad6n2BxT4
       csv << [weibo_id,res.reposts_count,res.comments_count,res.reposts_count+res.comments_count,res.text,res.user.id]
       rescue Exception =>e
          if e.message =~ / does not exist!/
          csv << [weibo_id]
          else
          raise e
          end
        end
  end
end
 #新粉丝质量分布

filename = "新粉丝质量分布csv"
  CSV.open filename,"wb" do |csv|
      ar = []
      compare_uids =   ReportUtils.names_to_uids(%w{英特尔商用频道 思科数据中心 ThinkPad 首席智库 微软云计算},true)
     @compare_uids = (compare_uids||[]).map(&:to_s).uniq
     @end_date =  '2013-10-01'
     @start_date =  '2013-07-01'
     @compare_uids.each_with_index{|uid,idx|
      info = @compares[uid][:infos]
      row = [info.screen_name, 0,0,0,0,0,0]
      records = WeiboUserRelation.find_by_sql <<-EOF
        select  relation.uid,
        case
        when acc.followers_count <=10 then 1
        when acc.followers_count >10 and acc.followers_count <= 50  then 2
        when acc.followers_count >50 and acc.followers_count <= 100  then 3
        when acc.followers_count >100 and acc.followers_count <= 500  then 4
        when acc.followers_count >500 and acc.followers_count <= 5000  then 5
        when acc.followers_count >5000  then 6
        END  fans_level ,
          count(1) as counts
        from  weibo_user_relations relation
        left join weibo_accounts acc on acc.uid = relation.by_uid
        where relation.follow_time>= '#{@start_date}'  and relation.follow_time < '#{@end_date}'
        and relation.uid = #{uid}

         group by  relation.uid, fans_level
      EOF
      total = records.sum(&:counts)
      real_total = records.sum{|record| record.fans_level ? record.counts : 0}
      records.each{|record|
        next if record.fans_level.blank?
        row[record.fans_level] = "#{(record.counts.to_f / real_total * 100).round(2)}%"
      }
      row << total
      ar << row

    }
    title = %w{微博昵称   0-10  11-50  51-100  101-500 501-5000  >5000 total}
  csv << title

    ar.each{|a|
     csv << a
    }

  end


#接口提取 api 通过url 查出互动人信息列表(大文) 
filename = "互动人信息-8.csv"
  task = GetUserTagsTask.new
  CSV.open filename,"wb" do |csv|
    csv << WeiboAccount.to_row_title(:full)
    path = File.join(Rails.root,"db/url7")#从file拿weibo_id
      @all_interactive = []
      File.open(path,"r").each do|line|
      url = line.strip
      weibo_id = WeiboMidUtil.str_to_mid url.split("/").last#http://weibo.com/1902520272/AdgAY5a54  http://weibo.com/2637370927/AdYvTsFCh
#http://weibo.com/2803301701/AiivFxLc4
      puts url
      forward = []
      comment = []
      page = 1
      processing = true
        begin
          begin
            res = task.stable{task.api.statuses.repost_timeline(weibo_id,count:200,page:page)}#根据weibo_id查转发人信息count
#debugger
              if !res.blank?
                 res.reposts.each do |line|
                   row = []
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

                 end
               else
                processing = false
                break
               end
           rescue Exception=>e
            puts e.message
            next
           end
           page+=1
        end while processing == true
#debugger
      interactive = forward+comment
      @all_interactive += interactive
    end
    @all_interactive.each do |uid|
         begin
           account  = task.load_weibo_user(uid)
         rescue Exception=>e
            puts e.message
            next
          end
         csv << account.to_row(:full)
     end
  end
#接口提取 api 通过url 查出互动人信息列表(大文) http://weibo.com/2637370927/AkwdM2B9r 
 filename = "data/国药集团1互动人信息列表1.csv"
  #@compare_uids = {}
  target_id = '2951251611'
  task = GetUserTagsTask.new
  CSV.open filename,"wb" do |csv|
    csv << WeiboAccount.to_row_title(:full) +['中国互动次数','是否是国药集团1粉丝']

        @compare_uids.keys.each do |uid|
          puts uid
          row = []
         begin
          account  = task.load_weibo_user(uid)
         rescue Exception=>e
            if e.message =~ /User does not exists!/
                csv << [uid]
                 next
            end
         end
          row = account.to_row(:full)
          row << @compare_uids[uid]
          begin
          res = task.api.friendships.show(source_id:uid,target_id:target_id)
          rescue Exception=>e
          row << ''
          csv << row
          next
          end
          res.source.following ? row << "是": row << "否"
          csv << row
     end
  end
#



# 根据 uid 查 近100条微博中转发蓝V用户的占转发比例 转发蓝V的微博数  转发蓝V的人。（范范）
filename = "查近100条微博中转发蓝V用户的占转发比例-超级本.csv"
  task = GetUserTagsTask.new
  CSV.open filename,"wb" do |csv|
    csv << %w{uid 近100条微博中转发蓝V用户的占总微博比例 近100条微博中转发蓝V用户的占转发比例 是转发蓝V的微博数  转发蓝V的人 平均回复率 }
    path = File.join(Rails.root,"db/uid")#从file拿weibo_id
      File.open(path,"r").each do|line|
      uid = line.strip
     puts uid
    forwardnumber = 0
    commentnumber = 0
    #a.update_attributes(forward_rate:rnd_code)
    begin
    res = task.stable{task.api.statuses.user_timeline(uid:uid.to_s,count:100)}
     rescue Exception=>e
            csv << [uid]
            next
      end
    statuses = res.statuses
    forwardcount = 0
    forwardvuid = []
    statuses.each{|status|
#debugger
      if !status.retweeted_status.blank?
        next if status.retweeted_status.user.blank?
          forwardcount +=1
          if status.retweeted_status.user.verified
              forwardnumber += status.reposts_count
              commentnumber += status.comments_count
              forwardvuid << status.retweeted_status.user.id
           end
       end
    }

      if forwardcount == 0
         forwardcount = 1
      end
     if forwardvuid.size == 0
         number = 0
       else
        number = (forwardnumber+commentnumber)/forwardvuid.size.to_f
     end
     if statuses.size == 0
         statusesnumber = 0
       else
        statusesnumber = forwardvuid.size/statuses.size.to_f
     end

      csv << [uid,statusesnumber,forwardvuid.size/forwardcount.to_f,forwardvuid.size,forwardvuid.uniq.size,number]#

    end
end


#根据 文件里面时间  name  查 时间 那天粉丝总数(范范)
CSV.open("范范-粉丝总数-XL.csv","wb") do |csv|
  title =  %w{英特尔中国	 英特尔知IN 	英特尔商用频道 	英特尔芯品汇 	Qualcomm中国 	Snapdragon骁龙 	联想	 ThinkPad	 东芝电脑 	戴尔中国	 ASUS华硕	 惠普电脑 	杜蕾斯官方微博	 戴尔促销	 ARM中国	 AMD中国	 Acer宏碁  饭团AMD  小米手机  可口可乐  星巴克中国  小米公司 超能双雄}
  #%w{英特尔中国	 英特尔知IN	 英特尔商用频道	 英特尔芯品汇 	Qualcomm中国 	Snapdragon骁龙 	联想	 ThinkPad 	东芝电脑	 戴尔中国	 ASUS华硕	 惠普电脑 	  杜蕾斯官方微博  	戴尔促销	  ARM中国	  AMD中国	  Acer宏碁	  饭团AMD	  小米手机	  可口可乐	  星巴克中国 	 小米公司	  超能双雄}
  #%w{英特尔中国	 英特尔中国天天事 	英特尔商用频道 	英特尔芯品汇 	Qualcomm中国 	Snapdragon骁龙 	联想	 ThinkPad	 东芝电脑 	戴尔中国	 ASUS华硕	 惠普电脑 	杜蕾斯官方微博	 戴尔促销	 ARM中国	 AMD中国	 Acer宏碁}
csv << title
path = File.join(Rails.root,"db/date")
#path1 = File.join(Rails.root,"db/name")#2013-08-31 英特尔中国 杜蕾斯官方微博 C033FAB1571932A8A5644D0977C7281E
  File.open(path,"r").each do|date|

   date1 = date.strip
   row = []
  title.each do|name|
   nick = name.strip
   openid = ReportUtils.names_to_uids([nick],true)
puts openid
  weibo =  WeiboAccountSnapDaily.where("uid = ? and date = ?",openid[0],date1)
  weibo.blank?? row << " ": row << weibo[0].followers_count
end
 csv << row + [date1]
end
end
#根据 文件里面时间  name  查 时间 那天粉丝总数腾讯(范范) 
CSV.open("范范-粉丝总数-tq.csv","wb") do |csv|
title = %w{英特尔中国 	戴尔中国	 联想	 Snapdragon骁龙	 三星电子 	杜蕾斯 	易迅网 }
csv << title
path = File.join(Rails.root,"db/date")
  File.open(path,"r").each do|date|
   date1 = date.strip
   row = []
  ["0B6A468C0642625453023BFB0D1B8570", "A6AD5631683AA595967D945FB78DB61C", 
                 "2B7C9EE9B6878DF1E1C4EC28ED7EEE15", "997B01BB7EA298442DC62C8912FF57AD", 
                 "43AFF8C3E6A0A98B653F56BE78535199", "334FF584F2A77237CDE67F58B1DA20CF",
                  "8553E3309EDF8235F4CB846C6396DB35"].each do|openid|
puts openid
  weibo =  TqqAccountSnapDaily.where("openid = ? and date = ?",openid,date1)
  weibo.blank?? row << " ": row << weibo[0].followers_count
end
 csv << row + [date1]
end
end
#api 根据uid  查这个人
   filename = "12ren-weibo_id.csv"
    CSV.open(filename,"wb"){|csv|
      csv << %w{uid  原创数 原创微博总转发 原创微博总评论 转发英特尔次数  评论英特尔次数}
     path = File.join(Rails.root, "db/uid")
   task = GetUserTagsTask.new
    File.open(path,"r").each{|uid|
        uid = uid.strip
          begin
            res = task.stable{task.api.statuses.user_timeline(uid:uid,count:100, page:1)}
            res['statuses'].each{|w|
                 csv << [w.id]
            }
          rescue Exception=>e
            puts e.message
          end
      }
    }
#监控帐号 信息查询 只要地域（范范）
filename = "中国全量粉丝地域.csv"
CSV.open(filename,"wb"){|csv|
    csv << %w{地域}
    relation = WeiboUserRelation.where("uid = ?",'2637370927')
    relation.each do |line|
puts line
       weibo = WeiboAccount.find_by_uid(line.by_uid)
       next if weibo.blank?
       next if weibo.location.blank?
       csv << [weibo.location]
    end
}

#打印KOL ITDM 列表（张桢）

filename = "itdm与与商用频道.csv"
CSV.open(filename,"wb"){|csv|
  csv << %w{uid 与商用频道转发 与商用频道评论 与商用频道互动}
=begin
     itdms = WeiboUserAttribute.find_by_sql <<-EOF
      select  uid uid  from weibo_user_attributes where  keyword_id = 77
    EOF
    kols = WeiboUserAttribute.find_by_sql <<-EOF
     select  uid uid  from weibo_user_attributes where  keyword_id = 85 or keyword_id= 86 or keyword_id = 88 or keyword_id = 90
    EOF
=end
path = File.join(Rails.root, "db/uid1")

     File.open(path,"r").each do |line|
       uid = line.strip
       forwards = WeiboForward.where("uid = ? and forward_uid = ?",2295615873,uid).count
      comments = WeiboComment.where("uid = ? and comment_uid = ?",2295615873,uid).count
       csv << [uid,forwards,comments,forwards+comments]
     end

    #File.open(path,"r").each do |line|
     #forwards = WeiboForward.where("uid = ? and forward_uid = ?",2295615873,uid).count
      #comments = WeiboComment.where("uid = ? and comment_uid = ?",2295615873,uid).count
      # csv << [uid,forwards,comments,forwards+comments]
    #end

}
#根据一些人都uid 查看与 一个监控帐号互动次数（张桢）
filename = "与中国互动次数1.csv"
CSV.open(filename,"wb"){|csv|
  csv << %w{uid 转发中国 评论中国 互动}
  path = File.join(Rails.root, "db/uid1")
  File.open(path,"r").each do |line|
    uid = line.strip
    forwards = WeiboForward.where("uid = ? and forward_uid = ? and forward_at between ? and ?",2637370927,uid,'2013-12-21','2013-12-24').count
    comments = WeiboComment.where("uid = ? and comment_uid = ? and comment_at between ? and ?",2637370927,uid,'2013-12-21','2013-12-24').count
    csv << [uid,forwards,comments,forwards+comments]
  end
}

# 根据 uid 查 近500条微博 查。  
=begin
跑@英特尔中国近500条微博的全量互动帐号的列表，并跑数据项：帐号自身的粉丝数&自身近100条微博的平均转发率；
=end
  filename = " 查 近100条微博信息.csv"
  task = GetUserTagsTask.new
  CSV.open filename,"wb" do |csv|
    csv << %w{MID  }
  path = File.join(Rails.root, "db/uid")
  File.open(path,"r").each do |line|
    uid = line.strip
    begin
    res = task.stable{task.api.statuses.user_timeline(uid:uid,count:100,page:1)}
     rescue Exception=>e
            csv << [uid]
            next
    end

    statuses = res.statuses
    statuses.each{|status|
     str = task.mid_to_str status.mid
     csv << [status.id,status.created_at.to_s.strftime("%Y-%m-%d %H:%S"),status.text,'http://weibo.com/'+str.to_s]
    }

   end
end


#根据url查互动信息人（大文）基本信息
  filename = "查互动信息人基本信息1.csv"
  path = File.join(Rails.root,"db/url")#从file拿weibo_id
  @compare_uids = {}
  CSV.open filename,"wb" do |csv|
  debugger
    task = GetUserTagsTask.new
    csv << WeiboAccount.to_row_title(:full) + #['中国互动次数','关注时间','是否是商用频道']
      File.open(path,"r").each do|url|
        url = url.strip
        weibo_id = WeiboMidUtil.str_to_mid url.split("/").last
        commentcount = 0
        forward_weibo = WeiboForward.where("weibo_id = ? ",weibo_id)
        #forward_weibo = forward_weibo.where("forward_at >= ? ", start_time)
        #forward_weibo = forward_weibo.where("forward_at < ? ", end_time)
        comment_weibo = WeiboComment.where("weibo_id = ? ",weibo_id)
        #comment_weibo = comment_weibo.where("comment_at >= ?",start_time)
       # comment_weibo = comment_weibo.where("comment_at < ? ",end_time)
        comment_weibo.each do |comment|
            @compare_uids[comment.comment_uid.to_s] ||= 1
            !@compare_uids[comment.comment_uid.to_s].nil? if @compare_uids[comment.comment_uid.to_s]+=1
        end
        forward_weibo.each do |forward|
          @compare_uids[forward.forward_uid.to_s] ||= 1
          !@compare_uids[forward.forward_uid.to_s].nil? if @compare_uids[forward.forward_uid.to_s]+=1
        end
      end
       @compare_uids.keys.each do |uid|
          puts uid
          row = []
         begin
          account  = task.load_weibo_user(uid)
         rescue Exception=>e
            if e.message =~ /User does not exists!/
                csv << [uid]
                 next
            end
         end
          row = account.to_row(:full)
=begin
          row << @compare_uids[uid]

          rel = WeiboUserRelation.where(uid:2295615873,by_uid:uid).first
          rel.nil? ? row << '' : row << rel.follow_time
          rel = rel.nil? ? "否": "是"
          row << rel
=end
          csv << row
         end

  end
# 监控粉丝列表
 filename = "data/中国粉丝列.csv"
    task = GetUserTagsTask.new
 CSV.open(filename,"wb"){|csv|
      csv << %w{ UID 昵称 位置 性别 粉丝 关注 微博 注册时间 认证类型 认证原因 标签  关注时间}
          relations = WeiboUserRelation.where("uid = ? and follow_time between ? and ?",2637370927,'2014-02-01','2014-02-25')
          relations.each{|rel|
            uid = rel.by_uid
            begin
              a  = task.load_weibo_user(uid)
            rescue Exception=>e
              if e.message =~ /User does not exists!/
                csv << [uid]
                 next
              end
            end
            next if a.nil? # || a.forward_rate.nil? || a.forward_rate < 0
            row = a.to_row(:full)
            follow_time = rel.follow_time ? rel.follow_time.strftime("%Y-%m-%d %H:%M") : nil
            row << follow_time
            csv << row
          }
}

select count(1)
        from (
          select uid,from_uid, sum(snap.forwarded_count)  forwarded_count, sum(snap.commented_count) commented_count, sum(snap.forwarded_count)+sum(snap.commented_count) interacted_count
          from weibo_user_interaction_snap_dailies snap
          where snap.date >= '2013-11-25' and snap.date < '2013-12-02'
          and snap.uid = 2637370927

          group by snap.uid, snap.from_uid
          order by snap.uid , sum(snap.forwarded_count)+sum(snap.commented_count) desc
          limit 200000
        ) as snap
        left join weibo_accounts users on users.uid = snap.from_uid
        where users.followers_count >= 2000

 select count(1)
        from weibo_user_relations relations
        left join weibo_accounts users on users.uid = relations.by_uid
        left join weibo_user_interaction_snap_dailies interacts on  interacts.from_uid=relations.by_uid
                  and interacts.uid = 2637370927
                  and interacts.date >= '2013-11-25' and interacts.date < '2013-12-02'
        where relations.follow_time >= '2013-11-25' and relations.follow_time < '2013-12-02' and users.followers_count >=2000
        and relations.uid = 2637370927
        group by relations.by_uid
        order by users.followers_count DESC

filename = "data/新增粉丝创建时间.csv"
 CSV.open(filename,"wb"){|csv|
      csv << %w{昵称 创建年份  认证类型  }#加一列空    #users.screen_name,users.created_at created_at,users.verified_type verified_type
      records = WeiboUserRelation.find_by_sql <<-EOF
        select
        users.screen_name,users.created_at created_at,users.verified_type verified_type
        from weibo_user_relations relations
        left join weibo_accounts users on users.uid = relations.by_uid
        where relations.follow_time >= '2013-11-25' and relations.follow_time < '2013-12-02'
        and relations.uid = 2637370927
      EOF
      verified_types = {
      -1 => "未认证",
      0 =>"名人",
      1 =>"政府",
      2 =>"企业",
      3 =>"媒体",
      4 =>"校园",
      5 =>"网站",
      6 =>"应用",
      7 =>"团体（机构）",
      10 => "微博女郎",
      200 =>"未审核达人",
      220 =>"达人",
    }

    verified_type_goups = {
      -1 => "草根",
      0 =>"橙V",
      1 =>"蓝V",
      2 =>"蓝V",
      3 =>"蓝V",
      4 =>"蓝V",
      5 =>"蓝V",
      6 =>"蓝V",
      7 =>"蓝V",
      200 =>"达人",
      220 =>"达人",
    }

      records.each_with_index{|record,index|
        type = verified_types[record.verified_type]
        group = verified_type_goups[record.verified_type]
        verified_type = [type,group]
        csv << [record.screen_name,record.created_at,verified_type*',']
      }
}
#更新粉丝信息
      records = WeiboUserRelation.find_by_sql <<-EOF
        select
        by_uid
        from weibo_user_relations
        where follow_time >= '2013-11-25' and  follow_time < '2013-12-02'
        and  uid = 2637370927
      EOF
      number = 1
      records.each_with_index{|record,index|
       puts "第#{number}#{index}"
       begin
          account  = task.load_weibo_user(record.by_uid)
         rescue Exception=>e
            if e.message =~ /User does not exists!/
                 next
            end
         end
      }
    #根据uid更新粉丝信息 
path = File.join(Rails.root, "db/uid")
File.open(path,"r").each do |uid|
  uid = uid.strip
      records = WeiboUserRelation.find_by_sql <<-EOF
        select
        by_uid
        from weibo_user_relations
        where follow_time >= '2013-11-25' and  follow_time < '2013-12-02'
        and  uid = 2637370927
      EOF
      number = 1
      records.each_with_index{|record,index|
       puts "第#{number}#{index}"
       begin
          account  = task.load_weibo_user(record.by_uid)
         rescue Exception=>e
            if e.message =~ /User does not exists!/
                 next
            end
         end
      }
end

#
#一些人给监控帐号互动次数（大鱼）汤臣倍健营养家 2290417792 
filename = "互动次数-频道-1.csv"  #3637213449765372
CSV.open filename,"wb" do |csv|
csv << %w{uid 转发 评论 互动数}
start_time = '2014-01-01'
end_time = '2014-07-01'
intel = 2295615873#2295615873   #2637370247 3869439663
path = File.join(Rails.root, "db/uid")
File.open(path,"r").each do |uid|
uid = uid.strip
forwards = WeiboForward.where("uid = ? and forward_uid = ? and forward_at between ? and ?",intel,uid,start_time,end_time).count
comments = WeiboComment.where("uid = ? and comment_uid = ? and comment_at between ? and ?",intel,uid,start_time,end_time).count
#forwards = WeiboForward.where("uid = ? and forward_uid = ? ",intel,uid ).count
#comments = WeiboComment.where("uid = ? and comment_uid = ? ",intel,uid ).count
csv << [uid,forwards,comments,forwards+comments]
end
end

#转发 评论 主动AT 次数 
filename = "互动AT次数2014.csv"  #3637213449765372
CSV.open filename,"wb" do |csv|
  csv << %w{uid 转发 评论 主动@}
  start_time = '2014-01-01'
  end_time = '2014-03-18'
  intel = 2637370927 #2295615873   #2637370247 3869439663 2637370927,
  path = File.join(Rails.root, "db/uid")
  File.open(path,"r").each do |uid|
     uid = uid.strip
     comments = WeiboComment.where("uid = ? and comment_uid = ? and comment_at between ?   and ?",intel,uid,start_time,end_time).count
     forwards = WeiboForward.where("uid = ? and forward_uid = ? and forward_at between ?   and ?",intel,uid,start_time,end_time).count
     mention = WeiboMention.where("uid = ? and mention_uid = ? and mention_at between ?   and ?",intel,uid,start_time,end_time).count
     csv << [uid,forwards,comments,mention]
  end

end
filename = "互动次数-7.csv"  #3637213449765372
CSV.open filename,"wb" do |csv|
csv << %w{uid 转发 评论 互动数}
intel = 1747360663#2637370927#2295615873   #2637370247
path = File.join(Rails.root, "db/name")
File.open(path,"r").each do |name|
uid = ReportUtils.names_to_uids([name.strip],true).first
#forwards = WeiboForward.where("uid = ? and forward_uid = ? and forward_at between ? and ?",intel,uid,'2014-01-01','2014-02-01').count
#comments = WeiboComment.where("uid = ? and comment_uid = ? and comment_at between ? and ?",intel,uid,'2014-01-01','2014-02-01').count
forwards = WeiboForward.where("uid = ? and forward_uid = ? ",intel,uid ).count
comments = WeiboComment.where("uid = ? and comment_uid = ? ",intel,uid ).count
csv << [uid,forwards,comments,forwards+comments]
end
end
#一些人和微博静参与人数(范范) 
 filename = "静参与人数1.csv"
 task = GetUserTagsTask.new
CSV.open filename,"wb" do |csv|
csv << %w{url 静参与人数}
    path = File.join(Rails.root,"db/url")
      @all_interactive = []
      File.open(path,"r").each do|line|
      url = line.strip
      weibo_id = WeiboMidUtil.str_to_mid url.split("/").last
      puts url
      forward = []
      comment = []
      page = 1
      processing = true
        begin
          begin
            res = task.stable{task.api.statuses.repost_timeline(weibo_id.to_s,count:200,page:page)}
              if !res.blank?
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
            res = task.stable{task.api.comments.show(weibo_id,count:200,page:page)}
              if !res.comments.blank?
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
      csv << [url,interactive.uniq.size]
      #@all_interactive += interactive
    end

CSV.open filename,"wb" do |csv|
csv << %w{静参与人数}
path1 = File.join(Rails.root, "db/uid")
number  = 0
File.open(path1,"r").each do |uid|

  uid = uid.strip
  number +=1 if @all_interactive.uniq.include?(uid.to_i)
end
csv << [number]
number
end


#查 一批人uids 是一些人粉丝的人数（范范）放入uid
filename = "粉的人.csv"
task = GetUserTagsTask.new
path = File.join(Rails.root,"db/uid")
path1 = File.join(Rails.root,"db/uid1")
CSV.open filename,"wb" do |csv|
csv << %w{uid number}
  File.open(path,"r").each do|line|
    target_uid = line.strip
    number = 0
    File.open(path1,"r").each do|line|
      uid = line.strip
      begin
        res = task.api.friendships.show(source_id:uid,target_id:target_uid)
      rescue Exception=>e
        next
      end
      number+=1 if res.source.following
    end
    csv << [target_uid,number]
  end
end
#



#一对多判断是否粉丝（范范）.xlsx 
filename = "isweibo.csv"
task = GetUserTagsTask.new
CSV.open filename,"wb" do |csv|
  path = File.join(Rails.root,"db/uid1")
  path1 = File.join(Rails.root,"db/uid")
  File.open(path1,"r").each do|line|
    name = line.strip
    csv <<  ['uid','是否是'+name+'粉丝']
    target_id = name #ReportUtils.names_to_uids([name],true)
    File.open(path,"r").each do|line|
      uid = line.strip
      begin
        res = task.api.friendships.show(source_id:uid,target_id:target_id)
      rescue Exception=>e
        puts e.message
        csv << [uid]
        next
      end
      csv << [uid,res.source.following ? "是":"否"]
    end
  end
end
#根据时间统计互动粉丝数 (范范)1785529887 
uids = ["2637370247", "2637370927", "1340241374", "2295615873", "1738056157", "2619244577", "2183473425", "1617785922", "1765189187", "1687053504", "1747360663", "1847000261", "1942473263", "2216786767", "1883832215", "1775695331"]
filename = "统计互动粉丝数.csv"
start_time = '2014-04-22'
end_time = '2014-04-23'
CSV.open filename,"wb" do |csv|
  csv << %w{UID 昵称 互动粉丝总数 互动新粉丝数}
  uids.each do |line|
    intel = line
    fans = []
    newfans = []
    forwards = WeiboForward.where("uid = ?  and forward_at between ? and ? ",intel,start_time,end_time)
    comments = WeiboComment.where("uid = ?  and comment_at between ? and ? ",intel,start_time,end_time)
    forwards.each{|forward|
      uid = forward.forward_uid
      rel = WeiboUserRelation.where(uid:intel,by_uid:uid).first
      rel = rel ? (
              rel.follow_time ? (
                rel.follow_time >= start_time.to_date ? "新" : "老"
              ) : "老"
            ) : ""
      if (rel == "老")||(rel == "新")
         fans << uid
      end
      if (rel == "新")
         newfans << uid
      end
    }
    comments.each{|comment|
      uid = comment.comment_uid
      rel = WeiboUserRelation.where(uid:intel,by_uid:uid).first
      rel = rel ? (
              rel.follow_time ? (
                rel.follow_time >= start_time.to_date ? "新" : "老"
              ) : "老"
            ) : ""
      if (rel == "老")||(rel == "新")
         fans << uid
      end
      if (rel == "新")
         newfans << uid
      end
    }
    account = WeiboAccount.find_by_uid(intel)
    csv << [intel,account.screen_name,fans.uniq.size,newfans.uniq.size]
  end
end
#接口查基本信息（范范）互粉数英特尔
filename = "接口查基本信息.csv"
task = GetUserTagsTask.new
CSV.open filename,"wb" do |csv|
csv << ["UID", "昵称", "位置", "性别", "粉丝", "关注", "微博","互粉数","注册时间", "认证信息", "认证原因","互粉数"]
path = File.join(Rails.root,"db/uid1")
File.open(path,"r").each do|line|
     row = []
     uid = line.strip
     begin #解决异常
         res = task.stable{task.api.users.show(uid:uid)}
         if !res.blank?
            row << uid
            row << res.screen_name
            row << res.location
            value = {'m'=>'男','f'=>'女','n'=>'未知'}
            row << value[res.gender]
            row << res.followers_count
            row << res.friends_count
            row << res.statuses_count
            row << res.bi_followers_count
            row << Time.parse(res.created_at)
            row << res.verified ? '是' : '否'
            row << res.verified_reason
            row << res.bi_followers_count
         end
      rescue Exception=>e
         if e.message =~ /User does not exists!/
            row << [uid]
         else
            row << [uid]
         end
      end
     csv << row
end
end
#晒取内容包含 一个字符（大文）
filename = "晒取内容.csv"
CSV.open filename,"wb" do |csv|
 path = File.join(Rails.root,"db/name")
 csv << %w{weibo_id 内容 是否三次转发}
 File.open(path,"r").each do|name|
    name = name.strip
    name.split('@').each do |line|
    csv << [line]
    end
 end
end
#随机提取一些uid (大鱼)
filename = "随机生成的uid.csv"
CSV.open filename,"wb" do |csv|
   path = File.join(Rails.root,"db/uid")
   keywords = {}
   uids = []
   File.open(path,"r").each do|uid|
      uid = uid.strip
      uids << uid
   end
   processing = true
   chars = ("0".."9").to_a#生成0至9的字符数组#["0","1","2","3","4","5","6","7","8","9"]
   begin
     newpass = ""
     1.upto(uids.size.to_s.size) { |i| newpass << chars[rand(chars.size-1)] }
     next if newpass.to_i > uids.size
     keywords[newpass] ||= 1
     !keywords[newpass].nil? if keywords[newpass]+=1
     if keywords.keys.size == 500
        processing = false
     end
   end while processing == true
   keywords.keys.each do |line|
      csv << [line]
   end
end
## 每小时发微博分布（近7天）(范范)
@uids=[2637370927,1340241374,2295615873,2637370247,1738056157,
2619244577,2183473425,1617785922,1765189187,
1687053504,1747360663,1847000261,1942473263,1785529887,2216786767,1883832215,1775695331,2030206793]
@uids.each do |uid|
 name = WeiboAccount.find_by_uid(uid).screen_name
 filename = "#{name}每小时发微博分布（2013）.csv"
CSV.open filename,"wb" do |csv|
   csv << %w{时刻 微博数 转发数 评论数 互动数 新粉丝}
   @uid = uid
   @start_date = '2013-07-01'
   @end_date = '2014-01-01'
    records = WeiboContentCountSnapHourly.find_by_sql <<EOF
      select content_snap.hour,sum(content_snap.new_statuses_count) new_statuses_count,
              sum(content_snap.be_commented_count) commented,
              sum(content_snap.be_forwarded_count) forwarded,
              sum(content_snap.be_forwarded_count+content_snap.be_commented_count) interacts,
              rels.new_fans
      from weibo_content_count_snap_hourlies content_snap
      left join(
        select uid, hour(follow_time) hour, count(1) new_fans
        from weibo_user_relations
        where uid = #{@uid}
        and follow_time   >= '#{@start_date}' and follow_time < '#{@end_date}'
        group by hour(follow_time)
        ) as rels on rels.hour = content_snap.hour and rels.uid = content_snap.uid
      where content_snap.date >= '#{@start_date}' and content_snap.date < '#{@end_date}' and
            content_snap.uid = #{@uid}
      group by content_snap.hour
EOF

    records.each{|record|
      csv << [record.hour, record.new_statuses_count, record.forwarded,  record.commented, record.interacts, record.new_fans]

    }
end
end
 #
#根据uid查互动微博信息 filename = "互动内容列表.csv" 
filename = "kol与中国-互动微博信息.csv"
CSV.open filename,"wb" do |csv|
target_uid ="2637370927"#2637370927
task = GetUserTagsTask.new
 path = File.join(Rails.root,"db/uid")
   File.open(path,"r").each do|uid|
        uid = uid.strip
        forward_weibo = WeiboForward.where("uid = ? and forward_uid = ?",target_uid,uid)
        comment_weibo = WeiboComment.where("uid = ? and comment_uid = ?",target_uid,uid)
        if comment_weibo.size >0
          comment_weibo.each do |comment|
             row = []
             comment_at = comment.comment_at.strftime("%Y-%m-%d %H:%M:%S")
             url = "http://weibo.com/#{comment.comment_uid}/#{WeiboMidUtil.mid_to_str(comment.comment_id.to_s)}"
             url1 = "http://weibo.com/2637370927/#{WeiboMidUtil.mid_to_str(comment.weibo_id.to_s)}"
             c = MComment.find(comment.comment_id)
             next if c.nil?
             begin
             account=task.load_weibo_user(comment.comment_uid)
             rescue Exception=>e
              if e.message =~ / does not exists!/
                  csv << [comment.comment_uid]
                   next
              end
             end
             row = account.to_row + [comment.comment_uid,comment.comment_at,url,url1,'评论'] #account.to_row(:full) +/c['text'],
             csv << row
          end
        end
        if forward_weibo.size >0
          forward_weibo.each do |forward|
            row = []
           # account = WeiboAccount.find_by_uid(forward.forward_uid.to_s)
            forward_at = forward.forward_at.strftime("%Y-%m-%d %H:%M:%S")
            url = "http://weibo.com/#{forward.forward_uid}/#{WeiboMidUtil.mid_to_str(forward.forward_id.to_s)}"
            url1 = "http://weibo.com/2637370927/#{WeiboMidUtil.mid_to_str(forward.weibo_id.to_s)}"
            f = MForward.find(forward.forward_id)
            next if f.nil?
             begin
            account  = task.load_weibo_user(forward.forward_uid)
            rescue Exception=>e
              if e.message =~ / does not exists!/
                  csv << [forward.forward_uid]
                   next
              end
             end
            row = account.to_row + [forward.forward_uid,forward.forward_at,url,url1,'转发']#account.to_row(:full) + /f['text'],
             csv << row
          end
       end

    end
end
# 一段时间微博的互动用户排行(小文)
filename = "商用频道微博的互动用户排行.csv"
CSV.open filename,"wb" do |csv|
     csv << %w{帐号 用户ID 昵称 性别 粉丝数 认证类型 认证原因 是否我的粉丝 转发次数 评论次数 互动次数 intel员工 "  "}#添加一列空
      @uid = 2637370927
      @start_date = '2014-01-12'
      @end_date = '2014-01-19'
      employee_keyword = Keyword.where(user_id:1,name:"INTERNAL").first
      key_id = employee_keyword.try(:id)
      records = WeiboUserInteractionSnapDaily.find_by_sql <<-EOF
        select snap.uid, snap.from_uid, rel.uid following,attrs.id is_employee, users.screen_name, users.gender, users.followers_count, users.verified_type,
        forwarded_count, commented_count,interacted_count
        from (
          select uid,from_uid, sum(snap.forwarded_count)  forwarded_count, sum(snap.commented_count) commented_count, sum(snap.forwarded_count)+sum(snap.commented_count) interacted_count
          from weibo_user_interaction_snap_dailies snap
          where snap.date >= '#{@start_date}' and snap.date < '#{@end_date}'
          and snap.uid = #{@uid}
          group by snap.uid, snap.from_uid
          order by snap.uid , sum(snap.forwarded_count)+sum(snap.commented_count) desc
        ) as snap
        left join weibo_accounts users on users.uid = snap.from_uid
        left join weibo_user_relations rel on rel.by_uid = snap.from_uid and rel.uid = #{@uid}
        left join weibo_user_attributes attrs on attrs.uid = snap.from_uid and attrs.keyword_id = #{key_id}
      EOF
     records.each{|record|
        uid = record.uid.to_s
        a = MUser.find(record.from_uid)
        csv << [
                        record.screen_name,
                        record.from_uid,
                        record.screen_name,
                        record.gender,
                        record.followers_count,
                        record.verified_type,
                        a.try(:verified_reason),
                        record.following ? "Yes" : "",
                        record.forwarded_count,
                        record.commented_count,
                        record.interacted_count,
                        record.is_employee ? "Yes" : "" #员工
	                        ]

    }
end


#读CSV openid 查看 活跃度 日均发帖量 原创占比(王娟) 
filename = "weibo_活跃度 日均发帖量 原创占比 转发率 评论率.csv"
CSV.open filename,"wb" do |csv|
  csv << %w{name 日均发帖量 活跃度  原创占比 转发率 评论率}
   number = 2
   s = Roo::CSV.new("全量新增粉丝中分别随机抽取300样本.csv")
   while
     openid = s.cell('B',number)
     evaluate = WeiboUserEvaluate.find_by_uid(uid)
     if evaluate.nil? || evaluate.origin_rate == 0
         evaluate = WeiboAccount.find_by_openid(uid).update_evaluates
     end
     csv << [name,evaluate.day_posts,(evaluate.forward_average+evaluate.comment_average)/100.0,evaluate.origin_rate/100.0,evaluate.forward_rate,evaluate.comment_rate]
   number+= number + 1
   end
end


#
filename = "互动人列表-1.csv"
  #target_id = '1687053504' 
  task = GetUserTagsTask.new
  #@compare_uids = {}
  CSV.open filename,"wb" do |csv|
    csv << ["url", "UID", "昵称", "位置", "性别", "粉丝", "关注", "微博", "注册时间", "认证信息", "认证原因"]#WeiboAccount.to_row_title(:full) +['主号互动次数','是否是主号粉丝']
    path = File.join(Rails.root,"db/url1")#从file拿weibo_id
    File.open(path,"r").each do|line|
      url = line.strip
      weibo_id = WeiboMidUtil.str_to_mid url.split("/").last# http://weibo.com/2637370927/AjBZqpI56
      puts url
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
                  csv << [url,line.user.id,use.screen_name,use.location,gender,use.followers_count,use.friends_count,use.statuses_count,Time.parse(use.created_at),use.verified_type,use.verified_reason]
                  #@compare_uids[line.user.id.to_s] ||= 1
                 #!@compare_uids[line.user.id.to_s].nil? if @compare_uids[line.user.id.to_s]+=1
                 end
               else
                processing = false
               end
          rescue Exception=>e
            puts e.message
          end
          page+=1
        end while processing == true
        page = 1
        processing == true
        begin
          begin
            res = task.stable{task.api.comments.show(weibo_id,count:200,page:page)}#根据weibo_id查评论人信息
              if !res.comments.blank?
                 res.comments.each do |line|
                  row = []
                  if line.nil?
                     processing = false
                     break
                  end
                  csv << [url,line.user.id,use.screen_name,use.location,gender,use.followers_count,use.friends_count,use.statuses_count,Time.parse(use.created_at),use.verified_type,use.verified_reason]
                 
                  #@compare_uids[line.user.id.to_s] ||= 1
                 #!@compare_uids[line.user.id.to_s].nil? if @compare_uids[line.user.id.to_s]+=1
                 end
               else
                processing = false
               end
           rescue Exception=>e
            puts e.message
           end
           page+=1
        end while processing == true

    end
=begin
        @compare_uids.keys.each do |uid|
          puts uid
          row = []
          begin
           account  = task.load_weibo_user(uid)
          rescue Exception=>e
                csv << [uid]
                 next
          end
          next if account.blank?
          row = account.to_row(:full)
          row << @compare_uids[uid]
          begin
          res = task.api.friendships.show(source_id:uid,target_id:target_id)
          rescue Exception=>e
                row << ''
                csv << row
                next
          end
          res.source.following ? row << "是": row << "否"
          csv << row
       end
=end
end
#写EXCEL 
Axlsx::Package.new do |p|
  p.workbook.add_worksheet(:name => "sheet1") do |sheet|
    results.each{|row|
      sheet.add_row  row
    }
  end
  p.serialize('aaa.xlsx')
end

  #粉丝列表的uid 现在是否
  filename = "data/中山大学-粉丝列表.csv"
target_id = '1892723783'
task = GetUserTagsTask.new
CSV.open filename,"wb" do |csv|
   csv <<  ['uid']#WeiboAccount.to_row_title(:full)

    begin
    friend_ids = task.api.friendships.followers_ids(:uid=>target_id, :count=>2000).ids
    rescue Exception=>e
      puts 'error:类'
    end
  friend_ids.each do|uid|
    csv << [uid]
=begin
   begin
     account = task.load_weibo_user(uid)
   rescue Exception=>e
    csv << [uid]
    next
   end
     next if account.blank?
     csv <<  account.to_row(:full)
=end
  end
end
#查看身份 
filename = "身份.csv"
  task = GetUserTagsTask.new
  CSV.open filename,"wb" do |csv|
    csv << ['uid','身份']
    path = File.join(Rails.root,"db/uid1")
    File.open(path,"r").each do|line|
      uid = line.strip
      records = WeiboUserAttribute.find_by_sql <<-EOF
         select keyword_id from weibo_user_attributes where uid = #{uid}
EOF
       type = {85 => "核心KOL",86 => "降级核心KOL",88 => "全量KOL",90 => "全网KOL",}
       if records.size==0
          csv << [uid]
          next
       end
       row = []
       records.each do |line|
          keyword = type[line.keyword_id]
          if !keyword.nil?
             row << keyword
          end
       end
       csv << [uid,row*',']
    end
  end
#提取中国，超级本 评论的其他的内容。
filename = "超级本评论的其他人的信息.csv"
CSV.open filename,"wb" do |csv|
    csv << %w{UID	  官博昵称  	 评论转发说的内容 	发出动作的时间	  原微博链接 }
    AUTHED_UID_AND_KEYS = {
    2637370927=>"1075842038",
    2295615873=>"1384091891",
    1288915263=>"3778658839",
    2637370247=>"1075842038",
  }
  appkey = AUTHED_UID_AND_KEYS[2637370247]
  task = GetMentionsTask.new(2637370247,:appkey=>appkey)
  page = 1
      processing = true
        begin
          begin
            res = task.oapi.comments.by_me(count:50,page:page,filter_by_source:0)
            res.comments.each do |line|
                   row = []
                if line.nil?
                   processing = false
                   break
                end
                str = WeiboMidUtil.mid_to_str line.status.mid
                url = 'http://www.weibo.com/'+ line.status.user.idstr + '/'+ str
                csv << [line.id,line.user.name,line.text,Time.parse(line.created_at),url]
            end
          rescue Exception=>e
            puts e.message
          end
          page+=1
        end while processing == true
end

#循环跑微博列表（范范）
uids = [2637370927,1340241374,2295615873,2637370247,1738056157,2619244577,2183473425,1617785922,1765189187,
1687053504,1747360663,1847000261,1942473263,1785529887,2216786767,1883832215,1775695331,2030206793]
uids.each do |line|
  uid = line
  filename = "data/#{WeiboAccount.find_by_uid(2637370927).screen_name}微博列表.csv"
  ReportUtils.export_weibo_list_to_csv([2637370927],filename,start_time: Time.new(2012,1,1),end_time: Time.new(2014,05,31))
end


#匹配一个帐号是否在 一些帐号中（匹配）接口提取           
filename = "匹配2.csv"
CSV.open filename,"wb" do |csv|
    csv << ['uid','新老']
    path = File.join(Rails.root,"db/uid")
    path1 = File.join(Rails.root,"db/uid1")
    keywords = []
    File.open(path,"r").each do|line|
      keywords << line.strip
    end
    File.open(path1,"r").each do|line|
      isinclude = keywords.include?(line.strip) ? '有' : ''
      csv << [line,isinclude]
    end
end

filename = "匹配1.csv"
CSV.open filename,"wb" do |csv|
    csv << ['id','新老']
    path0 = File.join(Rails.root,"db/uid")
    path = File.join(Rails.root,"db/uid1")
    path1 = File.join(Rails.root,"db/uid2")

    keywords = []
    key = {}
    File.open(path0,"r").each do|line|
      keywords << line.strip.to_i
    end
    number = 0
    File.open(path,"r").each do|line|
      id = line.strip
      key[id] = keywords[number]
      number = number + 1
    end
    File.open(path1,"r").each do|line|
      openid = line.strip
      isinclude = (key.keys.include?(openid)) ? key[openid] : ''
      csv << [line,isinclude]
    end
end

#接口提取基本信息 近一条微博时间 
task = GetUserTagsTask.new
filename = "16W接口提取基本信息近一条微博时间-1-1.csv"
path = File.join(Rails.root,"db/uid4")
CSV.open filename,"wb" do |csv|
      csv << WeiboAccount.to_row_title(:full)+["近1条微博时间"]
  File.open(path,"r").each do|line|
           uid = line.strip
           begin #解决异常
               res = task.stable{task.api.users.show(uid:uid)}
               if !res.blank?
                  account = task.save_weibo_user(res)
               else
                  csv << [uid]
                  next
               end
            rescue Exception=>e
                  csv << [uid]
                  next
            end
           if res.status.nil?
             csv << account.to_row(:full)
             next
           end
           csv << account.to_row(:full) + [Time.parse(res.status.created_at)]
  end
end




#张桢匹配（张桢） 大数据	云计算 	IT消费化	 行业	媒体
require 'rubygems'
 require 'roo'
s = Roo::Excelx.new("data/标签.xlsx")
#新KOL挖掘2014-全网（媒体、蓝v）合并.xlsx  新KOL挖掘2014-全量(媒体、蓝v)合并.xlsx

s1 = Roo::Excelx.new("Intel China fans 关键词2014.xlsx")#IT筛选关键词.xlsx
filename = "匹配3.csv"
CSV.open filename,"wb" do |csv|
    csv << ['IT关键词']
    #path0 = File.join(Rails.root,"db/openid")
    #path = File.join(Rails.root,"db/name")
    keywords = []
    #File.open(path0,"r").each do|line|
    i = 2
    while true
    break if s1.cell("C",i).nil?
      keywords << s1.cell('C',i).to_s.strip#line #改变匹配字符串还是 数字
      i +=1
    end
   # File.open(path,"r").each do|line|
   num = 2
   while true
      number = 0
      if !s.cell('A',num).nil?
        str = s.cell('A',num).to_s.strip
      end
      if str.nil?
        str = ''
      end
      keywords.each do |line|
       break if line.nil?
       (number = number + 1) if str.include?(line.strip)
      end
      isinclude = (number > 0)? 'Y' : 'N'
      csv << [str.to_i,isinclude]
      break if (num == 27888)#15667   1140 3368
      num +=1
   end
end


#根据uid提取一个人 与其他人 互粉 uids 微博
task = GetUserTagsTask.new
filename = "互粉uids-1.csv"
path = File.join(Rails.root,"db/uid")
CSV.open filename,"wb" do |csv|
    csv << ['uid']
File.open(path,"r").each do|line|
  uid = line.strip
  page = 1
  while
    res= task.stable{task.api.friendships.friends_bilateral_ids(uid,:count=>50,:page=>page)}
    ids = res.ids
    break if ids.blank?
    ids.each do |line|
      csv << [line]
    end
    page += 1
  end
end
end
#互粉uids.csv
s = Roo::CSV.new("互粉uids.csv")
    keywords = {}
    i = 2
while





#
filename = "互动人数-cjb.csv" 
path = File.join(Rails.root,"db/uid")
CSV.open filename,"wb" do |csv|
    csv << ['uid','互动人数']
    target_uid = 2637370247
File.open(path,"r").each do|line|
  uid = line.strip
  interactioncount = WeiboUserInteractionSnapDaily.where("uid = ? and from_uid = ? and date between ? and ?",target_uid,uid,'2014-05-01','2014-06-01').count
  csv << [uid,interactioncount]
end
end


#根据url查与中国在一定时间内的互动信息（范范）基本信息   原微博链接  原微博内容  互动时间 动作    
itdms = WeiboUserAttribute.find_by_sql <<-EOF
     select  uid uid  from weibo_user_attributes where  keyword_id = 77
EOF
filename = "ITDM.csv"
CSV.open filename,"wb" do |csv|
start_time = '2014-06-02'
  end_time = '2014-06-10'
   target_uid = 2295615873 
  itdms.each do |itdm|
    uid = itdm.uid
             # forward_weibo = WeiboForward.where("uid = ? and forward_uid = ? and forward_at between ? and ? ",target_uid,uid,start_time,end_time)
             #   comment_weibo = WeiboComment.where("uid = ? and comment_uid = ? and comment_at between ? and ? ",target_uid,uid,start_time,end_time)
   # csv << [uid,forward_weibo.count,comment_weibo.count]
  csv << [uid]
  end
end

itdms = WeiboUserAttribute.find_by_sql <<-EOF
     select  uid uid  from weibo_user_attributes where  keyword_id = 77
EOF
#互动内容列表-ITDM与商用频道(张桢)
itdms = WeiboUserAttribute.find_by_sql <<-EOF
     select  uid uid  from weibo_user_attributes where  keyword_id = 77
EOF
filename = "互动内容列表-ITDM与商用频道.csv"
  CSV.open filename,"wb" do |csv|
  start_time = '2014-06-17'
  end_time = '2014-06-24'
   target_uid = 2295615873 #2637370927 M
    task = GetUserTagsTask.new
    csv << WeiboAccount.to_row_title(:full) + %w{ 内容 互动时间 互动微博连接 动作}  
        commentcount = 0
        itdms.each do |itdm|
          uid = itdm.uid
          forward_weibo = WeiboForward.where("uid = ? and forward_uid = ? and forward_at between ? and ? ",target_uid,uid,start_time,end_time)
          #forward_weibo = forward_weibo.where("forward_at >= ? ", start_time)
          #forward_weibo = forward_weibo.where("forward_at < ? ", end_time)
          comment_weibo = WeiboComment.where("uid = ? and comment_uid = ? and comment_at between ? and ? ",target_uid,uid,start_time,end_time)
          #comment_weibo = comment_weibo.where("comment_at >= ?",start_time)
          #comment_weibo = comment_weibo.where("comment_at < ? ",end_time)
          if !comment_weibo.blank?
            comment_weibo.each do |comment|
               next if comment.blank?
               row = []
                account = WeiboAccount.find_by_uid(comment.comment_uid.to_s)
               comment.nil? ? (comment_at = '') : (comment_at = comment.comment_at.strftime("%Y-%m-%d %H:%M:%S"))
               url = "http://weibo.com/2637370927/#{WeiboMidUtil.mid_to_str(comment.comment_id.to_s)}"
               c = MComment.find(comment.comment_id)
               next if c.nil?
               row = account.to_row(:full) + [c['text'],comment_at,url,'评论'] #account.to_row(:full) + c['text'],
               csv << row
            end
          end
          if !forward_weibo.blank?
            forward_weibo.each do |forward|
              row = []
               account = WeiboAccount.find_by_uid(forward.forward_uid.to_s)
              next if forward.blank?
              forward.nil?? (forward_at = '') : (forward_at = forward.forward_at.strftime("%Y-%m-%d %H:%M:%S"))
              url = "http://weibo.com/#{forward.forward_uid}/#{WeiboMidUtil.mid_to_str(forward.forward_id.to_s)}"
              f = MForward.find(forward.forward_id)
              next if f.nil?
              row = account.to_row(:full) + [f['text'],forward_at,url,'转发']#account.to_row(:full) + /f['text'],
               csv << row
            end
          end
        end    
end


# 
 filename = "互动列表-与商用频道.csv" 
  CSV.open filename,"wb" do |csv|
  start_time = '2014-06-02'
  end_time = '2014-06-10'
   target_uid = 2295615873 #2637370927 M
    task = GetUserTagsTask.new
    csv << WeiboAccount.to_row_title(:full)  
          commentcount = 0
          forward_weibo = WeiboForward.where("uid = ? and forward_at between ? and ? ",target_uid,start_time,end_time)
          comment_weibo = WeiboComment.where("uid = ? and comment_at between ? and ? ",target_uid,start_time,end_time)
        
          if !(comment_weibo.size == 0)
            comment_weibo.each do |comment|
                next if comment.blank?
                row = []
                account = WeiboAccount.find_by_uid(comment.comment_uid.to_s)
                row = account.to_row(:full)  
                csv << row
            end
          end
          if !(forward_weibo.size == 0)
            forward_weibo.each do |forward|
              row = []
              account = WeiboAccount.find_by_uid(forward.forward_uid.to_s)
              row = account.to_row(:full)  
              csv << row
            end
          end    
end 
#主动AT 里面包含 #爱去哪去哪#（张桢）  微博内容 微博列表  #爱去哪去哪# 
    task = GetUserTagsTask.new
filename = "data/转发_评论_互动.csv" #9.30零点-10.14零点 10.14零点-11.4零点
  intel = 2295615873
  title = %w{uid	 微博昵称  	粉丝数 	url	 内容 	是否原创	 发布时间	 来源	 评论数	 转发数}
CSV.open filename,"wb" do |csv|
  csv << title
  start_time = '2014-06-17'
  end_time = '2014-06-24'
  mention = WeiboMention.where("uid = ? and mention_at between ? and ? ",intel,start_time,end_time)
  mention.each do |ment|
    begin
    account = task.load_weibo_user(ment.mention_uid) 
    rescue Exception=>e
      next
    end
    mentioncountion = MMention.find(ment.mention_id)
    url =  "http://weibo.com/#{ment.mention_uid}/#{WeiboMidUtil.mid_to_str(ment.mention_id.to_s)}"
    mentioncountion.text.include?("#爱去哪去哪#")? (isinclude='是') : (isinclude = '否') 
    begin
    res = task.stable{task.api.statuses.show(id:ment.mention_id)}#http://weibo.com/2812586933/Aq33jswEW
    rescue Exception=>e
      next
    end
    res.retweeted_status.nil? ? origin = 'Y' : origin = 'N'
    source = ActionView::Base.full_sanitizer.sanitize(res.source)
    csv << [ment.mention_uid,account.screen_name,account.followers_count,url,mentioncountion.text,origin,Time.parse(res.created_at),source,res.reposts_count,res.comments_count]
  end
end

#uid去重 互动
filename = "uid去重1.csv"
CSV.open filename,"wb" do |csv|
    csv << ['uid'] 
    #path0 = File.join(Rails.root,"db/name") 
    path = File.join(Rails.root,"db/uid4") 
    @compare_uids = {}
    File.open(path,"r").each do|line|
       uid = line.strip
       @compare_uids[uid] ||=  1
       !@compare_uids[uid].nil? if @compare_uids[uid] +=1
    end
    
     @compare_uids.keys.each do |line|
       uid = line
       csv << [uid]
     end
end 
#
 #通过url 转发 评论的内容 查出这些人说了些什么  
  task = GetUserTagsTask.new
  filename = "转发 评论的内容.csv"
CSV.open filename,"wb" do |csv|
    csv << %w{uid 内容 互动时间 互动微博连接 动作}
     path = File.join(Rails.root,"db/uid") 
      File.open(path,"r").each do|line|
        url = line.strip
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
               row = account.to_row(:full) + [url,c.text,commentat,'评论']
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
              row = account.to_row(:full) + [url,c.text,forwardat,'转发']
               csv << row
            end
          end
       
      end    
end


#接口提取 api 通过url 查曝光量 #转发 评论的内容 查出这些人说了些什 
task = GetUserTagsTask.new
filename = "查出这些人说了些什.csv"
CSV.open filename,"wb" do |csv|
    csv << %w{uid 内容 互动时间 互动微博连接 动作} #%w{url 曝光量}#
    path = File.join(Rails.root,"db/url1") 
    File.open(path,"r").each do|line|
      url = line.strip
      @compare_uids = {}
      number  = 0
      weibo_id = WeiboMidUtil.str_to_mid URI.parse(url).path.split("/").last# http://weibo.com/1795839430/AhbvtnvrV http://weibo.com/1795839430/AhmhfkBY5
      puts url 
      page = 1
      processing = true
        begin
          begin
            res = task.stable{task.api.statuses.repost_timeline(weibo_id.to_s,count:200,page:page)}#根据weibo_id查转发人信息count  
                           
              if !res.blank?        
                 res.reposts.each do |line| 
                   row =3.邮件里面 关键词5天次数
 [] 
                  if line.nil?
                     processing = false
                     break
                  end
                  csv << [line.user.id,line.text,DateTime.parse(line.created_at).strftime("%Y-%m-%d %H:%S"),url,'转发']
                  #number += line.user.followers_count
                  #@compare_uids[line.user.id.to_s] ||= [1,{'uid' =>line.user.id,'followers_count' =>line.user.followers_count}]
                 #!@compare_uids[line.user.id.to_s].nil? if @compare_uids[line.user.id.to_s][0] +=1
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
                 csv << [line.user.id,line.text,DateTime.parse(line.created_at).strftime("%Y-%m-%d %H:%S"),url,'评论']
                 #number += line.user.followers_count
                 #@compare_uids[line.user.id.to_s] ||= [1,{'uid' =>line.user.id,'followers_count' =>line.user.followers_count}]
                 #!@compare_uids[line.user.id.to_s].nil? if @compare_uids[line.user.id.to_s][0] +=1
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
       #@compare_uids.keys.each do |uid|
        #  puts uid
       #   number += @compare_uids[uid][1]['followers_count']
      # end  
     # csv << [url,number]  
    end  
end  

#曝光量 库里提取

  filename = "曝光量.csv"
CSV.open filename,"wb" do |csv|
    csv << %w{uid 曝光量}
     path = File.join(Rails.root,"url") 
      File.open(path,"r").each do|line|
          @compare_uids = {}
          number  = 0
          commentcount = 0
          forward_weibo = WeiboForward.where("weibo_id = ?",weibo.weibo_id.to_s)
          comment_weibo = WeiboComment.where("weibo_id = ?",weibo.weibo_id.to_s)
            if !comment_weibo.nil?
              comment_weibo.each do |comment|
                 @compare_uids[comment.comment_uid.to_s] ||= 1
                 !@compare_uids[comment.comment_uid.to_s].nil? if  @compare_uids[comment.comment_uid.to_s] +=1
              end
            end
            if !forward_weibo.nil?
              forward_weibo.each do |forward|
                account = task.load_weibo_user(forward.forward_uid.to_s)
                @compare_uids[forward.forward_uid.to_s] ||= 1
                 !@compare_uids[forward.forward_uid.to_s].nil? if  @compare_uids[forward.forward_uid.to_s] +=1
              end
            end
            @compare_uids.keys.each do |uid|
              puts uid
              begin
                account = task.load_weibo_user(uid)
              rescue Exception=>e
                next
              end
              number += account.followers_count 
            end 
       
      end    
end
#根据 uid  关键词 时间  查互动微博内容 (王娟，胡烨) 
filename =  "互动微博内容7.1-7.27.csv"
CSV.open filename,"wb" do |csv|
  start_time = '2014-07-01' 
  end_time = '2014-07-27'
   #target_uid = 2637370927  
    task = GetUserTagsTask.new
    csv <<  %w{ uid 关键词 互动微博包含次数 原微博包含次数}  
          #forward_weibo = WeiboForward.where("uid = ?  and forward_at between ? and ? ",target_uid,start_time,end_time)
          #comment_weibo = WeiboComment.where("uid = ?  and comment_at between ? and ? ",target_uid,start_time,end_time)
          forward_weibo = WeiboForward.where("forward_at between ? and ? ",start_time,end_time)
          comment_weibo = WeiboComment.where("comment_at between ? and ? ",start_time,end_time)
          if !comment_weibo.blank?
            comment_weibo.each do |comment|
               next if comment.blank?
               row = []
               c=MComment.find(comment.comment_id.to_i)
               if !c.nil?
                 InteractionKeyword.all.each do |keyword|
                    isinclude= c['text'].include?(keyword.key)
                    isincludeone= c.status["text"].include?(keyword.key)
                    if isinclude 
                      wiks  = WeiboInteractionKeywordStat.where(uid: comment.comment_uid,key_id: keyword.id).first
                      wiks = WeiboInteractionKeywordStat.new(uid: comment.comment_uid,key_id: keyword.id) if wiks.nil?
                      wiks.interactive_included = 1 if wiks.interactive_included.blank?
                      wiks.interactive_included += 1 if !wiks.interactive_included.blank?
                      wiks.save!
                    end
                    if isincludeone 
                      wiks  = WeiboInteractionKeywordStat.where(uid: comment.comment_uid,key_id: keyword.id).first
                      wiks = WeiboInteractionKeywordStat.new(uid: comment.comment_uid,key_id: keyword.id) if wiks.nil?
                      wiks.weibo_included = 1 if wiks.weibo_included.blank?
                      wiks.weibo_included += 1 if !wiks.weibo_included.blank?
                      wiks.save!
                    end
                 end
               end
            end
          end
          if !forward_weibo.blank?
            forward_weibo.each do |forward|
              row = []
              next if forward.blank?
              f=MForward.find(forward.forward_id)
              if !f.nil?
                InteractionKeyword.all.each do |keyword|
                   isinclude = f['text'].include?(keyword.key)
                   isincludeone = f.retweeted_status['text'].include?(keyword.key)
                   if isinclude 
                        wiks  = WeiboInteractionKeywordStat.where(uid: forward.forward_uid,key_id: keyword.id).first
                        wiks = WeiboInteractionKeywordStat.new(uid: forward.forward_uid,key_id: keyword.id) if wiks.nil?
                        wiks.interactive_included = 1 if wiks.interactive_included.blank?
                        wiks.interactive_included += 1 if !wiks.interactive_included.blank?
                        wiks.save!
                      end
                   if isincludeone 
                        wiks  = WeiboInteractionKeywordStat.where(uid: forward.forward_uid,key_id: keyword.id).first
                        wiks = WeiboInteractionKeywordStat.new(uid: forward.forward_uid,key_id: keyword.id) if wiks.nil?
                        wiks.weibo_included = 1 if wiks.weibo_included.blank?
                        wiks.weibo_included += 1 if !wiks.weibo_included.blank?
                        wiks.save!
                   end
                 end
              end 
            end
          end
            comment_weibo.each do |comment|
              wiks = WeiboInteractionKeywordStat.where(uid: comment.comment_uid)
              wiks.each do |line|
                ik = InteractionKeyword.find_by_id(line.key_id).key
                csv << [comment.comment_uid,ik,line.interactive_included,line.weibo_included]
              end
            end
          if !forward_weibo.nil?
            forward_weibo.each do |forward|
              wiks = WeiboInteractionKeywordStat.where(uid: forward.forward_uid)
              wiks.each do |line|
                ik = InteractionKeyword.find_by_id(line.key_id).key
                csv << [forward.forward_uid,ik,line.interactive_included,line.weibo_included]
              end
            end
          end
end
=begin
WeiboInteractionKeywordStat   uid  key_id  interactive_included  weibo_included 
InteractionKeyword
      c = MWeiboContent.find(forward.weibo_id)
rel = WeiboUserRelation.where(uid:2637370247,by_uid:uid).first
      rel = WeiboUserRelation.new(uid:2637370247,by_uid:uid) if rel.nil?
      rel.follow_time = Time.now
      rel.save!
filename =  "uid.csv"
CSV.open filename,"wb" do |csv|
WeiboInteractionKeywordStat.all.each do |line|
  csv <<[line.uid]
end
end
=end
path = File.join(Rails.root,"db/name")#从file拿weibo_id 
File.open(path,"r").each do|line|
 name = line.strip
 ik  = InteractionKeyword.where(key:name).first
 debugger
 ik = InteractionKeyword.new(key:name) if ik.nil?
 ik.save!
end
#互动微博数 （娜娜）       
start_time ='2014-06-16'
  end_time = '2014-06-22'
   target_uid = 2637370247 
 filename = "互动微博数2.csv"
 CSV.open filename,"wb" do |csv|
    csv << %w{uid 互动微博数}
    path = File.join(Rails.root,"db/uid")#从file拿weibo_id
      File.open(path,"r").each do|line|
          uid = line.strip
          forwards = WeiboForward.where("uid = ? and forward_uid = ? and forward_at between ? and ?",target_uid,uid,start_time,end_time)
          comments = WeiboComment.where("uid = ? and comment_uid = ? and comment_at between ? and ?",target_uid,uid,start_time,end_time)
          row = []
          if !comments.blank?
            comments.each do |comment|
               next if comment.blank?
               row << comment.comment_id
            end
          end
          if !forwards.blank?
            forwards.each do |forward|
              row << forward.forward_id
            end
          end
          csv << [uid,row.uniq.size]
      end

 end
 
 #
 #互动人信息 互动时间  
  filename = "weibo_weibo_list_by__ok.csv"
  CSV.open filename,"wb" do |csv|
    csv << %w{uid }
#3620546325922080 WeiboForward.where("weibo_id= ?",'3620546325922080').distinct(by_uid)
    forwards = WeiboForward.where("uid = ?  and forward_at between ? and ?",2637370247 ,'2014-06-30','2014-07-07')
    comments = WeiboComment.where("uid = ?   and comment_at between ? and ?",2637370247 ,'2014-06-30','2014-07-07')
    forwards.each{|forward|
      uid = forward.forward_uid
      csv << [uid]
    }
    comments.each{|comment|
      uid = comment.comment_uid
      csv << [uid]
    }
  end
  
  
  #连接 点击量统计 根据url 或者uid 时间 time links = WeiboReport.analyse_links ['2295615873'],'2014-01-01','2014-07-01'
  all_links = []
  links = []
  path = File.join(Rails.root,"db/url1")#从file拿url
  File.open(path,"r").each{|url|
    weibo_id = WeiboMidUtil.str_to_mid URI.parse(url.strip).path.split("/").last
    w = WeiboDetail.where("weibo_id = ?",weibo_id).first
    mw = MWeiboContent.find weibo_id.to_i
    puts mw.text
    urls = mw.text.scan(/(http:\/\/t\.cn\/[A-Za-z0-9]{5,7})/).flatten
    urls.each{|url|
      puts url 
      next if all_links.include? url
      url = url[0..18] if url.size>19
      all_links << url
      content = mw.text
      links << [w.uid,w.post_at.to_date.to_s, url,content.to_s]
      puts "%s\t%s\t%s\%s" % [w.uid,w.post_at.to_date.to_s,url,content]
     }
     
  }
  
  #links = WeiboReport.analyse_links ['2295615873'],'2014-01-01','2014-07-01'
  filename = "点击量统计.csv"
  CSV.open filename,"wb" do |csv|
    csv <<  %w{时间 url 点击量 微博内容}
     links.each_with_index{|ar,index|
        puts ar
        uid, date,url,wurl = ar
        clicks = WeiboReport.get_click(url)
        if ar.size > 3
          ar[3] = clicks
        else
          ar << clicks
        end
       csv << [date,url,clicks,wurl]
   }
  end
  # 关键词匹配
  微博关键词： 
 keywords={
 '2in1'=> ['二合一','2合1','2in1','芯电脑','PC','PC平板'],
 'Pad'=>['平板','芯平板','英特尔芯平板'],
 'Campaign'=>['活动','促销','优惠','大礼包']
 }
 filename = "匹配.csv"
 CSV.open filename,"wb" do |csv|
    csv << %w{uid 互动微博数}
    path = File.join(Rails.root,"db/uid")#从file拿weibo_id
      File.open(path,"r").each do|line|
          name = line.strip
          key1 =[]
          key2 =[]
          keywords.keys.each do |key|
            keywords[key].each do |line|
              isinclude = name.strip.include?('line')
              if isinclude
                key1 << line
                key1 << key
              end
            end
          end
          csv << [name,key1*',',key2*',']
      end
 end         
 
 
 
 #提取以及转发信息（根据）娜娜     
      
task = GetUserTagsTask.new 
urls = ['http://weibo.com/1881422534/Bez9shEGS','http://weibo.com/1881422534/Bez9shEGS']
keyword = "云计算"
timenow = Time.now.strftime("%Y%m%d")
Axlsx::Package.new do |p|
  p.workbook.add_worksheet(:name => "#{keyword}") do |sheet|
    sheet.add_row ["Intel Biz Platform Keywords monitoring(#{timenow})"]
      urls.each do |url|

        url = url
        weibo_id = WeiboMidUtil.str_to_mid URI.parse(url).path.split("/").last#http://weibo.com/1881422534/Bez9shEGS
        begin
          res = task.stable{task.api.statuses.show(id:weibo_id)}
        rescue Exception =>e
          next
        end
        #title = %w{keyword url content name detail fans post_time retweets comments   retweet_name retweet_fans }
        content = res.text
        date = "#{DateTime.parse(res.created_at).year}年#{DateTime.parse(res.created_at).month}月#{DateTime.parse(res.created_at).day}日#{DateTime.parse(res.created_at).hour}:#{DateTime.parse(res.created_at).minute}"
        poster = "#{res.user.name}(Fans:#{res.user.followers_count}/Detail:#{res.user.verified_reason})"
        buzz_volume = "Retweets:#{res.reposts_count}/ Comments:#{res.comments_count}"
        sheet.add_row ["Keyword",keyword]
        sheet.add_row ["Content",content]
        sheet.add_row ["Link",url]
        sheet.add_row ["Poster",poster]
        sheet.add_row ["Date",date]
        sheet.add_row ["Buzz Volume",buzz_volume]
        page = 1
        processing = true
        begin
          begin
             repost = task.stable{task.api.statuses.repost_timeline(weibo_id.to_s,count:200,page:page)}#根据weibo_id查转发人信息count  
              if !repost.blank?        
                 repost.reposts.each do |line| 
                   row = [] 
                  if line.nil?
                      processing = false
                     break
                   end
                     #rows << [line.user.id,line.text,DateTime.parse(line.created_at).strftime("%Y-%m-%d %H:%S"),url,'转发']
                   sheet.add_row ["KOL","（Fans:#{line.user.followers_count}/ Retweet：#{line.reposts_count})#{line.user.verified_reason}"]
                  end
               else
                 processing = false
                break
               end         
          rescue Exception=>e
            sheet.add_row [e.message]
            
          end
           page+=1
         end while processing == true
       end
    end
  p.serialize('云计算.xlsx')
end
 #根据uid一段时间内转发 二次转发  
 task = GetUserTagsTask.new
 filename = "根据uid一段时间内转发_二次转发.csv"
 target_uid=2295615873
 start_time='2014-04-01'
 end_time='2014-07-01'
 CSV.open filename,"wb" do |csv|
    csv << WeiboAccount.to_row_title + %w{原微博链接  原微博发布时间 原微博内容 原微博内容分类 转发微博连接 转发时间   总转发 总评论 二次转发 二次评论  转发占比 动作} 
        forward_weibo = WeiboForward.where("uid = ? and forward_at between ? and ?",target_uid,start_time,end_time)
       if !(forward_weibo.count == 0)  
          forward_weibo.each do |forward|
            account =  task.load_weibo_user(forward.forward_uid)
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
            if record.blank?
              csv << [forward.forward_uid]
              next
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
              f = task.stable{task.api.statuses.show(id:forward.forward_id)}
              freposts_count =f.reposts_count
              fcomments_count = f.comments_count
            rescue Exception=>e
               if e.message =~ / does not exists!/
                 freposts_count =0
                 fcomments_count = 0
               end
            end
           csv << account.to_row + [record.url, post_at,text,type,forward_url, forward_at,record.reposts_count.to_s ,record.comments_count.to_s,freposts_count, fcomments_count, freposts_count.to_f/record.reposts_count.to_f,'转发']
          end
        end
end



#微博类型，发布类型
filename = "发布类型.csv"
 path = File.join(Rails.root,"db/url1")#从file拿weibo_id
 CSV.open filename,"wb" do |csv|
    csv <<['url','类型']
    File.open(path,"r").each do |url|
      weibo_id = WeiboMidUtil.str_to_mid URI.parse(url.strip).path.split("/").last
      record=WeiboDetail.find_by_weibo_id(weibo_id.to_i)
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
        csv << [url,type]
    end
end
#接口提取粉丝列表   
1771925961
2968634427
这是小米公司和锤子科技UID
filename = "粉丝列表-张桢.csv"  
uids = [2798910464,2747614257,2298686821,2301490210,1798050751,2921503464,3820882201,2848698000,2697416452] 
task = GetUserTagsTask.new
CSV.open filename,"wb" do |csv|
   csv << ['主号uid']+ WeiboAccount.to_row_title(:full)
   uids.each do|id|
      target_id = id
      begin
      friend_ids = task.stable{task.api.friendships.followers_ids(:uid=>target_id, :count=>5000).ids} 
      rescue Exception=>e
        puts 'error:类'
        #if e.message =~ / for this time/
       #   sleep(300)
        #end
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


#接口提取近50条微博 查看微博内容里面包含关键词次数（王娟）  
keys1 = %w{装机 超频 DIY 程序 性能 MOD 改装 跑分 性价比}
keys2 = %w{手机 平板 手游 游戏 动漫	APP 二次元}
keys3 = %w{办公 笔记本 超极本 超级本 Office PPT}
 filename = "近50条微博-内容里面包含关键词次数.csv"
    CSV.open(filename,"wb"){|csv|
      csv << %w{name 微博内容 发布时间 转发数 评论数 互动总数 URL 原创 发布来源 原微博uid  原微博人昵称  }
     path = File.join(Rails.root, "db/uid")
   task = GetUserTagsTask.new
    File.open(path,"r").each{|uid|
        uid = uid.strip
        num1 = 0
        num2 = 0
        num3 = 0
          begin
            res = task.stable{task.api.statuses.user_timeline(uid:uid,count:50, page:1)}
           if !res['statuses'][0].nil?
              res['statuses'].each{|w|
                 keys1.each do|key|
                   if w.text.include?(key)
                     num1+=1 
                     break
                   end
                 end 
                  keys2.each do|key|
                    if w.text.include?(key)
                     num2+=1 
                     break
                   end
                  end
                  keys3.each do|key|
                    if w.text.include?(key)
                     num3+=1 
                     break
                   end
                  end                          

              }
          end
          rescue Exception=>e
              0
          end
          csv << [uid,num1,num2,num3]
      }
    }
    
    
    
   #2 
 
 filename = "负面.csv"
    CSV.open(filename,"wb"){|csv|
      csv << %w{name 正面 负面 主张 }
     path = File.join(Rails.root, "db/name")
   task = GetUserTagsTask.new
    File.open(path,"r").each{|uid|
        name = uid.strip
        fumian.each do|key|
          if name.include?(key)
             csv << [key]
             break 
          end
        end
=begin
        num1 = 0
        num2 = 0
        num3 = 0

                 zhengmian.each do|key|
                    if name.include?(key)
                       num1+=1
                       break 
                    end
                 end 
                 fumian.each do|key|
                   if name.include?(key)
                       num2+=1
                       break 
                    end
                 end
                 zhuzhang.each do|key|
                   if name.include?(key)
                       num3+=1
                       break 
                    end
                 end                          

              
          csv << [uid,num1,num2,num3]
=end          
      }
    } 
    
 #拍断一些人 是否关注一些人   
target_uids = %w{
1708942053
1931890934
1904769205
1100856704
2637370927
1340241374
2637370247
2295615873
1642634100
1771925961
1758102755
1286528122
1652987982
1734741902
2853016445
1763950617
1726544024
1728649351
1660521332
1182391231
2683843043
1640571365
1110411735
2183473425
2144646174
1197161814
2244925365
1285452502
1750637412
1639770567
1529573474
1595443924
1246151574
1847000261
5033090411
2740048604
1577794853
1627825392
3318777442
2357213493
3021514657
1850988623
3435593994
1659825360
1856404484
1765189187
1687053504
2145291155
2968634427
1711479641
1796445350
1895520105
1895520105
1647678107
2708473010
1642720480
1747383115
3097378697
1686203097
1617785922
1642471052
1812671331
1826017320
1630461754
1937649537
1735559201
1823630913
1644676117
1747360663
1775695331
1750070171
1729866554
1892706337
1680482282
2117516631
2339287275
2367422032
2117435205
2031482343
2533448835
2993023192
1862888540
1711088242
1865540501
1829488454
2587998954
1785529887
2841852054
3952269256
3541470712
1218334084
1866779793
3714368651
3871405119
1986740801
1646446167
1261141474
1662049267
1642739913
1229068373
1408329341
1410812623
1736737707
2202387347
2913709715
2381785464
2554668724
1678298567}
filename = "sheet2-没关注数的-2.csv"
CSV.open(filename,"wb"){|csv|
  csv << %w{uid 关注108个帐号几个}
  path = File.join(Rails.root, "db/uid4")
  task = GetUserTagsTask.new
     File.open(path,"r").each{|uid|
       uid = uid.strip
       begin
          ids = task.stable{task.api.friendships.friends_ids(uid:uid,count:5000).ids}
       rescue Exception=>e
          csv << [uid,e.message]
          puts e.message
          next
       end
       istargetnum = 0
       target_uids.each do |id|
        istargetnum+=1 if ids.include?(id.to_i) 
      end
      csv << [uid,istargetnum]
      puts Time.now
    }   
}    




#
 keywords = []
 path = File.join(Rails.root, "db/name")
     File.open(path,"r").each{|name|
       uid = name.strip
       keywords << uid
    }
     
