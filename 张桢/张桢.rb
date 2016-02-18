
一,英特尔商用频道运营数据分析(2014.11.14)

1,2014年1月-11月，官微的微博列表（平台导出）完成

2, 7、8、9、10、11月，各账号总共参与互动的人数，以及他们每月参与互动的人，其中@英特尔商用频道 需要互动的人的列表及次数。

3,ITDM和KOL在这几个月内，每月与互动的人数和次数。

账号：
英特尔商用频道
思科数据中心
CSDN云计算
IT经理世界杂志
中国云计算论坛
阿里云

#求出互动数和互动的总人数

  #(1)互动数
  filename = "十一月份互动总数.csv"
  CSV.open filename,"wb" do |csv|
  csv << %w{UID 互动数}
  start_time = '2014-11-01'#开始时间
  end_time = '2014-12-01'#终止时间  
  sum = 0
  uids = open "uids"
  uids = uids.read
  uids = uids.strip.split("\n")
    uids.each do |uid|
      forwards = WeiboForward.where("uid = ? and forward_at between ? and ?",uid,start_time,end_time)
      comments = WeiboComment.where("uid = ? and comment_at between ? and ?",uid,start_time,end_time)
      sum = comments.size + forwards.size
      csv << [uid,sum]
    end  
  end
  
  #互动人数
  name = "七月"
  start_time = '2014-07-01'#开始时间
  end_time = '2014-08-01'#终止时间
  filename = "#{name}互动人数.csv" #都是基于近一个月发过微博的用户
  CSV.open filename,"wb" do |csv|
   csv << %w{UID 人数}
      uids = open "uids"
      uids = uids.read
      uids = uids.strip.split("\n")
      uids.each do |uid|
      
        rows = [] #存放有互动的id
        comments = WeiboComment.where("uid = ? and comment_at between ? and ?",uid,start_time,end_time)
        forwards = WeiboForward.where("uid = ? and forward_at between ? and ?",uid,start_time,end_time)

        comments.each do |comment|
            rows << [comment.comment_uid]
        end

        forwards.each do |forward|
            rows << [forward.forward_uid]
        end
        
        csv << [uid,rows.uniq.size]
      end
    end
    
  #第二个需求商用频道所有互动的人
    
    #去除重复的数据
    
    filename = "syhd-uid"
    CSV.open filename,"wb" do |csv|
      csv << %w{UID}
      uids = open "商用频道互动人在7-11月份"
      uids = uids.read
      uids = uids.strip.split("\n")
      uids = uids.uniq
      uids.each do |uid|
        csv << [uid]
      end            
    end
    
    #用户信息
    
    filename = "用户基本信息.csv" #没有活跃度的
    CSV.open filename,"wb" do |csv|
      #csv << %w{uid 昵称 位置 性别 粉丝 关注 微博 认证信息 认证原因 备注 标签}
      task = GetUserTagsTask.new
      csv << WeiboAccount.to_row_title(:full) 
      uids = open "syhd-uid"
      uids = uids.read
      uids = uids.strip.split("\n")
      uids = uids.uniq
      uids.each do|line|
           uid = line
           begin #解决异常      
               res = task.stable{task.api.users.show(uid:uid)}
               if !res.blank?
                  account = task.save_weibo_user(res)
               else
                  csv << [uid,'取不到此用户信息']
                  next
               end
            rescue Exception=>e
                if e.message =~ /User does not exists!/
                  csv << [uid,'此用户不存在']
                  next
                end
            end
            if res.status.nil?
              csv << account.to_row(:full)
              next
            end
           csv << account.to_row(:full)
      end
  end
  
  1970685982
  
  #算出这些用户每个月份与商用频道的互动量情况
  
  start_time = '2014-07-01'#开始时间
  end_time = '2014-08-01'#终止时间
  filename = "七月份.csv"
  CSV.open filename,"wb" do |csv|
  csv << %w{UID 互动数}
  uids = open "uid"
  uids = uids.read
  uids = uids.strip.split("\n")
  uids = uids.uniq
  uids.each do |uid|
      fc = 0
      mc = 0
      comment_num = WeiboComment.where("uid = ? and comment_at between ? and ?",uid,start_time,end_time).count("distinct comment_id")
      mc += comment_num 
      forward_num = WeiboForward.where("uid = ? and forward_at between ? and ?",uid,start_time,end_time).count("distinct forward_id")
      fc += forward_num
  end
    csv << [uid,fc+mc]     
  end
  
  #总互动量
  
  filename = '用户的总互动量'.csv
  CSV.open filename,"wb" do |csv|
    status = {}
    csv << %w{元素 数量}
    uids = open '商用频道互动人'
    uids = uids.read
    uids = uids.strip.split("\n")
      uids.each do |uid|
        status[uid] = 0
      end
      uids.each do |uid|
        next if uid.nil? 
          if status[uid].blank?
            status[uid] = 0 
          end
            status[uid] += 1
      end
     status.sort{|a,b| b[1]<=>a[1]}.each do |line|
        csv << line
     end 
  end
  
  #找出七月份与主号有互动的uid然后再与kol和itdm匹配
  
  name = "七月"
  start_time = '2014-07-01'#开始时间
  end_time = '2014-08-01'#终止时间陪我
  filename = "#{name}互动人数.csv" #都是基于近一个月发过微博的用户
  CSV.open filename,"wb" do |csv|
   csv << %w{UID 人数}
      uids = open "uids"
      uids = uids.read
      uids = uids.strip.split("\n")
      uids.each do |uid|
      
        rows = [] #存放有互动的id
        comments = WeiboComment.where("uid = ? and comment_at between ? and ?",uid,start_time,end_time)
        forwards = WeiboForward.where("uid = ? and forward_at between ? and ?",uid,start_time,end_time)

        comments.each do |comment|
            rows << [comment.comment_uid]
        end

        forwards.each do |forward|
            rows << [forward.forward_uid]
        end
        
        csv << [uid,rows.uniq.size]
      end
    end
  
  
  
  #每个帐号的每个月份的uid(这个方法很慢)
  
  
  
  filename = '十一月份itdm互动人数.csv' 
  CSV.open filename,"wb" do |csv|
  csv << %w{UID 互动人数}
  start_time = '2014-11-01'
  end_time = '2014-12-01'
  
  uids = open "uids"
  uids = uids.read
  uids = uids.strip.split("\n")

  kol_uids = open "itdm-uid"
  kol_uids = kol_uids.read
  kol_uids = kol_uids.strip.split("\n")
  
  uids.each do |uid|
    rows = []
    kol_uids.each do |kid|
      comments = WeiboComment.where("uid = ? and comment_uid = ? and comment_at between ? and ?",uid,kid,start_time,end_time)
      forwards = WeiboForward.where("uid = ? and forward_uid = ? and forward_at between ? and ?",uid,kid,start_time,end_time)
      #评论的uid
      comments.each do |comment|
          rows << [comment.comment_uid]
      end
      #转发的uid
      forwards.each do |forward|
          rows << [forward.forward_uid]
      end
    end
    csv << [uid,rows.uniq.size]
  end
