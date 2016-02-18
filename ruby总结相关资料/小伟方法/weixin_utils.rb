#匹配一个帐号是否在 一些帐号中（匹配）
filename = "匹配1.csv"
CSV.open filename,"wb" do |csv|
    csv << ['uid','是否发送消息'] 
    path = File.join(Rails.root,"db/openid1") 
    path1 = File.join(Rails.root,"db/openid") 
    keywords = []
    File.open(path,"r").each do|line|
      keywords << line.strip
    end
    File.open(path1,"r").each do|line|
      isinclude = keywords.include?(line.strip) ? '有' : '否'
      csv << [line,isinclude]
    end
end   

filename = "匹配.csv"
CSV.open filename,"wb" do |csv|
    csv << ['id','匹配信息'] 
    path0 = File.join(Rails.root,"db/name") 
    path = File.join(Rails.root,"db/openid") 
    path1 = File.join(Rails.root,"db/openid1") 
    keywords = []
    key = {}
    File.open(path0,"r").each do|line|
      keywords << line.strip.to_s #改变匹配字符串还是 数字
    end
    number = 0
    File.open(path,"r").each do|line|
      id = line.strip
      key[id] = keywords[number]
      number = number + 1
    end
    File.open(path1,"r").each do|line|
      openid = line.strip
      isinclude = (key.keys.include?(openid)) ? key[openid] : ''
      csv << [line,isinclude]
    end
end  




#接受页码反馈的数据 互动次数
require 'net/http'
require 'open-uri'
filename = "data/微信数据提取-8.csv"
path = File.join(Rails.root,"db/url8") 
  url = "http://intelweixin.buzzopt.com/index.php/wechat/getUserInfoByOpenId/openid/"
  #url =  "http://intelweixin.buzzopt.com/index.php/wechat/getUserInfoByOpenId/openid/"
  CSV.open filename,"wb" do |csv|
    csv << %w{subscribe openid nickname sex language city province country headimgurl subscribe_time}
    File.open(path,"r").each do|line|
        openid = line.strip
        puts openid
       
          urlp = url+openid.to_s
          host = urlp.match(".+\:\/\/([^\/]+)")[1]
          path = urlp.partition(host)[2] || "/"
        begin
          res = Net::HTTP.get host, path
          if res.nil? || res=="null"
            csv << [openid]
            next
          end
          keyword = JSON.parse(res)
          if keyword['errmsg'] == "invalid openid"
            csv << [openid]
            next
          end 
          subscribe_time = Time.at(keyword['subscribe_time'].to_i)
          csv <<  [keyword['subscribe'],keyword['openid'],keyword['nickname'],keyword['sex'],keyword['language'],keyword['city'],keyword['province'],keyword['country'],keyword['headimgurl'],subscribe_time]
        rescue Exception=>e
          csv << [openid]
          next
        end
    end
end


require 'net/http'
require 'open-uri'

def hopen(url)
  begin
    open(url)
  rescue URI::InvalidURIError
    host = url.match(".+\:\/\/([^\/]+)")[1]
    path = url.partition(host)[2] || "/"
    Net::HTTP.get host, path
  end
end

resp = hopen("http://dear_raed.blogspot.com/2009_01_01_archive.html")

 

