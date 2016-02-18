
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
                rows << [w.user.screen_name,w.reposts_count, w.comments_count,scount]
                next 
              end
              next if end_time && Time.parse(w.created_at) > end_time
              if Time.parse(w.created_at) > start_time
                scount = w.reposts_count + w.comments_count
                origin = !w.retweeted_status
                csv << [w.user.screen_name,w.reposts_count, w.comments_count,scount]
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
   
