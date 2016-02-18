  #这个可以统计词的数量
  filename = "分割词组"
  CSV.open filename,"wb" do |csv|
    words = open "words"
    words = words.read
    #words.scan('\w')#或者str.scan(/(?<=').*(?=')/)
    words = words.strip.split("，") #记住这里是要分好中英文逗号
    words = words.uniq
    words.each{|word|
      csv << [word]
    }
  end
  
  #这个是以词为主的
  name = "关键词微薄"
  filename = "#{name}统计.csv"
  CSV.open filename,"wb" do |csv|
    csv << %w{关键词 搜索量}
    start_time = '2015-01-01'
    end_time = '2015-05-05'
    keywords = open "keywords"
    keywords = keywords.read
    keywords = keywords.strip.split("\n")
    keywords = keywords.uniq
    task = GetUserTagsTask.new
    url = "https://c.api.weibo.com/2/search/statuses/limited.json?"
    keywords.each{|word|
      word.sub("/","~")
      pas={access_token:"2.002F_9jFDtpNAD47a763f759FICatB",q:word,starttime:start_time.to_i,endtime:end_time.to_i,count:1,antispam:1,dup:1}
      res = task.stable(retry_limit:500, retry_interval:10){Hashie::Mash.new(JSON.parse(open(url+pas.to_query).read))}
      csv << [word,"#{res.total_number}"]
    }
  end
  
  #这个是以词为主的
  name = "sheet2微薄量"
  filename = "#{name}统计.csv"
  CSV.open filename,"wb" do |csv|
    csv << %w{关键词 日期 搜索量}
    keywords = open "keywords"
    keywords = keywords.read
    keywords = keywords.strip.split("\n")
    keywords = keywords.uniq
    task = GetUserTagsTask.new
    url = "https://c.api.weibo.com/2/search/statuses/limited.json?"
    keywords.each{|word|
      word.sub("/","~")
      start_time = Time.new(2012,12,01)
      24.times{ #2013-01-01 到 2014-12-31
        start_time += 1.month
        end_time = start_time + 1.month #每个月份循环一次
        pas={access_token:"2.002F_9jFDtpNADac000c4d2dEEO6kB",q:word,starttime:start_time.to_i,endtime:end_time.to_i,count:1,antispam:1,dup:1}
        res = task.stable(retry_limit:500, retry_interval:10){Hashie::Mash.new(JSON.parse(open(url+pas.to_query).read))}
        csv << [word,start_time,"#{res.total_number}"]
      }
    }
  end
  
  
  #这个是以月份为主的
  name = "微薄量"
  filename = "#{name}统计2.csv"
  CSV.open filename,"wb" do |csv|
    csv << %w{关键词 日期 搜索量}
    keywords = open "匹配词"
    keywords = keywords.read
    keywords = keywords.strip.split("\n")
    keywords = keywords.uniq
    task = GetUserTagsTask.new
    num = 0
    url = "https://c.api.weibo.com/2/search/statuses/limited.json?"
    start_time = Time.new(2013,12,01)
    13.times{ #2013-01-01 到 2014-12-31
      if num % 13 == 0
        start_time += 1.month
        end_time = start_time + 1.month
        keywords.each {|word|
          word.sub("/","~")
          pas={access_token:"2.002F_9jFDtpNADac000c4d2dEEO6kB",q:word,starttime:start_time.to_i,endtime:end_time.to_i,count:1,antispam:1,dup:1}
          res = task.stable(retry_limit:500, retry_interval:10){Hashie::Mash.new(JSON.parse(open(url+pas.to_query).read))}      
          csv << [word,start_time,"#{res.total_number}"]
        }
      end
    }
  end
  
  #进一步的整理
  name = "微薄量"
  filename = "#{name}统计3.csv"
  CSV.open filename,"wb" do |csv|
    csv << %w{日期 搜索量}
    keywords = open "匹配词"
    keywords = keywords.read
    keywords = keywords.strip.split("\n")
    keywords = keywords.uniq
    task = GetUserTagsTask.new
    status = {}
    num = 0
    sums = 0 #总量
    url = "https://c.api.weibo.com/2/search/statuses/limited.json?"
    start_time = Time.new(2013,12,01)
    13.times{ #2013-01-01 到 2014-12-31
      if num % 13 == 0
        start_time += 1.month
        end_time = start_time + 1.month
        keywords.each {|word|
          word.sub("/","~")
          pas={access_token:"2.002F_9jFDtpNADac000c4d2dEEO6kB",q:word,starttime:start_time.to_i,endtime:end_time.to_i,count:1,antispam:1,dup:1}
          res = task.stable(retry_limit:500, retry_interval:10){Hashie::Mash.new(JSON.parse(open(url+pas.to_query).read))}
          status[word] = "#{res.total_number}".to_i
          #csv << [word,start_time,"#{res.total_number}"]
        }
        sums = status.values.sum
        #每循环一次都要清空一下status的values
        keywords.each{|w|
          key = w.strip
          status[key] = 0
        }
        csv << [start_time,sums]
      end
    }
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
  
  
  filename = "两个帐号匹配信息.csv"
    CSV.open filename,"wb" do |csv|
    one_csv = CSV.open '新品会最终.csv'#(这个csv文件是没有对内容正负面影响进行统计的csv文件)
    lines1 = one_csv.read
      lines1.each do |line|
        csv << line
      end 
    two_csv = CSV.open 'bbb.csv'#(这个csv文件是没有对内容正负面影响进行统计的csv文件)
    lines2 = two_csv.read
      lines2.each do |line|
        csv << line
    end
  end
  
  user = task.api.users.show(screen_name:"许晓婉F")
  
  #男女比例判断
  
  #匹配
  hash = {}
  filename ="hw2.csv"
  CSV.open filename,"wb" do |csv|

    old_csv = CSV.open '户外.csv'

    old_csv.each{|line|
      uid = line[0]
      hash[uid] = line
    }
    uids = open "hw-uid"
    uids = uids.read
    uids = uids.strip.split("\n")
    uids = uids.uniq

    uids.each do |uid|
      line = hash[uid]
      if !line.blank?
        csv << line
      end
    end
  end
 
 
  #主帐号分析
   
  def get
    uids = open "ycty-uid"
    uids = uids.read
    uids = uids.strip.split("\n")
    uids = uids.uniq
    puts uids.size
  end
