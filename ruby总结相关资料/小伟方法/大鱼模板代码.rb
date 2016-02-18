#1，
ReportUtils.names_to_uids(title,true)['温碧泉'],true) #uid名字导出 uid 2154212385
#2，数据A：全部帖子列表（包含以下维度：发帖时间、发帖内容、被转发数、被评论数、发布来源、帖子链接）
 汤臣倍健官博:1612134157 汤臣倍健营养健康风尚 2249615152 汤臣倍健淘宝官方旗舰店  2418499412
ReportUtils.export_weibo_list([3911310783, 3318508000],"微博列表-温碧泉.csv",Time.new(2012,6,30),Time.new(2014,8,9)) #从接口提取这个人的微博列表 
#3，数据B：提取与全部帖子互动的UID列表（包含以下维度：昵称、性别、地域、认证类型、关注数、粉丝数、微博数、单条微博平均互动量、开通微博时间）
#接口提取 api 通过url 查出互动人信息列表(大文) 
ReportUtils.names_to_uids(,true)
 title=%w{圣象地板微博 世友地板}
 [1678281133, 1367067594]
 title=%w{Qualcomm中国 联想 戴尔中国 惠普电脑 Asus华硕 Acer宏碁}
 [1738056157, 2183473425, 1687053504, 1847000261, 1747360663, 1775695331] 
 武汉万达电影乐园 武汉万达汉秀
 [3911310783, 3318508000] 
 ReportUtils.export_fans_list([2798910464,2747614257,2298686821,2301490210,1798050751,2921503464,3820882201,2848698000,2697416452],"data/中国粉丝列表-张桢.csv",start_time:Time.new(2014,7,1),end_time:Time.new(2014,8,1))
  filename = "data/互动人信息列表-武汉万达电影乐园.csv"
  task = GetUserTagsTask.new
  @compare_uids = {}
  CSV.open filename,"wb" do |csv|
    csv << ['url']+WeiboAccount.to_row_title(:default) +['主号互动次数','是否是主号粉丝']
    path = File.join(Rails.root,"db/url2")#从file拿weibo_id
    File.open(path,"r").each do|line|
      url = line.strip
      puts url
      next if url.nil?
      weibo_id = WeiboMidUtil.str_to_mid url.split("/").last# http://weibo.com/2637370927/AjBZqpI56
      puts url
      page = 1
      genders = {'m'=>"男",'f'=>"女"}
      processing = true
        begin
          begin
            res = task.stable{task.api.statuses.repost_timeline(weibo_id.to_s,count:200,page:page)}#根据weibo_id查转发人信息count
              if !res.reposts.blank?
                 res.reposts.each do |line|
                   row = []
                  if line.blank?
                     processing = false
                     break
                  end
                  use = line.user
                  
                  gender = genders[use.gender]
                  verified_type = WeiboAccount.human_verified_type(use.verified_type)*','
                  
                  @compare_uids[use.id.to_s] ||= [1,{'url'=>url,'uid' =>use.id,'screen_name' =>use.screen_name,'location' =>use.location,'gender'=>gender,'followers_count'=>use.followers_count,'friends_count'=>use.friends_count,'statuses_count'=>use.statuses_count,'created_at'=>Time.parse(use.created_at),'verified_type'=>verified_type,'verified_reason'=>use.verified_reason}]
                 !@compare_uids[use.id.to_s].nil? if @compare_uids[use.id.to_s][0] +=1
                 end
               else
                processing = false
               end
          rescue SystemExit, Interrupt,IRB::Abort
              raise
          rescue Exception=>e
            puts e.message
            if e.message =~ / for this time/
              sleep(300)
            end
            next
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
                  use = line.user
                  gender = genders[use.gender]
                  verified_type = WeiboAccount.human_verified_type(use.verified_type)*','
                  @compare_uids[use.id.to_s] ||= [1,{'url'=>url,'uid' =>use.id,'screen_name' =>use.screen_name,
                  'location' =>use.location,'gender'=>gender,'followers_count'=>use.followers_count,
                  'friends_count'=>use.friends_count,'statuses_count'=>use.statuses_count,
                  'created_at'=>Time.parse(use.created_at),'verified_type'=>use.verified_type,
                  'verified_reason'=>verified_reason}]
                 !@compare_uids[use.id.to_s].nil? if @compare_uids[use.id.to_s][0] +=1
                 end
               else
                processing = false
               end
           rescue SystemExit, Interrupt,IRB::Abort
              raise
           rescue Exception=>e
            puts e.message
            if e.message =~ / for this time/
              sleep(300)
            end
            next
           end
           page+=1
        end while processing == true

    end
        @compare_uids.keys.each do |uid|
          puts uid
          row = []
          row = @compare_uids[uid][1].values
          row << @compare_uids[uid][0]
          row << ''
