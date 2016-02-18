  
  name = "wdd"
  filename = "#{name}-nan-uid"
  CSV.open filename,"wb" do |csv|
    old_csv = CSV.open "wdd.csv"
    old_csv.each{|line|
      if line[1] != nil
        if line[1] == "男"
          csv << [line[0]]
        end
      end
    }
  end
  
  #(1)根据一些uids跑出这些uid的共同关注数量(降序) 最终结果
  
  keywords = {}
  task = GetUserTagsTask.new
  filename = "500用户共同关注排行.csv"
  CSV.open filename,"wb" do |csv|
    num = 0
    csv << %w{UID 共同关注次数}
    uids = open "500-uids"
    uids = uids.read
    uids = uids.strip.split("\n")
    uids = uids.uniq
    uids_nu = []
    uids.each{|uid|
      uid = uid.strip
      #返回uid关注的用户uids
      begin
          ids = task.api.friendships.friends_ids(uid:uid,count:5000).ids
          if !ids.include?(2637370927)
            num+=1
            uids_nu << uid
          end
          ids.each{|id|
            next if id.nil?
              if keywords[id.to_s].blank?
                keywords[id.to_s] = 0
              end
                keywords[id.to_s] += 1
          }
        rescue Exception =>e
          next
      end
    }
    keywords.sort{|a,b| b[1]<=>a[1]}.each do |line|
      csv << line
    end
  end
  
  #取出关注的用户
  
  task = GetUserTagsTask.new
  filename = "关注.csv"
  CSV.open filename,"wb" do |csv|
    csv << %w{UID}
      uid = 2978144983
      #返回uid关注的用户uids
          ids = task.api.friendships.friends_ids(uid:uid,count:5000).ids
          ids.each{|id|
            csv << [id]
          }
  end
