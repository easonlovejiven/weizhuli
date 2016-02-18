    filename = "881话题排行.csv"
    CSV.open filename,"wb" do |csv|
      status = {}
      csv << %w{相关话题 数量}
      num = 0
      topics = open 'topic'
      topics = topics.read
      topics = topics.strip.split("\n")
        topics.each do |topic|
          status[topic] = 0
        end
        topics.each do |topic|
          next if topic.nil? 
            if status[topic].blank?
              status[topic] = 0 
            end
              status[topic] += 1
        end
       status.sort{|a,b| b[1]<=>a[1]}.each do |line|
          csv << line
        end 
    end
    
  task = GetUserTagsTask.new
  filename = '话题排行测试.csv'#返回最新的微薄最多返回100条
  CSV.open filename,"wb" do |csv|
    csv << %w{话题 数量}
    uids = open "2000-uid"
    uids = uids.read
    uids = uids.strip.split("\n")
    uids = uids.uniq
    topics = []
    status = {}
    uids.each do |uid|
      begin
        res = task.stable{task.api.statuses.user_timeline(uid:uid,count:100)}
        res['statuses'].each{|w|
          #url = "http://weibo.com/#{uid}/#{WeiboMidUtil.mid_to_str(w.id.to_s)}"
          content = w.text
           if content.include?("#")
            content=~/.*#(.*)#.*/ 
            topic = $1 #匹配话题
            topics << topic         
          end
        }
        rescue Exception=>e
          puts e.message
          if e.message =~ /User does not exists!/
            csv << [uid,"此用户已被屏蔽"]
        end
      end
    end
  
    #给hash赋值
    topics.each do |topic|
      status[topic] = 0
    end
    
    #统计
    topics.each do |topic|
      next if topic.nil? 
        if status[topic].blank?
          status[topic] = 0 
        end
          status[topic] += 1
    end
    #打印排序
     status.sort{|a,b| b[1]<=>a[1]}.each do |line|
        csv << line
    end
  end