=begin
          begin
          res = task.api.friendships.show(source_id:uid,target_id:target_id)
          rescue Exception=>e
                if e.message =~ / for this time/
                  sleep(300)
                end
                row << ''
                csv << row
                next
          end
          res.source.following ? row << "Y": row << "N"
=end
          csv << row
       end
  end
#7.数据D：提取所能提及的全量粉丝UID列表（包含以下维度：昵称、性别、地域、认证类型、关注数、粉丝数、微博数、单条微博平均互动量、开通微博时间）途尚咖啡twosome},true) #巴黎贝甜面包店 1653399282,BreadTalk_面包新语 2205618490,漫咖啡中国 2476750895,咖啡陪你caffebene 2759346065
  title=%w{圣象地板 世友地板}
 [1658542871, 1367067594]
  武汉万达电影乐园 武汉万达汉秀
 [3911310783, 3318508000] 
filename = "data/粉丝列表-武汉万达汉秀.csv"  
task = GetUserTagsTask.new
target_id = 3318508000
CSV.open filename,"wb" do |csv|
   csv << ['主号uid']+ WeiboAccount.to_row_title(:full)

      begin
      friend_ids = task.stable{task.api.friendships.followers_ids(:uid=>target_id, :count=>5000).ids} 
      rescue Exception=>e
        puts 'error:类'
        if e.message =~ / for this time/
          sleep(300)
        end
        next
      end
    friend_ids.each do|uid|
     begin
        account = task.load_weibo_user(uid)
     rescue Exception=>e
      if e.message =~ / for this time/
          sleep(300)
      end
      csv << [uid]
      next
     end
       next if account.blank?
       csv << [target_id]+ account.to_row(:full)
    end
end  
  
 # 萝卜 中萝卜 纯中国 
 
  filename = "data/标签-trendy.csv"
  task = GetUserTagsTask.new
  CSV.open filename,"wb" do |csv|
    csv << ['标签']
  path = File.join(Rails.root,"db/uid")
    File.open(path,"r").each do |uid|  
      uid = uid.strip
      begin
        res = task.stable{task.api.tags.tags_batch uid}
      rescue Exception=>e
        csv << [""]
        next
      end
      if res.blank?
        csv << [""]
        next
      end
            tags = []
            res1 = res[0].tags
            res1.each{|info|
              info.delete "weight"
              
              tags << info.to_a.first[1]
            }
            csv << [tags*',']
    end
    
 end
  #随机生成的uid  
 武汉万达电影乐园 武汉万达汉秀 圣象地板微博 世友地板
filename = "data/fs-随机500-世友地板.csv"
task = GetUserTagsTask.new
CSV.open filename,"wb" do |csv|
csv << WeiboAccount.to_row_title(:full)
   path = File.join(Rails.root,"db/uid2")
   keywords = {}
   uids = []
   File.open(path,"r").each do|uid|
      uid = uid.strip
      uids << uid 
   end
   processing = true
   chars = ("0".."9").to_a#生成0至9的字符数组#["0","1","2","3","4","5","6","7","8","9"]
   begin
     puts chars
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
    puts line
    uid = uids[line.to_i]
    begin
     account =  task.load_weibo_user(uid)
     rescue Exception =>e
          if e.message =~ / does not exist!/
          csv << [uid]
          next
          end
     end
      if account.blank?
        csv << [uid.to_i]
        next
      end
    accounts =  account.to_row(:full)
    csv <<  accounts
   end
end
 武汉万达电影乐园 武汉万达汉秀 圣象地板微博 世友地板
