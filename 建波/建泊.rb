#给出1441个用户在近两周发布的微博的当中的关键词和话题的统计

  task = GetUserTagsTask.new
  filename = '测试用户发布的前200条微博.csv'#返回最新的微薄最多返回100条
  CSV.open filename,"wb" do |csv|
    csv << %w{UID URL 内容 话题}
    uids = open "uids"
    uids = uids.read
    uids = uids.strip.split("\n")
    uids = uids.uniq
    uids.each do |uid|
      begin
        res = task.stable{task.api.statuses.user_timeline(uid:uid,count:100)}
        res['statuses'].each{|w|
          url = "http://weibo.com/#{uid}/#{WeiboMidUtil.mid_to_str(w.id.to_s)}"
          content = w.text
           if content.include?("#")
            content=~/.*#(.*)#.*/ 
            topic = $1 #匹配话题
            csv << [uid,url,content,topic]         
          end
        }
      rescue Exception=>e
        puts e.message
        if e.message =~ /User does not exists!/
          csv << [uid,"此用户已被屏蔽"]
      end
    end
  end
end

  #承上的（话题统计）

  filename = "881三.csv"
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

  #关键词排行

  filename = "881关键词排行2.csv"
  CSV.open filename,"wb" do |csv|
    csv << %w{关键词 关键词数量}
    all_keywords = {}
    url = "http://www.tfengyun.com/user.php?action=keywords&userid="
    task = GetUserTagsTask.new
    uids = open "881-uid"
    uids = uids.read
    uids = uids.strip.split("\n")
    uids = uids.uniq
      uids.each_with_index do |uid,index|
        begin
          res = task.stable{Net::HTTP.get URI.parse(url+uid.to_s)}
          keywords = JSON.parse(res)
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
  
  #单个用户的标签统计(只能统计出有标签的用户) 批量获取

  filename = "用户标签统计批量用户匹配.csv"
  CSV.open filename,"wb" do |csv|
    csv << %w{UID 标签}
    task = GetUserTagsTask.new
    uids = open "1303-uids"
    uids = uids.read
    uids = uids.strip.split("\n")
    uids = uids.uniq
    uids.in_groups_of(20).each do |uid| #每次取出20个用户
      res = task.stable{task.api.tags.tags_batch uid.compact*","}
      res.each{|tag|
        tag_name = ""
        tags = tag.tags
        tags.each{|info|
          info.delete "weight"
          if !info.to_a.blank?
            tag_name += info.to_a.first[1] + ","
          end 
        }
        csv << [tag.id,tag_name[0,tag_name.length-1]]
      }
    end
  end
  
  #单个用户的标签统计(只能统计出有标签的用户) 每次取一个用户 #这块儿参数传的有问题
  
  filename = "用户标签统计单个用户匹配测试.csv"
  CSV.open filename,"wb" do |csv|
    csv << %w{UID 标签}
    task = GetUserTagsTask.new
    uids = open "ceshi-uid"
    uids = uids.read
    uids = uids.strip.split("\n")
    uids = uids.uniq
    uids.each do |uid|
      debugger
      res = task.stable{task.api.tags(uid)}
      debugger
    end
  end
  
  #建波取4000粉丝男女比例
  
  def get_num(sex)
    old_csv = CSV.open "建波-12-092000个粉丝信息.csv"
    num = 0
    old_csv.each{|line|
      if line[4] == sex
        num += 1
      end
    }
    puts num
  end
