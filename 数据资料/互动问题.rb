
  #sql匹配互动数(快速匹配用户的各种互动数)
  
  
  filename = "总互动.csv" #都是基于近一个月发过微博的用户
  CSV.open filename,"wb" do |csv|
    csv << %w{UID 互动数}
      z_uid = 2295615873
      fcs = WeiboForward.find_by_sql <<-EOF
      select uid,sum(count) num from (
        select 'c',comment_uid uid,count(distinct comment_id) as count from weibo_comments where uid = "#{z_uid}" group by comment_uid 
        union
        select 'f',forward_uid uid,count(distinct forward_id) as count from weibo_forwards where uid = "#{z_uid}" group by forward_uid
      ) as fc group by uid
      EOF
      fcs.each do |fc|
        csv << [fc.uid,fc.num]
      end
  end
  
  #周报内容
  1,英特尔双帐号微薄列表分析(buzz和@数及粉丝增长情况) --->邵帅 完成情况100%
  2,IDF用户筛选(基本信息,活跃度,与双帐号的互动次数,是否是英特尔双帐号粉丝) --->张桢,何阳 完成情况100%
  3,LG微薄精选 --->何阳 完成情况100%
  4,娱乐名人(同关注排行,信息) --->张桢 完成情况100%
  5,双帐号每周微博列表(没周微博信息及微薄类型) --->何阳,邵帅 完成情况100%
  6,英特尔双帐号粉丝更新(基本信息,活跃度,与各自帐号的互动次数) --->完成50%按照下周需求走
    
    #3.23-29，3.30-4.5，4.6-12，4.13-19，4.20-26，4.27-5.3，5.4-10，5.11-17，5.18-24
    #3.02-3.9,3.9-3.16,3.16-3.23
    filename = "intel-互动-7.csv" #都是基于近一个月发过微博的用户
    CSV.open filename,"wb" do |csv|
      csv << %w{UID 互动数}
        z_uid = 2637370927
        start_time = "2015-07-01"
        end_time = "2015-07-16"
        fcs = WeiboForward.find_by_sql <<-EOF
        select uid,sum(count) num from (
          select 'c',comment_uid uid,count(distinct comment_id) as count from weibo_comments where uid = "#{z_uid}" and comment_at between "#{start_time}" and "#{end_time}" group by comment_uid 
          union
          select 'f',forward_uid uid,count(distinct forward_id) as count from weibo_forwards where uid = "#{z_uid}" and forward_at between "#{start_time}" and "#{end_time}" group by forward_uid
        ) as fc group by uid
        EOF
        fcs.each do |fc|
          csv << [fc.uid,fc.num]
        end
    end
  
  filename = "B转发.csv" #都是基于近一个月发过微博的用户
  CSV.open filename,"wb" do |csv|
    csv << %w{UID 转发量}
      z_uid = 1687399850
      start_time = "2015-01-15"
      end_time = "2015-01-22"
      fcs = WeiboForward.find_by_sql <<-EOF
        select forward_uid uid,count(distinct forward_id) as count from weibo_forwards where uid = "#{z_uid}" and forward_at between "#{start_time}" and "#{end_time}" group by forward_uid
      EOF
      fcs.each do |fc|
        csv << [fc.uid,fc.count]
      end
  end
  
  filename = "B评论.csv" #都是基于近一个月发过微博的用户
  CSV.open filename,"wb" do |csv|
    csv << %w{UID 评论量}
      z_uid = 1687399850
      start_time = "2015-01-15"
      end_time = "2015-01-22"
      fcs = WeiboComment.find_by_sql <<-EOF
        select 'c',comment_uid uid,count(distinct comment_id) as count from weibo_comments where uid = "#{z_uid}" and comment_at between "#{start_time}" and "#{end_time}" group by comment_uid 
      EOF
      fcs.each do |fc|
        csv << [fc.uid,fc.count]
      end
  end
  
  hash = {}
  filename = "终极极客总互动.csv"
  CSV.open filename,"wb" do |csv|
    old_csv = CSV.open '极客总互动.csv'
    
    old_csv.each{|line|
      uid = line[0]
      hash[uid] = line
    }
    uids = open "jike-uid"
    uids = uids.read
    uids = uids.strip.split("\n")

    uids.each do |uid|
      line = hash[uid]
      if !line.blank?
        csv << line
      end
    end
  end 
  
  #一部分用户的与某个主号的互动量
    
  z_uid = 2295615873#与某个主号的
  filename = "商用频道互动问题用户.csv" #极客特列(极客互动情况3)
  CSV.open filename,"wb" do |csv|
  csv << %w{UID 昵称 十一月以来 七月以来 2014年以来 总互动}
  uids = open "uid"
  uids = uids.read
  uids = uids.strip.split("\n")
  uids = uids.uniq
  uids.each do |uid|
      
      wa = WeiboAccount.find_by_uid(uid)
      
      c_shiyi = WeiboComment.where("uid = ? and comment_uid = ? and comment_at between ? and ?",z_uid,uid,'2014-11-01','2014-12-19').count("distinct comment_id")
      f_shiyi = WeiboForward.where("uid = ? and forward_uid = ? and forward_at between ? and ?",z_uid,uid,'2014-11-01','2014-12-19').count("distinct forward_id")      

      c_qi = WeiboComment.where("uid = ? and comment_uid = ? and comment_at between ? and ?",z_uid,uid,'2014-07-01','2014-12-19').count("distinct comment_id")
      f_qi = WeiboForward.where("uid = ? and forward_uid = ? and forward_at between ? and ?",z_uid,uid,'2014-07-01','2014-12-19').count("distinct forward_id")
            
      c_yi = WeiboComment.where("uid = ? and comment_uid = ? and comment_at between ? and ?",2295615873,3492650961,'2014-01-01','2015-01-13').count("distinct comment_id")
      f_yi = WeiboForward.where("uid = ? and forward_uid = ? and forward_at between ? and ?",2295615873,3492650961,'2014-01-01','2015-01-13').count("distinct forward_id")
      
      c_yi = WeiboComment.where("uid = ? and comment_uid = ?",2295615873,3492650961).count("distinct comment_id")
      f_yi = WeiboForward.where("uid = ? and forward_uid = ?",2295615873,3492650961).count("distinct forward_id")
      
      c_sum = WeiboComment.where("uid = ? and comment_uid = ?",z_uid,uid).count("distinct comment_id")
      f_sum = WeiboForward.where("uid = ? and forward_uid = ?",z_uid,uid).count("distinct forward_id")
      
      csv << [uid,wa.screen_name,c_shiyi+f_shiyi,c_qi+f_qi,c_yi+f_yi,c_sum+f_sum]
      
    end      
  end
  
  
  z_uid = 2637370927#与某个主号的
  filename = "近3个月idf.csv" #极客特列(极客互动情况3)
  CSV.open filename,"wb" do |csv|
  csv << %w{UID 转发 评论 总互动}
  uids = open "uids"
  uids = uids.read
  uids = uids.strip.split("\n")
  uids = uids.uniq
    uids.each do |uid|
      wa = WeiboAccount.find_by_uid(uid)
      c_yi = WeiboComment.where("uid = ? and comment_uid = ? and comment_at between ? and ?",z_uid,uid,'2015-03-01','2015-04-20').count("distinct comment_id")
      f_yi = WeiboForward.where("uid = ? and forward_uid = ? and forward_at between ? and ?",z_uid,uid,'2015-03-01','2015-04-20').count("distinct forward_id")
      csv << [uid,f_yi,c_yi,c_yi+f_yi]
    end
  end
  
  z_uid = 2637370927#与某个主号的
  #start_time = '2014-07-01'#开始时间
  #end_time = '2014-08-01'#终止时间
  filename = "极客互动情况.csv" #极客特列(极客互动情况3)
  CSV.open filename,"wb" do |csv|
  csv << %w{UID 总互动}
  uids = open "游戏"
  uids = uids.read
  uids = uids.uniq
    uids = uids.strip.split("\n")
  uids.each do |uid|
      
      c_sum = WeiboComment.where("uid = ? and comment_uid = ?",z_uid,uid).count("distinct comment_id")
      f_sum = WeiboForward.where("uid = ? and forward_uid = ?",z_uid,uid).count("distinct forward_id")
      
      csv << [uid,c_sum+f_sum]
      
    end
  end
  
  #一部分用户与主号的互动数
  
  filename = "xph娜娜.csv"
  CSV.open filename,"wb" do |csv|
  csv << %w{UID 转发 评论 互动次数}
    z_uid = 2637370247
    uids = open "/home/rails/Desktop/xph-uid"
    uids = uids.read
    uids = uids.strip.split("\n")
    uids = uids.uniq
      uids.each do |uid|
        uid = uid.strip
        comment_num = WeiboComment.where("uid = ?",z_uid).where("comment_uid = ?",uid).count("distinct comment_id")
        forward_num = WeiboForward.where("uid = ?",z_uid).where("forward_uid = ?",uid).count("distinct forward_id")
        csv << [uid,comment_num,forward_num,comment_num+forward_num]
    end
  end
    
  filename = "names-by-uid.csv"
  CSV.open filename,"wb" do |csv|
    csv << %w{昵称 UID}
    names = open "names"
    names = names.read
    names = names.strip.split("\n")
    names.each do |name|
      wa = WeiboAccount.find_by_screen_name(name)
      if wa.blank?
        csv << [name,nil]
        elsif
          csv << [name,wa.uid]
        end
    end
  end
  
  #找出这些用户在近一个星期内发布的所有微博以及每条微薄的互动数--->每个用户的互动数
  
  filename = "微薄互动数.csv"
  CSV.open filename,"wb" do |csv|
   task = GetUserTagsTask.new
      csv << %w{UID 转发 评论 互动总数}
      start_time = '2014-09-22'
      end_time = '2014-11-20'
      uids = open "uids"
      uids = uids.read
      uids = uids.strip.split("\n")
      uids = uids.uniq
      uids.each{|uid|
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
                scount = w.reposts_count + w.comments_count
                rows << [uid,w.user.screen_name,w.reposts_count, w.comments_count,scount]
                next 
              end
              next if end_time && Time.parse(w.created_at) > end_time
              if Time.parse(w.created_at) > start_time
                scount = w.reposts_count + w.comments_count
                origin = !w.retweeted_status
                csv << [uid,w.user.screen_name,w.reposts_count, w.comments_count,scount]
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
  
  #何样统计互动数
  
  filename = '转发统计.csv'
  CSV.open filename,"wb" do |csv|
    status = {}
    csv << %w{元素 数量}
      old_csv = CSV.open "微薄互动数.csv"
      old_csv.each do |line|
        name = line[0]
        num = line[1].to_i
        #将name赋给hash作为key
        if status[name].blank?
          status[name] = num
          else
            status[name] += num
        end
      end
     status.each do |line|
        csv << line
     end
  end
  
  #有一些微博和uids抛出这些用户与这些微薄的总互动数
  
  filename = "微博互动.csv"
  CSV.open filename,"wb" do |csv|
    
    csv << %w{UID 转发 评论 互动数}

    uids = open '2000-uid'#文件的路径
    uids = uids.read
    uids = uids.strip.split("\n")
    uids = uids.uniq

    urls = open 'url'#文件的路径
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
  
  #找出没有的

  filename = "没有的name"
  CSV.open filename,"wb" do |csv|
  
  names = open "names"
  names = names.read
  names = names.strip.split("\n")
  namess = open "namess"
  namess = namess.read
  namess = namess.strip.split("\n")
  
    names.each do |name|
      if !namess.include?(name)
        csv << [name]
      end 
    end
  end
  #接口提取每条微薄的互动
  filename = "微薄互动数.csv"
  task = GetUserTagsTask.new
  CSV.open filename,"wb" do |csv| 
    csv << %w{微博url 互动数}
    urls = open 'urls'#文件的路径
    urls = urls.read
    urls = urls.strip.split("\n")
    urls = urls.uniq
    urls.each{|url|
      weibo_id = WeiboMidUtil.str_to_mid URI.parse(url.strip).path.split("/").last
      res = task.stable{task.api.statuses.show(id:weibo_id)}
      debugger
    }
  end