# 数据F：提取【数据D】微博100以上（随机500个）近100条微博 
    filename = "data/近100条微博-世友地板.csv"
    CSV.open(filename,"wb"){|csv|
      csv << %w{name 微博内容 发布时间 转发数 评论数 互动总数 URL 原创 发布来源 原微博uid  原微博人昵称  }
     path = File.join(Rails.root, "db/uid5")
   task = GetUserTagsTask.new
    File.open(path,"r").each{|uid|
        uid = uid.strip
        begin  
            res = task.stable{task.api.statuses.user_timeline(uid:uid,count:100, page:1)}
           if !res['statuses'][0].nil?
              res['statuses'].each{|w|

                  srouce = ActionView::Base.full_sanitizer.sanitize(w.source) #去出所有的标签
                  url = "http://weibo.com/#{uid}/#{WeiboMidUtil.mid_to_str(w.id.to_s)}"
                  post_at = Time.parse(w.created_at).strftime("%Y-%m-%d %H:%M")
                  count = w.reposts_count + w.comments_count
                  origin = !w.retweeted_status
                  wuserid = ''
                  wuserscreen_name = ''
                  if !w.user.nil?
                  wuserid = w.user.id
                  wuserscreen_name = w.user.screen_name               
                  end  
                  csv << [w.user.screen_name, w.text,post_at, w.reposts_count, w.comments_count,count, url,origin, srouce,wuserid,wuserscreen_name]
                 
              }
          end
          rescue Exception=>e
              puts e.message
          end
      }
    }


#4.数据C：提取【数据B】的共同关注前500名列表，并进行关注类型分析：蓝V（企业、机构、媒体......）、普通、个人......dd
#根据3 uid 提取 共同关注  
 
1.
task = GetUserTagsTask.new
path = File.join(Rails.root, "db/uid")
uids = []
keywords = {}
CSV.open("data/共同关注_ASUS华硕-互动.csv","wb"){|csv|
File.open(path,"r").each do|uid|
   uid = uid.strip
 uids << uid
 end
  uids.each{|uid|
    begin
      ids = task.api.friendships.friends_ids(uid:uid,count:5000).ids
      ids.each{|id|
        next if id.nil? 
        keywords[id.to_s] ||= 1
        !keywords[id.to_s].nil? if keywords[id.to_s]+=1
      }
    rescue Exception =>e
      next
    end
  }
  keywords.keys.each do |line|
      csv << [line,keywords[line]]
  end
} && nil
# in shell
cat data/1428共同关注_1113.csv |sort| uniq -c| sort -nr > data/1428共同关注_1113_uniq.csv
cat data/1428共同关注_1113_uniq.csv | awk '{if($1>500)print($0)}' > data/1428共同关注_1113_filtered.csv
 
 2.武汉万达电影乐园 武汉万达汉秀 圣象地板微博 世友地板
task = GetUserTagsTask.new
path = File.join(Rails.root, "db/uid2")
uids = []
keywords = {}
CSV.open("data/共同关注-fs-世友地板.csv","wb"){|csv|
csv << %w{uid	 共同关注次数}
File.open(path,"r").each do|uid|
   uid = uid.strip
 uids << uid
 end
  uids.each{|uid|
    begin
      ids = task.api.friendships.friends_ids(uid:uid,count:5000).ids
      ids.each{|id|
        next if id.nil? 
        keywords[id.to_s] ||= 1
        !keywords[id.to_s].nil? if keywords[id.to_s]+=1
      }
    rescue Exception =>e
      next
    end   
  }
  keywords.keys.each do |line|
      csv << [line,keywords[line]]
  end
} && nil



#根据uid 查 基本信息  
武汉万达电影乐园 武汉万达汉秀 圣象地板微博 世友地板

filename = "信息补充-共同关注-hd-世友地板.csv"
task = GetUserTagsTask.new
CSV.open filename,"wb" do |csv|
path = File.join(Rails.root, "db/uid1")
 title = WeiboAccount.to_row_title(:full) 
 csv << title  
 File.open(path,"r").each do|uid|
    accounts = []
    uid = uid.strip
  puts uid
    begin
     account = task.load_weibo_user(uid)
     rescue SystemExit, Interrupt,IRB::Abort
        rescue 
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
    accounts = account.to_row(:full)
    csv << accounts
    end 
end
#5.数据C1：提取【数据B】标签排行 
# 武汉万达电影乐园 武汉万达汉秀 圣象地板微博 世友地板
 
filename = "data/标签排行-世友地板.csv"#"data/ 2-标签排行.csv"
keywords = {}
path = File.join(Rails.root,"db/name") 
CSV.open filename,"wb" do |csv|
    csv << %w{标签名 标签数}
    File.open(path,"r").each do|line|
     next if line.blank? 
      keyword = line.strip.split(',')
      next if keyword.blank?
      keyword.each do |line|
        keywords[line] ||= 1
        !keywords[line].nil? if keywords[line]+=1
      end  
    end
    keywords.keys.each do |line|
      csv << [line,keywords[line]]
    end