gw
  #标签排行
  
  filename = "500-用户标签排行.csv"
  CSV.open filename,"wb" do |csv|
    all_tags = {}
    task = GetUserTagsTask.new
    uids = open "500-uid"
    uids = uids.read
    uids = uids.strip.split("\n")
    uids = uids.uniq
    uids.in_groups_of(20).each do |uid|
      res = task.stable{task.api.tags.tags_batch uid.compact*","}
      res.each{|tag|
          tags = tag.tags
          tags.each{|info|
            info.delete "weight"
            tag_name = info.to_a.first[1]
            all_tags[tag_name] ||= 0
            all_tags[tag_name] += 1
          }
        }
    end
    all_tags.sort{|a,b| b[1]<=>a[1]}.each{|line|
          csv << line
        }
  end
  
  #关键词排行

  filename = "关键词排行.csv"
  CSV.open filename,"wb" do |csv|
    csv << %w{关键词 关键词数量}
    all_keywords = {}
    url = "http://www.tfengyun.com/user.php?action=keywords&userid="
    task = GetUserTagsTask.new
    uids = open "uids"
    uids = uids.read
    uids = uids.strip.split("\n")
    uids = uids.uniq
    uids.each_with_index do |uid,index|
      begin
        res = task.stable{Net::HTTP.get URI.parse(url+uid.to_s)}
        keywords = JSON.parse(res)
        puts "#{index} : #{keywords['keywords']}"
        keywords['keywords'].each do |kw|
          all_keywords[kw] ||= 0 #当没有关键词时(all_keywords == nill)时 将0赋给这个变量 all_keywords[kw]
          all_keywords[kw] += 1
        end
      rescue Timeout::Error,JSON::ParserError
        puts "#{uid} Timeout Error"
        puts "A JSON text must at least contain two octets!"
      end
    end
    all_keywords.sort{|a,b| b[1]<=>a[1]}.each{|line|
      csv << line
    }
  end
  
  #转发KOL排行  //switchtabpos
  

  #根据短连接取出这条连接的的电击量
  
  filename = "点击量统计.csv"
  CSV.open filename,"wb" do |csv|
    task = GetUserTagsTask.new
    csv << %w{URL 点击量}
    urls = open '/home/rails/Desktop/urls'
    urls = urls.read
    urls = urls.strip.split("\n")
    urls = urls.uniq
    urls.each do |url|
      res = task.stable{Net::HTTP.post_form(URI("http://weiboyi.com/apiController.php"),{shortUrl:url,type:"clickNum"})}
      result = task.stable{JSON.parse res.body}
      csv << [url,result["clicks"]]
    end
  end

  #根据url算出点击量(以时间为参数)

  filename = "第一季度点击量统计.csv"
  CSV.open filename,"wb" do |csv|
    csv <<  %w{时间 url 点击量 微博内容}
     links = WeiboReport.analyse_links ['2637370927'],'2014-09-01','2014-09-30'
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

  #对数组元素进行分组统计(完成)

  filename = "500-uid-排行.csv"
  CSV.open filename,"wb" do |csv|
    status = {}
    csv << %w{URL 数量}
    num = 0
    urls = open '500-all-uid'
    urls = urls.read
    urls = urls.strip.split("\n")
      urls.each do |url|
        status[url] = 0
      end
      urls.each do |url|
        next if url.nil?
          if status[url].blank?
            status[url] = 0
          end
            status[url] += 1
      end
     status.sort{|a,b| b[1]<=>a[1]}.each do |line|
        csv << line
     end
  end
  
  filename = '转发贴-转发统计.csv'
  CSV.open filename,"wb" do |csv|
    status = {}
    csv << %w{元素 数量}
    old_csv = CSV.open "转发贴.csv"
      old_csv.each do |line|
        status[line[2]] = line[3]
      end
     status.sort{|a,b| b[1]<=>a[1]}.each do |line|
        csv << line
     end
  end
  
  
  
  #UID 昵称 位置 性别 粉丝 关注 微博 注册时间 认证信息 认证原因 keyword 微博url 是否转发 发布时间 内容 来源 转发数 评论数

  #uids与主号的互动数(可传递某个日期为参数)
  name = "东芝电脑有互动的粉丝"
  z_uid = 1765189187#与某个主号的
  filename = "#{name}的总互动数.csv"
  CSV.open filename,"wb" do |csv|
   csv << %w{UID 评论数 转发数 互动数}
    uids = open '东芝电脑有互动的粉丝'#文件的路径
    uids = uids.read
    uids = uids.strip.split("\n")
    uids = uids.uniq
    uids.each do |uid| 
      comment_num = WeiboComment.where("uid = ?",z_uid).where("comment_uid = ?",uid).count("distinct comment_id")
      forward_num = WeiboForward.where("uid = ?",z_uid).where("forward_uid = ?",uid).count("distinct forward_id")
      csv << [uid,comment_num,forward_num,comment_num+forward_num]
    end
  end

  #中国十月份总互动

  z_uid = 2637370927#与某个主号的
  start_time = '2014-09-28'#开始时间
  end_time = '2014-10-28'#终止时间
  filename = "intel.csv"
  CSV.open filename,"wb" do |csv|
  csv << %w{UID 评论数 转发数 互动数}
  uids = open "intel-uids"
  uids = uids.read
  uids = uids.strip.split("\n")
  uids = uids.uniq
  uids.each do |uid|
      comment_num = WeiboComment.where("uid = ? and comment_uid = ? and comment_at between ? and ?",z_uid,uid,start_time,end_time).count("distinct comment_id")
      forward_num = WeiboForward.where("uid = ? and forward_uid = ? and forward_at between ? and ?",z_uid,uid,start_time,end_time).count("distinct forward_id")
      csv << [uid,comment_num,forward_num,comment_num+forward_num]
    end      
  end

  #每个uid在某个时间段内与主号的二次转发数
  
  z_uid = 2637370927#与某个主号的
  start_time = '2014-10-01'#开始时间
  end_time = '2014-10-01'#终止时间
  filename = '二次转发.csv'
  uid_url = '/home/rails/Desktop/uids'
  uids = open uid_url
  uids = uids.read
  uids = uids.strip.split("\n")
  uids = uids.uniq
  CSV.open filename,"wb" do |csv|
    uids.each do |uid|
      wa = WeiboAccount.find_by_uid(uid) #可能有重复的用户
      next if wa.nil?
      row = wa.to_row
      WeiboForward.where(uid:z_uid,forward_uid:uid).where("forward_at between ? and ?",start_time, end_time).each{|f|
        mf = MForward.find(f.forward_id)
        if mf
          csv << [uid,mf.reposts_count]
        end
      }
    end
  end
  

  
  #主号在某个时间段内发的所有微博连接(不是监控接口/监控帐号直接从库里边取)
  
  z_uid = #与某个主号的
  start_time = '2014-09-01'#开始时间
  end_time = '2014-10-01'#终止时间
  filename = '提取微博连接.csv'
  CSV.open filename,"wb" do |csv|
    start_time = '2014-09-01'
    end_time = '2014-09-29'
      csv << %w{URL 发布时间}
      weibos = WeiboDetail.where("post_at between ? and ?",start_time,end_time)
        if weibos.count != 0
          weibos.each do |weibo|
            url = "http://weibo.com/"+weibo.uid.to_s+"/"+WeiboMidUtil.mid_to_str(weibo.weibo_id.to_s)
            time = weibo.post_at.strftime("%Y-%m-%d %H:%S")
            csv << [url,time]
          end
        end
    end 

  #不是监控帐号的

  filename = "话题.csv"
  CSV.open filename,"wb" do |csv|
    csv << %w{内容 话题}
    topic = ""
    old_csv = CSV.open 'intel30W-天数最新1.csv'
    old_csv.each do |line|
      content = line[1]
      if content.include?("#")
        content=~/.*#(.*)#.*/
        topic = $1
        csv << [content,topic]
      end
  end

  
  #通过关注时间来界定某个用户与主号的粉丝关系(新,老,非)
  
  z_uid = 2637370927#主号
  intel_time =  "2014-10-31"#以这个时间为界限来界定粉丝新老非
  weibo_time = intel_time.to_date.strftime("%Y-%m-%d %H:%M:%S") #这条微博的时间
  filename = "主号粉丝(新,老,非).csv"
  CSV.open filename,"wb" do |csv|
  csv << %w{uid 关注时间 新老非粉丝}
  uids = open '/home/rails/Desktop/uids'#文件的路径
  uids = uids.read
  uids = uids.strip.split("\n")
    uids.each do |uid|
      wurs = WeiboUserRelation.where("uid = ? and by_uid = ?",z_uid,uid)
      if wurs[0].blank?
        csv << [uid,nil,'非粉丝']
      else
        @follow_time = wurs[0].follow_time.strftime("%Y-%m-%d %H:%M:%S") #用户关注的时间
        @intel_type = case
        when @weibo_time > @follow_time
          csv << [uid,@follow_time,'老粉丝']
        when @weibo_time < @follow_time
          csv << [uid,@follow_time,'新粉丝']
        end
      end
    end
  end

  
  #每个uid的身份

  filename = "uid-身份.csv"
    task = GetUserTagsTask.new
    CSV.open filename,"wb" do |csv|
      csv << %w{uid 身份}
      path = File.join(Rails.root,"db/wuhan-uid.rb")
      File.open(path,"r").each do|line|
        uid = line.strip
        #可以根据sql语法去返回所需要的记录(数组)
        records = WeiboUserAttribute.find_by_sql <<-EOF
           select keyword_id from weibo_user_attributes where uid = #{uid}
          EOF
          #存放的是身份关键词的id然后用id进行查询
         type = {85 => "核心KOL",86 => "降级核心KOL",88 => "全量KOL",90 => "全网KOL",}
         if records.size==0  #csv文件处理没有的数据可以直接不写
            csv << [uid]
            next
         end
         row = []
         records.each do |line|
            keyword = type[line.keyword_id] #如果查询的
            if !keyword.nil? 
               row << keyword
            end
         end
         csv << [uid,row*',']
      end
    end
  
  #根据url查询这条微博的类型
  
   filename = "微博类型.csv"
   path = File.join(Rails.root,"db/urls")
   CSV.open filename,"wb" do |csv|
      csv << %w{URL 类型}
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

  #英特尔中国和芯品汇9月份（9.1-9.31）月报的数据，望明天上午11点左右给我呦~
  
  #1687399850 #加多宝的竞品帐号：2789871777,3231479672,1990514482,5236823068,1653196740
  #2637370927
  
  m = MonitWeiboAccount.find_by_uid(2637370927) 
  m.send_monthly_report "2015-01-20"

  #周报(月报)信息

  m = MonitWeiboAccount.find_by_uid(1687399850)
  opts = {1687399850 => [2789871777,3231479672,1990514482,5236823068,1653196740]}
  m.send_weekly_report '2015-01-21',opts
  
  m = MonitWeiboAccount.find_by_uid(2637370927)
  m.send_weekly_report '2015-02-03'
  
  #快速提取关键词
  
  ReportUtils.search_weibo_interface_by_keywords_time words, "data/search_平板词.csv", {skip_bluev:true,sum:1000}

  #将csv读取成xlsx文件(单个的压缩)

  Axlsx::Package.new do |p|
    p.workbook.add_worksheet(:name => "中国-buzz" ) do |sheet|
      old_csv = CSV.open '中国-buzz.csv' 
      lines = old_csv.read
      lines.each{|row|
        sheet.add_row row
      }
    end
      p.serialize('英特尔双帐号-20.xlsx')
  end

  #超大csv分成多个xlsx文件
  
  Axlsx::Package.new do |p|
    p.workbook.add_worksheet(:name => "图片") do |sheet|
      imgs = open "imgs"
      imgs = imgs.read
      imgs = imgs.strip.split("\n")
      num = 0
      numA = 0
      numB = 0
      imgs.each do |img_name|
        num += 1
        numA += 80
        numB += 80
        img = File.expand_path(img_name)
        sheet.add_image(:image_src => img, :noSelect => true, :noMove => true, :hyperlink=>"http://axlsx.blogspot.com") do |image|
          image.width = 80
          image.height = 80
          if num = 1
            image.start_at 0,0
            else
              image.start_at numA,numB
          end
        end
      end
    end
    p.serialize('测试一.xlsx')
  end
  
  Axlsx::Package.new do |p|
    p.workbook.add_worksheet(:name => "图片") do |sheet|
      img = File.expand_path("car3.jpg")
      sheet.add_image(:image_src => img, :noSelect => false, :noMove => false, :hyperlink=>"http://axlsx.blogspot.com") do |image|
        image.width = 80
        image.height = 80
        image.start_at 0,0
      end
    end
    p.serialize('测试三.xlsx')
  end
    
    
    #单独生成一个xlsx文件
    Axlsx::Package.new do |p|
      p.workbook.add_worksheet(:name => "图片") do |sheet|
        array = ["a","b","c","d","e"]
        sheet.add_row array
      end
      p.serialize('测试一.xlsx')
    end

  #某个时间段内有互动的
  
  z_uid = 1687399850 #与某个主号的
  start_time = '2015-01-08'#开始时间
  end_time = '2015-01-15'#终止时间
  filename = "有互动的粉丝" #都是基于近一个月发过微博的用户
  CSV.open filename,"wb" do |csv|
   csv << %w{UID}
      uids = open "three-month-uid"
      uids = uids.read
      uids = uids.strip.split("\n")
      uids.each do |uid|
        uid = uid.strip

        comments = WeiboComment.where("uid = ? and comment_uid = ? and comment_at < ?",z_uid,uid,start_time).
        forwards = WeiboForward.where("uid = ? and forward_uid = ? and forward_at < ?",z_uid,uid,start_time)

        comments.each do |comment|
            csv << [comment.comment_uid]
        end

        forwards.each do |forward|
            csv << [forward.forward_uid]
        end

      end
    end
  #三个月内:aaa-month-xph-zuixin.csv
  #一年内:a-year-xph.csv
  #一年以上:aaaa-year-xph.csv
  start_time = '2013-10-28'#开始时间
  end_time = '2014-10-28'#终止时间
  z_uid = 2637370247
  filename = "x.csv"
  CSV.open filename,"wb" do |csv|
   csv << %w{UID 总互动数}
    uids = open 'hudong-xph-uid'#文件的路径
    uids = uids.read
    uids = uids.strip.split("\n")
    uids = uids.uniq
    uids.each do |uid| 
      comment_num = WeiboComment.where("uid = ? and comment_uid = ?",z_uid,uid).where("comment_at between ? and ?",start_time,end_time).count("distinct comment_id")
      forward_num = WeiboForward.where("uid = ? and forward_uid = ?",z_uid,uid).where("forward_at between ? and ?",start_time,end_time).count("distinct forward_id")
      csv << [uid,forward_num,comment_num,comment_num+forward_num]
    end
  end
  
  #快速匹配互动数
  filename = "十一月.csv"
  CSV.open filename,"wb" do |csv|
  csv << %w{UID 昵称 互动数}
    uids = open 'uid'#文件的路径
    uids = uids.read
    uids = uids.strip.split("\n")
    uids.each do |uid|
      wa = WeiboAccount.find_by_uid(uid)
      c = WeiboComment.where("uid = ?",uid).where("comment_at between ? and ?",'2014-11-01','2014-12-01').count("distinct comment_id")
      f = WeiboForward.where("uid = ?",uid).where("forward_at between ? and ?",'2014-11-01','2014-12-01').count("distinct forward_id")
      csv << [uid,wa.screen_name,f+c]
    end
  end
  
  comment_num = WeiboComment.where("uid = ? and comment_uid = ?",2637370247,1068403532).where("comment_at < ?",'2013-10-28').count("distinct comment_id")
  forward_num = WeiboForward.where("uid = ? and forward_uid = ?",2637370247,1068403532).where("forward_at < ?",'2013-10-28').count("distinct forward_id")
  
  start_time = '2013-10-28'#开始时间
  #end_time = '2014-10-28'#终止时间
  z_uid = 2637370247
  filename = "xph-aaaa-year.csv"
  CSV.open filename,"wb" do |csv|
   csv << %w{UID F M 总互动数}
    uids = open 'hudong-xph-uid'#文件的路径
    uids = uids.read
    uids = uids.strip.split("\n")
    uids = uids.uniq
    uids.each do |uid| 
      comment_num = WeiboComment.where("uid = ? and comment_uid = ?",z_uid,uid).where("comment_at < ?",start_time).count("distinct comment_id")
      forward_num = WeiboForward.where("uid = ? and forward_uid = ?",z_uid,uid).where("forward_at < ?",start_time).count("distinct forward_id")
      csv << [uid,forward_num,comment_num,comment_num+forward_num]
    end
  end
  
  
  start_time = '2013-10-28'#开始时间
  #end_time = '2014-10-28'#终止时间
  z_uid = 2637370247
  filename = "year2.csv"
  CSV.open filename,"wb" do |csv|
   csv << %w{F M 总互动数}
      forward_num = comment_num = WeiboComment.where("uid = ? and comment_uid = ?",2637370247,1068403532).where("comment_at < ?",'2013-10-28').count("distinct comment_id")     
      comment_num = forward_num = WeiboForward.where("uid = ? and forward_uid = ?",2637370247,1068403532).where("forward_at < ?",'2013-10-28').count("distinct forward_id")
      csv << [forward_num,comment_num,forward_num+comment_num]
  end

  #每个帐号当月总互动次数

  #有互动的粉丝

  filename = '有互动的粉丝.csv'
  CSV.open filename,"wb" do |csv|
    csv << %w{UID}
    z_uid = 2637370247#与某个主号的
    uids = open '/home/rails/Desktop/某个时间断内与芯品汇有互动的UID'#文件的路径
    uids = uids.read
    uids = uids.strip.split("\n")
    uids = uids.uniq
    uids.each do |uid|
      wur = WeiboUserRelation.where('uid = ? and by_uid = ?',z_uid,uid)
      if !wur.blank?
        csv << [wur[0].by_uid]
      end
    end
  end

  #30W粉丝在九月份有互动的并把个人的信息都统计出来 
  
  hash = {}
  filename = '30W粉丝信息最新最新-九月份最新13.csv'
  CSV.open filename,"wb" do |csv|
    old_csv = CSV.open '2637370927_fans.csv'
    old_csv.each{|line|
      uid = line[0]
      hash[uid] = line
    }
    uids = open "九月份有互动的中国的粉丝的uid最新"
    uids = uids.read
    uids = uids.strip.split("\n")
    uids.each do |uid|
      line = hash[uid]
      if !line.blank?
        csv << line
      end
    end
  end

  #接口提取微博内容(从接口当中取出微博的内容)
  
  task = GetUserTagsTask.new
  filename = '根据url跑出内容.csv'
  CSV.open filename,"wb" do |csv|
    csv << %w{URL 微博ID 内容}
    urls = open '/home/rails/Desktop/urls'
    urls = urls.read
    urls = urls.strip.split("\n")
    urls = urls.uniq
    urls.each do |url|
      weibo_id = WeiboMidUtil.str_to_mid URI.parse(url.strip).path.split("/").last
      weibo = task.api.statuses.show(id:weibo_id)
      csv << [url,weibo_id,weibo.text]   
    end
  end

  #主号在某个时间段内的所有微博(监控微博帐号的在某个时间段内发布的微博)
  
  filename = "监控帐号的微博.csv"
  CSV.open filename,"wb" do |csv|
    target_id = 2637370927
    start_time = '2014-09-01'
    end_time = '2014-09-29'
      csv << %w{URL 发布时间}
      weibos = WeiboDetail.where("uid = ? and post_at between ? and ?",target_id,start_time,end_time)
        if weibos.count != 0
          weibos.each do |weibo|
            url = "http://weibo.com/"+weibo.uid.to_s+"/"+WeiboMidUtil.mid_to_str(weibo.weibo_id.to_s)
            time = weibo.post_at.strftime("%Y-%m-%d %H:%S")
            csv << [url,time]
          end
        end
    end
    
    
  #查看监控的主号有哪些以及它们的状态
  
  filename = "监控帐号.csv"
  CSV.open filename,"wb" do |csv|
    csv << %w{UID 昵称 监控状态 类型}
    #企业帐号
    mwas_enterparse = MonitWeiboAccount.where("status = 1")
    #个人帐号
    mwas_person = MonitWeiboAccount.where("status = 2")
    mwas_enterparse.each do |me|
      me.analyse_status == 1 ? csv << [me.uid,me.screen_name,'正在监控','企业'] : csv << [me.uid,me.screen_name,'不再监控','企业']
    end
    mwas_person.each do |mp|
      mp.analyse_status == 1 ? csv << [mp.uid,mp.screen_name,'正在监控','个人'] : csv << [mp.uid,mp.screen_name,'不再监控','个人']
    end
  end
  
  #近七天发贴量
  
  filename = "zzz.csv"
  CSV.open filename,"wb" do |csv|
    faties = open "hdq活跃度"
    faties = faties.read
    faties = faties.strip.split("\n")
    num = 0
    sum = 0
    faties.each {|num|
      if num.size == 1
        sum = num.to_i*6
        csv << [sum]
        elsif num.size > 1
          #这块儿的小数需要转换一下
          sum = (num.to_i*6+1).to_i
          csv << [sum]
      end
    }
  end
