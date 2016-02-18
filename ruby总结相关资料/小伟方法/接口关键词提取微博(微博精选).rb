接口说明：http://open.weibo.com/wiki/C/2/search/statuses/limited
module WeiboOAuth2
module Strategy
class UserPassword < OAuth2::Strategy::Password
def get_token(username,password, params={}, opts={})
params = {'grant_type' => 'password',
'username' => username,
'password'=> password}.merge(client_params).merge(params)
@client.get_and_restore_token(params, opts)
end
end
end
end

module WeiboOAuth2
class Client2 < Client
def auth_password
@auth_code ||= WeiboOAuth2::Strategy::UserPassword.new(self)
end
end
end


# 高级搜索接口
key = "2751696217"
secret = "3dbddd005fc1af2600f795806cc372bc"
WeiboOAuth2::Config.api_key = key
WeiboOAuth2::Config.api_secret = secret


@client = WeiboOAuth2::Client.new
u = "a11139606@sina.cn"
p = "m11134558"
t = @client.auth_password.get_token(u,p)


#chinajoy    CJ 动漫、cosplay  pas = {access_token:token,q:q,starttime:((Time.now-2.day).to_i),endtime:((Time.now-2.day+1.hour).to_i)}
filename = "cosplay.csv"
CSV.open filename,"wb" do|csv|
csv << %w{微博url 发布时间 内容 来源  发布人uid 发布人名 转发数 评论数}
  #i = 1
  #while i <=5 do
    begin
=begin   
        provinces = [11, 12, 13, 14, 15, 21, 22, 23, 31, 32, 33, 34, 35, 36, 37, 41, 42, 43, 44, 45, 46, 50, 51, 52, 53, 54, 61, 62, 63, 64, 65, 71, 81, 82, 100]
        res = Net::HTTP.get URI.parse("http://api.t.sina.com.cn/provinces.json") #获得地域
        j = 0
        while j < 35  do
          provinces << JSON.parse(res)['provinces'][j]['id']
          j +=1
        end
=end        
        q = "cosplay"
        url = "https://c.api.weibo.com/2/search/statuses/limited.json?"
        q =CGI.escape(q)
        count =50
        provinces.each do|province|
          processing = true
          page = 1
          while (processing == true) do
            pas={access_token:"2.00IQlCdDDtpNADc62fff93abNiAU9B",q:q,province:province,page:page,count:count}
            
            res = open (url+pas.to_query)
             
            res = Hashie::Mash.new JSON.parse(res.read)
             
            if res.statuses.blank?
              processing = false
              next
            end
            if !res.statuses.blank?
              res.statuses.each do|status|
                 puts  status.ids
                 puts  4
                
                source=ActionView::Base.full_sanitizer.sanitize(status.source)
                url1 = "http://weibo.com/#{status.user.id.to_s}/#{WeiboMidUtil.mid_to_str(status.idstr)}"
                created_at = Time.parse(status.created_at)
                csv << [url1,created_at,status.text,source,status.user.id,status.user.screen_name,status.reposts_count,status.comments_count]              
              end
            end
            page +=1
          end
          
        end
    rescue Exception=>e
      puts e.message
      csv << [e.message]
      next
     # i += 1
    end
  #end
end




#2. 根据单个关键词提取 
keywords = %w{动画 动漫爱好者 程序员}

keywords = %w{固态硬盘 SSD 硬盘速度 数据安全
 硬盘安全 硬盘故障 硬盘坏道}
 
 keywords = %w{工作站 动画制作 3D渲染 梦工厂 3D动画}
  #chinajoy    CJ 动漫、cosplay  pas = {access_token:token,q:q,starttime:((Time.now-2.day).to_i),endtime:((Time.now-2.day+1.hour).to_i)}