end


  #kol-uid
  filename = 'kol-uid.csv'
  CSV.open filename,"wb" do |csv|
    csv << %w{KOL-UID 类别}
    nums = [75,85,86,88,90,91,92]
    nums.each do |num|
      wuas = WeiboUserAttribute.where("keyword_id = ?",num)
      wuas.each do |wua|
        if num == 75
          csv << [wua.uid,'KOL']
          elsif num == 85
            csv << [wua.uid,'核心kol']
            elsif num == 86
              csv << [wua.uid,'降级核心KOL']
              elsif num == 88
                csv << [wua.uid,'全量KOL']
                elsif num == 90
                  csv << [wua.uid,'全网KOL']
                  elsif num == 91
                    csv << [wua.uid,'媒体KOL']
                    elsif num == 92
                      csv << [wua.uid,'降级媒体KOL']
        end
      end
    end
  end

  #itdm-uid
  filename = 'itdm-uid.csv'
  CSV.open filename,"wb" do |csv|
    csv << %w{ITDM-UID 类别}
    nums = [77,78]
    nums.each do |num|
      wuas = WeiboUserAttribute.where("keyword_id = ?",num)
      wuas.each do |wua|
         if num == 77
          csv << [wua.uid,'ITDM']
          elsif num == 78
            csv << [wua.uid,'疑似ITDM']
        end
      end
    end
  end
  
  #@xph或者@intel 微薄@量统计(一个时间段内的)
  filename = "@数量统计.csv"
  CSV.open filename,"wb" do |csv|
    csv << %w{UID @数量}
    num = 0
    start_time = '2015-01-08'
    end_time = '2015-01-15'
    uids = open "uids"
    uids = uids.read
    uids = strip.split("\n")
    uids = uids.uniq
    uids.each do |uid|
      num = WeiboMention.where("uid = ?",1687399850).where("mention_at between ? and ?",'2015-01-08','2014-01-15').count("distinct mention_id")
      csv << [uid,num]
    end
  end
  
  #找出两个帐号粉丝的关注列表
  
  task = GetUserTagsTask.new
  filename = "中国关注用户列表.csv"
  CSV.open filename,"wb" do |csv|
    csv << %w{主号uid 关注uid}
    old_csv = open "2637370927_fans.csv"
    old_csv.each{|line|
      line = line.strip.split(",")
      begin
        if line[0] != "UID" 
          uid = line[0]
          ids = task.api.friendships.friends_ids(uid:uid,count:5000).ids
          ids.each{|id|
            csv << [uid,id]
          }
        end
        rescue Exception =>e
          if e.message =~ /out of limitation/
            sleep 1800
          elsif e.message =~ /incompatible character encodings: UTF-8 and ASCII-8BIT/
            next
        end
      end
    }
  end
  
  
  filename = "wu"
  CSV.open filename,"wb" do |csv|
    csv << %w{UID}
    
      quan2 = open 'you'
      quan2 = quan2.read
      quan2 = quan2.strip.split("\n")
      quan2 = quan2.uniq
      

      quan = open '2000-uid'
      quan = quan.read
      quan = quan.strip.split("\n")
      quan = quan.uniq

      quan.each do |qu|
        if !quan2.include?(qu)
          csv << [qu]
        end
      end
  end
  
  filename = 'xph-uid'
  CSV.open filename,"wb" do |csv|
    z_uid = 2637370247
    task = GetUserTagsTask.new
    wurs = WeiboUserRelation.where("follow_time between ? and ? and uid = ?",'2014-07-01','2014-11-30',z_uid)
    wurs.each{|wur|
      csv << [wur.by_uid]
    }
  end
  
  #没有话题提取条件
  
  task = GetUserTagsTask.new
  filename = '剩余用户发布的前100条微博.csv'#返回最新的微薄最多返回100条
  CSV.open filename,"wb" do |csv|
    csv << %w{UID URL 内容}
    uids = open "wu"
    uids = uids.read
    uids = uids.strip.split("\n")
    uids = uids.uniq
    uids.each do |uid|
      begin
        res = task.stable{task.api.statuses.user_timeline(uid:uid,count:100)}
        res['statuses'].each{|w|
          url = "http://weibo.com/#{uid}/#{WeiboMidUtil.mid_to_str(w.id.to_s)}"
          content = w.text
          csv << [uid,url,content]         
        }
      rescue Exception=>e
        puts e.message
        if e.message =~ /User does not exists!/
          csv << [uid,"此用户已被屏蔽"]
      end
    end
  end
