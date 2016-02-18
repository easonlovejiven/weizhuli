
#一下都是常用的接口 

用户：
（1）users.counts(uids)批量获取用户的粉丝数,微薄数,关注数
 #注意:此接口只有一个必选的参数所以不用写参数的名称
  task = GetUserTagsTask.new
  filename = "监控帐号.csv"
  CSV.open filename,"wb" do |csv|
    csv << %w{UID 粉丝数 关注数 微薄数}
    uids = open "jk-uid"
    uids = uids.read
    uids = uids.strip.split("\n")
    uids = uids.uniq
    uids.in_groups_of(100).each do |ids|
      begin
        #res = task.stable{task.api.users.counts (ids.compact*",")}
        res = task.stable{task.api.users.counts ids.compact*","}
        res.each{|r|
          csv << [r.id,r.followers_count,r.friends_count,r.statuses_count]
        } 
      rescue Exception=>e
        if e.message =~ /User does not exists!/
          csv << [r.id,"此用户已被屏蔽"]
        end
      end
    end
  end
  (2)users.show(udis/names) #接口获取用户的信息包括用户的微薄信息
  (3)
微博:
  (1)statuses.user_timeline(uid/name) #最多只返回每个用户的最新的前2000条微薄信息
  #此接口有原微薄及原用户信息，和互动的用户及微薄信息（转发，评论，互动时间，互动内容）
  (2)statuses.user_timeline.ids(uid/name) #默认每次返回20条最多返回100条参数uid和name必选其一
  task = GetUserTagsTask.new
  filename = "测试数据.csv"
  CSV.open filename,"wb" do |csv|
    uids = open "intel-uids"
    uids = uids.read
    uids = uids.strip.split("\n")
    uids = uids.uniq
    uids.each do |uid|
      
    end
  end
  (3)statuses.show(id:weibo_id)#提取从接口获取的连接内容
  task = GetUserTagsTask.new
  filename = "接口内容.csv"
  CSV.open filename,"wb" do |csv|
    csv << %w{URL 内容 转发数 评论数}
    urls = open "nana-urls"
    urls = urls.read
    urls = urls.strip.split("\n")
    urls = urls.uniq
    urls.each{|url|
      weibo_id = WeiboMidUtil.str_to_mid(url.split("/").last)
      res = task.stable{task.api.statuses.show(id:weibo_id)}
      csv << [url,res.text,res.reposts_count,res.comments_count]
    }
  end
粉丝：
