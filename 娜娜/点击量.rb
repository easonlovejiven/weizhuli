  
  filename = "微博互动信息(根据urls).csv"
  CSV.open filename,"wb" do |csv|
    url = open 'nana-urls'#文件的路径
    url = url.read
    url = url.strip.split("\n")
    url = url.uniq
    url.each do |url|
      weibo_id = WeiboMidUtil.str_to_mid(url.split("/").last) #得到这些url的weibo_id,注:要把weibo_id转换成整形的
      #得到微博对象
      mwc = MWeiboContent.find_by_id(weibo_id.to_i)
      if !mwc.nil?
        text = mwc.text #得到微博的内容
        csv << [url,text]
        else
          csv << [url,nil]
      end  
    end
  end
  
  filename = "互动uid"
  CSV.open filename,"wb" do |csv|
    uids = open "uid"
    uids = uids.read
    uids = uids.strip.split("\n")
    uids = uids.uniq
    uids.each{|uid|
      csv << [uid]
    }
  end
  
  #提取短连接
  filename = '短连接.csv'
  CSV.open filename,"wb" do |csv|
    old_csv = CSV.open 'hehe.csv'#(这个csv文件是没有对内容正负面影响进行统计的csv文件)
    old_csv.each do |line|
      content = line[0]
      num = content.index("http").to_i
      url = content[num,19]
      csv << [url]
    end
  end
  
  #点击量统计
  filename = "点击量统计.csv"
  CSV.open filename,"wb" do |csv|
    task = GetUserTagsTask.new
    csv << %w{URL 点击量}
    urls = open "dl"
    urls = urls.read
    urls = urls.strip.split("\n")
    urls.each do |url|
      url = url.strip
      
      res = task.stable{Net::HTTP.post_form(URI("http://weiboyi.com/apiController.php"),{shortUrl:url,type:"clickNum"})}
      result = task.stable{JSON.parse res.body}
      csv << [url,result["clicks"]]
    end
  end 