end
  
  #微薄内容关键词统计
  
  def play
    keywords = open "play-keywords"
    keywords = keywords.read
    keywords = keywords.strip.split("\n")
    keywords = keywords.uniq
  end
  
  def user_test(uid,contents,keywords)
    row = []
    keywords.each{|keyword|
      m = 0
      contents.each{|content|
        keyword.each{|kw|
          if !content.nil?
            if content.include?(kw)
              m += 1
            end
          end
        }
      }
      row << m
    }
   row
  end
  
  
  filename = "剩余用户关键词统计.csv"
  CSV.open filename,"wb" do |csv|
    csv << %w{UID 极客 游戏 动漫 美剧 体育}
    old_csv = CSV.open "剩余用户发布的前100条微博.csv"
    row = []
    contents = []
    temp = nil
    old_csv.each{|line|
      start_uid = line[0]
      if temp != start_uid
        if !temp.nil?
          row=user_test(temp,contents,keywords)
          csv << [temp]+row
      end
        contents = []
      end
        contents << line[2]
        temp = line[0]
    }
  end
  
  filename = "wu"
  CSV.open filename,"wb" do |csv|
    shis = open "ceshi-uid"
    shis = shis.read
    shis = shis.strip.split("\n")
    shis = shis.uniq
    shis.each do |uid|
      csv << [uid]
    end
  end