end
#6.数据C2：提取【数据B】近期发布微博中关键词排行'  圣象地板微博 世友地板
#
 
filename = "data/keywords-世友地板.csv"#"data/keywords.csv"
path = File.join(Rails.root,"db/uid1") 
  url = "http://www.tfengyun.com/user.php?action=keywords&userid="
  CSV.open filename,"wb" do |csv|
    csv << %w{uid }
    File.open(path,"r").each do|line|
        uid = line.strip
        begin
        res = Net::HTTP.get URI.parse(url+uid.to_s)
        keyword = JSON.parse(res)
        rescue Exception=>e
          next
        end
        keyword['keywords'].each do |line|
          csv << [line]
        end
        #csv << [uid] +keyword['keywords']
    end
end
 1. 统计关键词   圣象地板微博 世友地板
 

filename = "data/-关键词排行-世友地板.csv"
keywords = {}
path = File.join(Rails.root,"db/name") 
CSV.open filename,"wb" do |csv|
    csv << %w{关键词 关键数}
    File.open(path,"r").each do|line|
      keyword = line.strip
      next if keyword.blank? 
        keywords[line] ||= 1
        !keywords[line].nil? if keywords[line]+=1
    end
    keywords.keys.each do |line|
      csv << [line,keywords[line]]
    end
end



#数据F：提取【数据D】随机抽取500查出互动量
# 圣象地板微博 世友地板
 

filename = "data/活跃度-世友地板.csv"
CSV.open filename,"wb" do |csv|
  csv << %w{uid 平均转发率 平均评论率 平均转发 平均评论 活跃度 原创占比}
path = File.join(Rails.root, "db/uid2")
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

 #根据uid 查 基本信息 
 
filename = "data/信息补充-共同关注-xm-1.csv"
task = GetUserTagsTask.new
CSV.open filename,"wb" do |csv|
path = File.join(Rails.root, "db/uid1")
 title = WeiboAccount.to_row_title(:full) 
 csv << title  
 File.open(path,"r").each do|uid|
    accounts = []
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
    accounts = account.to_row(:full)
    csv << accounts
    end 
end

#8.数据E：提取【数据D】的共同关注前500名列表，并进行关注类型分析：蓝V（企业、机构、媒体......）、普通、个人......
#根据3 uid 提取 共同关注  汤臣倍健官博:1612134157 汤臣倍健营养健康风尚 2249615152 汤臣倍健淘宝官方旗舰店  2418499412
1.
task = GetUserTagsTask.new
ids = {}
path = File.join(Rails.root, "db/uid3")
uids = []
CSV.open("data汤臣倍健营养家-共同关注.csv","wb"){|csv|
File.open(path,"r").each do|uid|
   uid = uid.strip
 uids << uid
 end
  uids.each{|uid|
    begin
      ids = task.api.friendships.friends_ids(uid:2303673483,count:5000).ids
      ids.each{|id|
        csv << [id]
      }
    rescue Exception=>e
     
    next
   end
  }

} && nil

# in shell
cat data/1428共同关注_1113.csv |sort| uniq -c| sort -nr > data/1428共同关注_1113_uniq.csv
cat data/1428共同关注_1113_uniq.csv | awk '{if($1>500)print($0)}' > data/1428共同关注_1113_filtered.csv
2.  

task = GetUserTagsTask.new
path = File.join(Rails.root, "db/uid2")#openid
uids = []
keywords = {}
CSV.open("data/共同关注-2.csv","wb"){|csv|
csv << %w{uid 	共同关注次数}
File.open(path,"r").each do|uid|
   uid = uid.strip
 uids << uid
 end
  uids.each{|uid|
    begin
      ids = task.api.friendships.friends_ids(uid:uid,count:5000).ids
      ids.each{|id|
        next if id.nil? 
        keywords[id.to_s] ||= 1
        !keywords[id.to_s].nil? if keywords[id.to_s]+=1
      }
    rescue Exception =>e
      next
    end
  }
  keywords.keys.each do |line|
      csv << [line,keywords[line]]
  end
} && nil


