
  #二次转发以每个用户为标准

  filename = "intel接口有转发的二次转发统计.csv"
  CSV.open filename,"wb" do |csv|
    csv << %w{UID URL 动作}
    old_csv = CSV.open "intel.csv"
    old_csv.each do |line|
    begin
      report = line[22]
      if report == "转发"
        uid = line[0]
        url = line[15]
        csv << [uid,url,report]
      end
      rescue Exception=>e
         puts e.message
      end
    end
  end

  #
  filename = "xph-url-by-mid"
  CSV.open filename,"wb" do |csv|
    csv << %w{微博帐号}
    urls = open "/home/rails/Desktop/xph-url"
    urls = urls.read
    urls = urls.strip.split("\n")
      urls.each do |url|
        weibo_id = WeiboMidUtil.str_to_mid URI.parse(url.strip).path.split("/").last
        csv << [weibo_id]
      end
  end

  #去除重复的weibo_id

  filename = "xph-weibo-id"
  CSV.open filename,"wb" do |csv|
    uids = open "/home/rails/Desktop/xph-id"
    uids = uids.read
    uids = uids.strip.split("\n")
    uids = uids.uniq
    uids.each do |uid|
      csv << [uid]
    end
  end

  #接口提取二次转发
  
  filename = "xph接口提取二次转发最新.csv"
  CSV.open filename,"wb" do |csv|
  csv << %w{微博帐号 转发数}
  task = GetUserTagsTask.new
  wids = open "xph-url-by-mid"
  wids = wids.read
  wids = wids.strip.split("\n")
  id_groups = wids.in_groups_of(100)
    id_groups.each do |ids|
      begin
        res = task.stable{task.api.statuses.count(ids:ids * ",")}
        res.each do |re|
          !re.nil ? csv << [re.id,re.reposts] : csv << [re.id,nil]
        end
        rescue Exception =>e
          puts e.message
      end
    end
  end

  #互动内容  

  start_time = '2014-09-27'
  end_time = '2014-10-27'
  filename = "xph互动内容娜娜.csv"
  CSV.open filename,"wb" do |csv|
    csv << %w{UID URL 内容 动作}
    uids = open '/home/rails/Desktop/xph-uid'
    uids = uids.read
    uids = uids.strip.split("\n")
    uids = uids.uniq
    uids.each do |uid|
      uid = uid.strip
      comments = WeiboComment.where("uid = ? and comment_uid = ? and comment_at between ? and ?",2637370247,uid,start_time,end_time)
        if !comments.blank?
          comments.each do |comment|
            url = "http://weibo.com/"+uid.to_s+"/"+WeiboMidUtil.mid_to_str(comment.weibo_id.to_s)
            mc = MComment.find(comment.comment_id)
            if !mc.blank? #如果不等于空的话(这块儿做了个非空的判断)
              content = mc.text
              csv << [uid,url,content,'评论']
            end
          end
      forwards = WeiboForward.where("uid = ? and forward_uid = ? and forward_at between ? and ?",2637370247,uid,start_time,end_time)
      if !forwards.blank?
        forwards.each do |forward|
          fc = MForward.find(forward.forward_id)
          url = "http://weibo.com/"+uid.to_s+"/"+WeiboMidUtil.mid_to_str(forward.weibo_id.to_s)
          if !fc.blank? #如果不等于空的话(这块儿做了个非空的判断)
            content = fc.text
            csv << [uid,url,content,'转发']
          end
        end
      end
    end
  end
end

  #消除重复

  filename = "intel-url"
  CSV.open filename,"wb" do |csv|
    uids = open "/home/rails/Desktop/intel-url"
    uids = uids.read
    uids = uids.strip.split("\n")
    uids = uids.uniq
    uids.each do |uid|
      csv << [uid]
    end
  end
  
  #微薄分类
  
  filename = "xph微博类别.csv" #原微博连接
  CSV.open filename,"wb" do |csv|
    csv << %w{URL Tag1 Tag2 Tag3 Tag4 Tag5 Tag6 GEO}
    urls = open 'url'
    urls = urls.read
    urls = urls.strip.split("\n")
    urls = urls.uniq
    urls.each do |url|
    begin
      weibo_id = WeiboMidUtil.str_to_mid URI.parse(url.strip).path.split("/").last
      post = Post.find_by_weibo_id(weibo_id)
      if !post.blank?
        csv << [url,post.tag1,post.tag2,post.tag3,post.tag4,post.tag5,post.tag6,post.geo]
        elsif
          csv << [url]
        end
    rescue Exception=>e
        puts url
        debugger
            csv << [uid, e.message]
        end
    end
  end
  
  #类别匹配

  filename = "xph原微博类别.csv"

  CSV.open filename,"wb" do |csv|

    csv << %w{URL Location Objective Message Group Topic}

    urls = open "url"
    urls = urls.read
    urls = urls.strip.split("\n")

    old_csv = CSV.read "/home/rails/Desktop/xph.csv"

    old_csv.each do |line|
      if urls.include?(line[0])
        csv << line
      end
    end
   
  end
  
  #取出不同的
  
  filename = "xph---111"
  CSV.open filename,"wb" do |csv|
    csv << %w{UID}
      quan2 = open '/home/rails/Desktop/xph-url'
      quan2 = quan2.read
      quan2 = quan2.strip.split("\n")

      quan = open '/home/rails/Desktop/xph-urls'
      quan = quan.read
      quan = quan.strip.split("\n")

      quan2.each do |q|
        if !quan.include?(q)
          csv << [q]
        end
      end
  end
