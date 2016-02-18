#根据 固定uids 查出 和英特尔中国互动微博信息

    CSV.open "data/comment_weibo_list20130912.csv", "wb" do |csv|
      csv << %w{UID 姓名 内容 发微博时间 转发	 评论 URL 互动时间 互动类型来源 类型 原创}
      path = File.join(Rails.root,"db/uid")
      File.open(path,"r").each do|line|
          uid  = line.strip 
            account =  WeiboAccount.find_by_uid(uid)
            comment_weibo = WeiboComment.where("uid = ? and comment_uid = ?",'2637370927',uid)
            next if comment_weibo.blank?
            record = WeiboDetail.where("weibo_id = ?",comment_weibo[0].weibo_id)         
            c = MWeiboContent.find(comment_weibo[0].weibo_id)
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
        csv << [uid,account.screen_name, c.text,post_at, record[0].reposts_count, record[0].comments_count, record[0].url,comment_weibo[0].comment_at,'评论',srouce, type, origin]
      end
    end

CSV.open "data/forward_weibo_list20130912.csv", "wb" do |csv|
      csv << %w{UID 姓名 内容 发微博时间 转发	 评论 URL 互动时间 互动类型来源 类型 原创}
      path = File.join(Rails.root,"db/uid")
      File.open(path,"r").each do|line|
          uid  = line.strip 
            account =  WeiboAccount.find_by_uid(uid)
            forward_weibo = WeiboForward.where("uid = ? and forward_uid = ?",'2637370927',uid)
            next if forward_weibo.blank?
            record = WeiboDetail.where("weibo_id = ?",forward_weibo[0].weibo_id)   #      
            c = MWeiboContent.find(forward_weibo[0].weibo_id)
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
        csv << [uid,account.screen_name, c.text,post_at, record[0].reposts_count, record[0].comments_count, record[0].url,forward_weibo[0].forward_at,'转发',srouce, type, origin]
      end
    end

 
#根据读文件 openid  查 用户信息
path = File.join(Rails.root,"db/uid")
    CSV.open "data/tqq_weibo_list20130911.csv", "wb" do |csv|

    csv << %w{openid name nick statuses following followers location created_at gender exp level realname vip verifyinfo} 
    File.open(path,"r").each do|line|
      openid = line.strip
          account = TqqAccount.find_by_openid(openid)
          next if account.blank?
          row = account.to_row
          csv << row
         
          end 
    end

#关注 中国 粉丝列表 关注时间  活跃度
CSV.open("attention_weibo_fans_list20130910.csv","wb"){|csv|

  csv << %w{uid name µØÖ· ÐÔ±ð  ÌýÖÚ ÊÕÌý Î¢²©Êý ŽŽœšÊ±Œä ÈÏÖ€ÀàÐÍ ×ª·¢ÂÊ ÆœŸù×ª·¢ ÆÀÂÛÂÊ ÆœŸùÆÀÂÛ  ×¢²áÀàÐÍ  ¹Ø×¢µÄÊ±Œä »îÔŸ¶È »¥¶¯×ÜŽÎÊý}
path = File.join(Rails.root,"db/uid")
  row = []
  File.open(path,"r").each do|line|
  by_uid = line.strip
  intel = '2637370927'
  weibo = WeiboAccount.find_by_uid(by_uid)
  
  attention_time = WeiboUserRelation.where("by_uid = ? and uid = ?",by_uid,intel)
  
  evaluates = WeiboUserEvaluate.find_by_uid(by_uid)
  next if evaluates.blank?
  forward = WeiboForward.where("uid = ? and forward_uid = ?",intel,by_uid).count
  comment = WeiboComment.where("uid = ? and comment_uid = ?",intel,by_uid).count
  time = attention_time[0].follow_time
  unless evaluates.nil?
  evaluate = evaluates.forward_average + evaluates.comment_average
  end
  interactive = forward[0] + comment[0]
  row = weibo.to_row
  row << time
  row << evaluate
  row << interactive
  csv << row
end
}

 
#根据weibo_id 查询和 中国 互动人信息 互动时间
#uid = '2637370927'
filename = "weibo_weibo_list_by__ok.csv"
  CSV.open filename,"wb" do |csv|
    csv << %w{uid µÇÂŒÃû Ãû×Ö ×ŽÌ¬  ÊÕÌýµÄÈËÊý ÌýÖÚ location ŽŽœšÊ±Œä ÐÔ±ð Ÿ­Ñé µÈŒ¶ ÊÇ·ñÊµÃûÈÏÖ€ vip '' ÀàÐÍ ÊÇ·ñÊÇÒòÌØ¶ûÖÐ¹ú·ÛË¿}  