task = GetUserTagsTask.new
path = File.join(Rails.root, "db/uid2")#openid
uids = []
CSV.open("data/共同关注-2000.csv","wb"){|csv|
csv << %w{主号uid  uid 	共同关注次数}
File.open(path,"r").each do|uid|
   uid = uid.strip
 uids << uid
 end
  uids.each{|uid|
    keywords = {}
    begin
      ids = task.api.friendships.friends_ids(uid:uid,count:5000).ids
      ids.each{|id|
        next if id.nil? 
        keywords[id.to_s] ||= 1
        !keywords[id.to_s].nil? if keywords[id.to_s]+=1
      }
    rescue Exception =>e
      next
    end
    number = 1
    keywords.keys.each do |line|
      break if number == 101
      csv << [uid,line,keywords[line]]
      number =number +1
    end
  }
 
} && nil

  #根据uid 查 基本信息 
 
filename = "data/信息补充-共同关注-互动-馨月汇北京月子会所.csv"
task = GetUserTagsTask.new
CSV.open filename,"wb" do |csv|
path = File.join(Rails.root, "db/uid1")
 title = WeiboAccount.to_row_title(:full) 
 csv << title  
 File.open(path,"r").each do|uid|
    accounts = []
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
    accounts = account.to_row(:full)
    csv << accounts
    end 
end


#随机 id 从库里面查 一些人   安卓网 2033175114 可口可乐 1795839430 果壳网 1850988623 超能双雄  3906939792
filename = "ASUS华硕-随机500的.csv"
task = GetUserTagsTask.new
CSV.open filename,"wb" do |csv|
csv << WeiboAccount.to_row_title(:full)
   sizes = 234308
   keywords = {}
   processing = true
   chars = ("0".."9").to_a#生成0至9的字符数组#["0","1","2","3","4","5","6","7","8","9"]
   begin
     newpass = "" 
     1.upto(sizes.to_s.size) { |i| newpass << chars[rand(chars.size-1)] }
     next if newpass.to_i > sizes 
     keywords[newpass] ||= 1
     !keywords[newpass].nil? if keywords[newpass]+=1
     if keywords.keys.size == 500
        processing = false 
     end
   end while processing == true
   keywords.keys.each do |line|
    id = line.to_i
    records = WeiboUserRelation.find_by_sql <<-EOF
  select by_uid by_uid from weibo_user_relations where uid ='1747360663' limit 1 offset #{id} 
EOF
    begin
     account = task.load_weibo_user(records[0].by_uid)
     rescue Exception =>e
          if e.message =~ / does not exist!/
          csv << [records[0].by_uid]
          next
          end
     end
      if account.blank?
        csv << [records[0].by_uid]
        next
      end
    accounts = account.to_row(:full)
    csv << accounts
   end
end



#备注排行 s = Roo::Excelx.new("KOL筛选合并字段.xlsx")
filename = "排行-1.csv"#"data/ 2-标签排行.csv"
keywords = {}
path = File.join(Rails.root,"db/name") 
CSV.open filename,"wb" do |csv|
    csv << %w{标签名 标签数}
    #File.open(path,"r").each do|line|
    i = 2
    while true
      break if i == 80783
      next if s.cell('A',i).blank? 
      keyword = s.cell('A',i).strip.split('，')#line.strip.split('，')
      next if keyword.blank?
      keyword.each do |line|
        keywords[line] ||= 1
        !keywords[line].nil? if keywords[line]+=1
      end  
      i+=1
    end
    keywords.keys.each do |line|
      csv << [line,keywords[line]]
    end
end

 杰士邦官方微博 岡本的官方微博 KEY情趣探索学院 LELO中国区微博
[1677892343, 2401518092, 2820633647, 2261060171]
filename = "现在是否是粉丝-岡本的官方微博.csv" 
task = GetUserTagsTask.new
path = File.join(Rails.root,"db/uid3")
CSV.open filename,"wb" do |csv|
csv << %w{uid 现在是否关注主号}
    target_uid = 2401518092 #2295615873  2637370247 2637370927
    File.open(path,"r").each do|line|
      uid = line.strip
      begin
        res = task.stable{task.api.friendships.show(source_id:uid,target_id:target_uid)}
      rescue Exception=>e
        if e.message =~ / for this time/
          sleep(300)
        end
        csv << [uid,e.message]
        next
      end
       csv << [uid,res.source.following ? "是":"否"]
    end
end