keywords = %w{
喜欢吃虾
爱吃虾
}
filename = "平板.csv"
uids =[]
task = GetUserTagsTask.new
CSV.open filename,"wb" do|csv|
csv << WeiboAccount.to_row_title(:default)+%w{keyword 微博url 发布时间 内容 来源   转发数 评论数}
     begin
       keywords.each do|keyword|
        q = keyword
        url = "https://c.api.weibo.com/2/search/statuses/limited.json?"
        number = 0
          endtime = (Time.now).to_i
          processing = true
          while (processing == true) do
            pas={access_token:"2.00IQlCdDDtpNADc62fff93abNiAU9B",q:q,endtime:endtime,count:50}
            res = task.stable{open (url+pas.to_query)}
            res = task.stable{Hashie::Mash.new JSON.parse(res.read)}
            puts "total_number:#{res.total_number}"
            
            if !res.statuses.blank?
              endtime = Time.parse(res.statuses.last.created_at).to_i-2
              res.statuses.each do|status|
                number +=1
                puts "number:#{number}"
                source=ActionView::Base.full_sanitizer.sanitize(status.source)
                url1 = "http://weibo.com/#{status.user.id.to_s}/#{WeiboMidUtil.mid_to_str(status.idstr)}"
                created_at = Time.parse(status.created_at)
                use = status.user
                next if uids.include?(use.id)
                next if (use.followers_count < 20) | (use.followers_count > 200000)
                next if use.statuses_count < 100
                uids << use.id
                genders = {'m'=>"男",'f'=>"女"}
                gender = genders[use.gender]
                verified_type = WeiboAccount.human_verified_type(use.verified_type)*','
                csv << [use.id,use.screen_name,use.location,gender,use.followers_count,use.friends_count,use.statuses_count,Time.parse(use.created_at),verified_type,use.verified_reason]+[keyword,url1,created_at,status.text,source,status.reposts_count,status.comments_count]              
                if  number > 100000
                  processing = false
                  break
                end
              end
            end
            if res.statuses.blank? || res.total_number.nil? || res.total_number < 45 
               puts '结果为空'
               processing = false
            end
            
          end
        end
      rescue Exception=>e
       puts e.message
      end
      uids.size
end



#3.限定时间 提取
filename = "动画.csv"
date = 1000.day
uids = []
task = GetUserTagsTask.new
CSV.open filename,"wb" do|csv|
csv << WeiboAccount.to_row_title(:default)+%w{keyword 微博url 发布时间 内容 来源  转发数 评论数}
     begin
      keywords.each do|keyword|
        puts keyword
        q = keyword
        url = "https://c.api.weibo.com/2/search/statuses/limited.json?"
        number = 0
          endtime = (Time.now).to_i
          processing = true
          while (processing == true) do
            pas={access_token:"2.00IQlCdDDtpNADc62fff93abNiAU9B",q:q,endtime:endtime,count:50}
            res = task.stable{open (url+pas.to_query)}
            res = task.stable{Hashie::Mash.new JSON.parse(res.read)}
            puts "endtime:#{endtime}"
            puts "total_number:#{res.total_number}"
            if !res.statuses.blank?
              endtime = Time.parse(res.statuses.last.created_at).to_i - 2
              puts 'h'+ endtime.to_s
              res.statuses.each do|status|
                if  (Time.parse(status.created_at).to_i < (Time.now - date).to_i)
                  processing = false
                  next
                end
                number +=1
                puts number
                puts "number:#{number}"
                source=ActionView::Base.full_sanitizer.sanitize(status.source)
                url1 = "http://weibo.com/#{status.user.id.to_s}/#{WeiboMidUtil.mid_to_str(status.idstr)}"
                created_at = Time.parse(status.created_at)
                
                use = status.user
                next if uids.include?(use.id)
                next if (use.followers_count.to_i < 20) | (use.followers_count.to_i > 200000)
                next if use.statuses_count.to_i < 100
                uids << use.id
                genders = {'m'=>"男",'f'=>"女"}
                gender = genders[use.gender]
                verified_type = WeiboAccount.human_verified_type(use.verified_type)*','
                csv << [use.id,use.screen_name,use.location,gender,use.followers_count,use.friends_count,use.statuses_count,Time.parse(use.created_at),verified_type,use.verified_reason] + [keyword, url1,created_at,status.text,source,status.reposts_count,status.comments_count]              
              end
            end
             
            if res.statuses.blank? || res.total_number<50 
               puts '结果为空'
               processing = false
            end
          end
        end
      rescue Exception=>e
       puts e.message
      end
      uids.size
end





def test(q,count)
          endtime = (Time.now).to_i
          url = "https://c.api.weibo.com/2/search/statuses/limited.json?"
          1.upto(count){
            pas={access_token:"2.00IQlCdDDtpNADc62fff93abNiAU9B",q:q,endtime:endtime,count:50}
            res = open (url+pas.to_query)
            res = Hashie::Mash.new JSON.parse(res.read)
            pp res.statuses.map(&:created_at)          
            
            endtime = Time.parse(res.statuses.last.created_at).to_i
          }

          nil
end



######
  q = "cosplay"
       url = "https://c.api.weibo.com/2/search/statuses/limited.json?"
       q =CGI.escape(q)
       pas={access_token:"2.00IQlCdDDtpNADc62fff93abNiAU9B",q:q,endtime:(Time.now).to_i}
       res = open (url+pas.to_query)
       res = Hashie::Mash.new JSON.parse(res.read)
        total_number=1018464
        res.total_number
WeiboToken.select_weibo_interface
例如：
pas={access_token:"2.00IQlCdDDtpNADc62fff93abNiAU9a",q:q}
pas[:count] = params[]
pas.to_query   // hash 值 字符串打印出来