#3620546325922080 WeiboForward.where("weibo_id= ?",'3620546325922080').distinct(by_uid)
    WeiboDetail.where("uid = ?",2637370927).where("post_at between ? and ?",'2013-9-9','2013-9-10').each{|weibo|
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

#通过weibo_id 查询 微博 列表
def self.export_tqq_weibo_list_to_csv_by_weibo_id(weiboids,filename)
  weiboids = ['275982008773151','224795131194429','323813014837900'] 
  filename = "tqq_weibo_list_by_weibo_id_20130910_ok.csv"
  CSV.open filename,"wb" do |csv|
    csv << %w{openid name nick statuses following followers location created_at gender exp level realname vip verifyinfo weibo_id}
    weiboids.each do|id|
        openids = TqqForward.select('forward_openid').where("weibo_id = ?",id)
        openids.each do|forward|
        puts forward
        openid = forward.forward_openid
        puts openid
        accounts = TqqAccount.find_by_openid(openid)
        next if accounts.blank? 
        row = accounts.to_row
        row << "http://t.qq.com/p/t/#{id}"
        csv << row 
      end
    end
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




  #根据 openid c查询 互动人 信息
  
     CSV.open "tqq_hudong_20130911.csv", "wb" do |csv|
      csv << %w{uid µÇÂŒÃû Ãû×Ö ×ŽÌ¬  ÊÕÌýµÄÈËÊý ÌýÖÚ location ŽŽœšÊ±Œä ÐÔ±ð Ÿ­Ñé µÈŒ¶ ÊÇ·ñÊµÃûÈÏÖ€ vip '' »¥¶¯Êý }
       openids = []
        
        forwards = TqqForward.select('forward_openid').where("openid = ? AND forward_at >= ? AND forward_at<= ?","0B6A468C0642625453023BFB0D1B8570",'2013-08-01','2013-08-26')
        forwards.each do |x|
       openids << x.forward_openid
       end
        comments = TqqComment.select('comment_openid').where("openid = ? AND comment_at >= ? AND comment_at<= ?","0B6A468C0642625453023BFB0D1B8570",'2013-08-01','2013-08-26')
        
        
       comments.each do |y|
       openids << y.comment_openid
       end
        
        
        openids.uniq.each do |record|
          a = TqqAccount.find_by_openid(record)
          next if a.nil?
          row = a.to_row
          num = 0
       openids.each do |z|
       (num += 1) if record == z
       end
          row << num
        puts row
          csv << row 
    
       end 
        
     end
      
      


#ËŒÂ·£º
[1,22,1,22,33,33,4,2,1,22].uniq.each do |record|
           
           
          num = 0
       [1,22,1,22,33,33,4,2,1,22].each do |z|
       (num += 1) if record == z
       
       end
          puts num
           
       end 
        
     end

[1,22,1,22,33,33,4,2,1,22].each do |z|
        num = 0
       (num += 1) if 2 == z
       puts num
       end
          
        
2
3
4

3
4
5
6].uniq

openids.each{|openid|

  a = TqqAccount.find_by_openid(openid)
  hudongs = fowards+comments


}



# 读office文件

require 'rubygems'
 require 'roo'
   
   HOURLY_RATE = 123.45
   
   oo = Openoffice.new("simple_spreadsheet.ods")
   oo.default_sheet = oo.sheets.first
   4.upto(12) do |line|
     date       = oo.cell(line,'A')
    start_time = oo.cell(line,'B')
    end_time   = oo.cell(line,'C')
    pause      = oo.cell(line,'D')
    sum        = (end_time - start_time) - pause
    comment    = oo.cell(line,'F')
    amount     = sum * HOURLY_RATE
    if date
      puts "#{date}\t#{sum}\t#{amount}\t#{comment}"
    end
  end










#根据file文件  查询

