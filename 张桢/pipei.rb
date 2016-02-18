  
    filename = "words2"
    CSV.open filename,"wb" do |csv|
      
      words3 = open "a"
      words3 = words3.read
      words3 = words3.strip.split("\n")
      words3 = words3.uniq
      
      words4 = open "b"
      words4 = words4.read
      words4 = words4.strip.split("\n")
      words4 = words4.uniq
      
      words3.each{|aaa|
        words4.each{|ccc|
          csv << [aaa+ccc]
        }
      }
    end
    
    filename = "intel"
    CSV.open filename,"wb" do |csv|
      uids = open "intel-uid"
      uids = uids.read
      uids = uids.strip.split("\n")
      uids = uids.uniq
      uids.each{|uid|
        csv << [uid]
      }
    end
    
  
  #最终结果 亲子游-亲子教育.csv
  
  filename = "匹配词3统计.csv"
  CSV.open filename,"wb" do |csv|
    csv << %w{关键词名称 数量统计}
    task = GetUserTagsTask.new
    keywords = open "匹配词3"
    keywords = keywords.read
    keywords = keywords.strip.split("\n")
    keywords.each do |keyword|
      url = "https://c.api.weibo.com/2/search/statuses/limited.json?"
      start_time = Time.parse("2013-07-01 00:00:00").to_i #转换成时间截
      end_time = Time.parse("2014-12-31 00:00:00").to_i
      pas={access_token:"2.005wKAMBDtpNADc71e3fbde2T8XNWB",q:keyword,starttime:start_time,endtime:end_time,count:50}
      res = task.stable{open (url+pas.to_query)}
      res = task.stable{Hashie::Mash.new JSON.parse(res.read)}
      csv << [keyword,res.total_number]
    end
  end
  
  #对数组当中的元素进行
  
  filename = '最终2.csv' 
  CSV.open filename,"wb" do |csv|
    status = {}
    csv << %w{关键词 数量}
    old_csv = CSV.open "张桢统计词2.csv"
    old_csv.each do |line|
      words = line[0]
      number = line[1].to_i
      status[words] = number
    end
     status.sort{|a,b| b[1]<=>a[1]}.each do |line|
        csv << line
     end 
  end
