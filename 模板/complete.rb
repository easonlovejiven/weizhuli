
#数据A:全部帖子列表  注意:一些参数最好放到代码的开头,代码的最主要因素是,其参数可以任意的传递
  
  name = "wuhan" #传不同的参数(主号的screen_name),去导出不同主号的信息
  folder = "#{name}-data" #这块儿是指不同帐号要放到不同的文件夹下,以避免不同的帐号时修改太多的变量
  Dir.mkdir folder if !Dir.exist? folder #判断文件夹是否存在,如果不存在就创建一个这样的文件夹
  @url = 'db/wuhan-url.rb'
  filename = "#{folder}/数据A全部帖子列表3.csv"
  path = File.join(Rails.root, @url)
  CSV.open filename,"wb" do |csv|
  csv << %w{名称 内容 发布时间 转发数 评论数 互动总数 URL 原创 发布来源}
    task = GetUserTagsTask.new
    File.open(path,"r").each do |url|
      if !url.blank?
        weibo_id = WeiboMidUtil.str_to_mid url.split("/").last #得到weibo_id
        res = task.stable{task.api.statuses.show(id:weibo_id)}
        content = res.text #微博的内容
        release_date = Time.parse(res.created_at) #微博的发布时间
        res.retweeted_status.nil? ? origin = 'Y' : origin = 'N' #是否是原创微博
        comments_num = res.comments_count #评论数
        reposts_num = res.reposts_count #转发数
        sum = comments_num + reposts_num #互动数
        source = ActionView::Base.full_sanitizer.sanitize(res.source) #来源
        #这块儿是转发微博的url并不是自己的
         if !res.retweeted_status.nil?  #转发的微博的url(并不是自己的微博)
            url1 = ''
            str1 = WeiboMidUtil.mid_to_str res.retweeted_status.idstr #B1W2pm2I7(得到路径后边儿的一段字符串)
            url1 = 'http://weibo.com/'+res.retweeted_status.user.idstr+'/'+str1 #"http://weibo.com/1782394737/B1W2pm2I7"
            debugger
            csv << [name,content,release_date,reposts_num,comments_num,sum,url1,origin,source]
         end
        #发布来源
        csv << [name,content,release_date,reposts_num,comments_num,sum,url,origin,source]
      end
    end
  end
  
#数据B1部分非活动贴互动人信息

  name = "wuhan" #传不同的参数(主号的screen_name),去导出不同主号的信息
  folder = "#{name}-data" #这块儿是指不同帐号要放到不同的文件夹下,以避免不同的帐号时修改太多的变量
  Dir.mkdir folder if !Dir.exist? folder #判断文件夹是否存在,如果不存在就创建一个这样的文件夹
  @url = "db/wuhan" #读取文件时可以直接传这个参数
  filename = "#{folder}数据B1部分非活动贴互动人信息3.csv"
    task = GetUserTagsTask.new
    CSV.open filename,"wb" do |csv|
      csv << ["url", "UID", "昵称", "位置", "性别", "粉丝", "关注", "微博", "注册时间", "认证信息", "认证原因", "主号互动数"]
      path = File.join(Rails.root,@url) #要注意这个默认路径
      File.open(path,"r").each do|line|
        url = line.strip
        weibo_id = WeiboMidUtil.str_to_mid url.split("/").last #得到微博id作为条件去导出转发人的信息
        page = 1
        processing = true
          begin
            begin
              res = task.stable{task.api.statuses.repost_timeline(weibo_id.to_s,count:200,page:page)}#根据weibo_id查转发人信息
                if !res.blank?
                   res.reposts.each do |line|
                     row = []
                    if line.nil?
                       processing = false
                       break
                    end
                    csv << [url,line.user.id,use.screen_name,use.location,gender,use.followers_count,use.friends_count,use.statuses_count,Time.parse(use.created_at),use.verified_type,use.verified_reason,line.reposts_count + line.comments_count]
                   end
                 else
                  processing = false
                 end
            rescue Exception=>e
              puts e.message
            end
            page+=1
          end while processing == true
          page = 1
          processing == true
          begin
            begin
              res = task.stable{task.api.comments.show(weibo_id,count:200,page:page)}#根据weibo_id查评论人信息
                if !res.comments.blank?
                   res.comments.each do |line|
                    row = []
                    if line.nil?
                       processing = false
                       break
                    end
                    csv << [url,line.user.id,use.screen_name,use.location,gender,use.followers_count,use.friends_count,use.statuses_count,Time.parse(use.created_at),use.verified_type,use.verified_reason,line.status.reposts_count + line.status.comments_count]
                   end
                 else
                  processing = false
                 end
             rescue Exception=>e
              puts e.message
             end
             page+=1
          end while processing == true
      end
  end

#数据B提取与全部帖子互动的UID列表(抽样500)
  
  
  
  