#debugger     
task = GetUserTagsTask.new
CSV.open("tmp_users_20130902uid0.csv","wb"){|csv|
path = File.join(Rails.root, "db/uid0")
File.open(path,"r").each do|line|
  uid = line.strip

    a = WeiboAccount.find_by_uid uid
    ma = MUser.find uid

    if ma.nil?
      a = task.stable{task.api.users.show(uid:uid)}
      ma = a
      task.save_weibo_user(a)
    end
    debugger if ma.nil?
    csv << [uid, a.screen_name]
     
end
  
} && nil

#根据uid 查询 是不是 intel  的 粉丝


CSV.open("uid.csv","wb"){|csv|

  csv << %w{uid 是否主号粉丝}
path = File.join(Rails.root,"db/uid")
  File.open(path,"r").each do|line|
  uid = line.strip
  intel = '2295615873'
       csv << [uid, WeiboUserRelation.where(uid:intel,by_uid:uid).count > 0 ? "Y" : "N"]
end
}


#根据uid查询 关注英特尔中国的时间

filename = "tem_fans_time20130909.csv"

CSV.open filename,"wb" do |csv|
  csv << %w{uid time}
path = File.join(Rails.root, "db/uid")
 File.open(path,"r").each do|line|
 row = []
 by_uid = line.strip
 weibotime = WeiboUserRelation.select('follow_time').where("uid = ? and by_uid = ?",'2637370927',by_uid)
 puts weibotime[0].follow_time
 row << by_uid
 row << weibotime[0].follow_time
 csv << row
  end

end
#活跃度 ，关注时间

filename = "evaluates_20130911.csv"
CSV.open filename,"wb" do |csv|
  csv << %w{uid 活跃度 关注时间}
path = File.join(Rails.root, "db/uid1")
 File.open(path,"r").each do|line|
 row = []
 uid = line.strip
 weiboEvaluates = WeiboUserEvaluate.select('forward_average,comment_average ').where("uid = ?",uid)
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
 end
 csv << row
  end

end
#根据uid查活跃度
filename = "weibo_account_v20130909.csv"
CSV.open filename,"wb" do |csv|
  csv << %w{}
  
path = File.join(Rails.root, "db/uid")
 File.open(path,"r").each do|line|
 row = []
 uid = line.strip
 weiboEvaluates = WeiboUserEvaluate.select('forward_average,comment_average ').where("uid = ?",uid)
 evaluates = weiboEvaluates[0].forward_average + weiboEvaluates[0].comment_average
 puts evaluates 
 row << uid
 row << evaluates
 csv << row
  end

end

 #新老粉丝 英特尔中国uid = '2637370927'

end
#¶ÌÁŽœÓµã»÷Á¿Í³ŒÆ
 


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


# 3.短链接点击量统计
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





MForward.first.reposts_count




 
#从接口里面提取一个人粉丝uid 并从数据库里面查这给人的信息 导入Csv
  filename = "data/aaa20130911.csv"
CSV.open filename,"wb" do |csv|
  csv << %w{uid	name 地址	性别	听众	 收听	微博数	 创建时间	认证类型 	转发率	平 均转发	评论率	 平均评论	注册类型
}
  task = GetUserTagsTask.new
    friend_ids = task.api.friendships.followers_ids(:uid=>2604372711, :count=>5000).ids 
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




#从接口提取 一个人的粉丝

task = GetUserTagsTask.new
    friend_ids = task.api.friendships.followers_ids(:uid=>2604372711, :count=>5000).ids 
    
  friend_ids.each do|uid|
   
   uids = uid.to_s.strip
  begin
    res = task.stable{task.api.users.show(uids)}
   task.save_weibo_user(a)
    rescue Exception=>e
    e.message 
    end
  end








#res2 = task.stable{task.api.statuses.user_timeline(uid:uid,count:100, page:page,feature:2)}['statuses'].map(&:id)
            # res3 = task.stable{task.api.statuses.user_timeline(uid:uid,count:100, page:page,feature:3)}['statuses'].map(&:id)
            #res4 = task.stable{task.api.statuses.user_timeline(uid:uid,count:100, page:page,feature:4)}['statuses'].map(&:id)


types = []
                #types << 'image' if res2.include?(w.id)
                #types << '' if res3.include?(w.id)
                #types << '' if res4.include?(w.id) # types*","
