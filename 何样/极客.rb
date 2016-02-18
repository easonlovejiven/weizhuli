
#取出这个帐号都前2000个粉丝

  #主号 uid UID 昵称 位置 性别 粉丝 关注 微博 注册时间 认证信息 认证原因 备注	 标签
  #跑出极客粉丝 (备注，标签，认证信息里边儿是否包含极客关键词的用户)
  name = "全球IT视角"
  filename = "#{name}极客粉丝"
  CSV.open filename,"wb" do |csv|
    keywords = open "keywords-jike"
    keywords = keywords.read
    keywords = keywords.strip.split("\n")
    keywords = keywords.uniq
    
    old_csv = CSV.open "全球IT视角测试前2000个粉丝信息.csv"
    
    old_csv.each do |line|
      if line[0] != "主号uid"
        if line[2] != nil
        uid = line[1] #用户
        infor = line[9] #认证信息
        beizhu = line[11] #备注
        tags = line[12] #标签
        if beizhu != nil && tags != nil 
          content = infor+beizhu+tags
          keywords.each do |word|
            if content.include?(word)
              csv << [uid]
            end
          end
          elsif beizhu == nil && tags != nil
            beizhu = "aaa"
            content = infor+beizhu+tags
            keywords.each do |word|
              if content.include?(word)
                csv << [uid]
              end
            end
            elsif beizhu != nil && tags == nil
              tags = "bbb"
              content = infor+beizhu+tags
              keywords.each do |word|
                if content.include?(word)
                  csv << [uid]
                end
              end
            end
        end
      end
    end
  end
  
  #不是极客粉丝的
  
  filename = "wu2"
  CSV.open filename,"wb" do |csv|
    csv << %w{UID}
    
      quan2 = open 'xph-y'
      quan2 = quan2.read
      quan2 = quan2.strip.split("\n")
      

      quan = open 'xph-yous'
      quan = quan.read
      quan = quan.strip.split("\n")
      
      quan.each do |uid|
        if !quan2.include?(uid)
          csv << [uid]
        end
      end
  end
  
  #共同关注
  
  keywords = {}
  task = GetUserTagsTask.new
  name = "全球IT视角"
  filename = "#{name}前100共同关注排行.csv"
  CSV.open filename,"wb" do |csv|
    csv << %w{UID 共同关注次数}
    uids = open "全球IT视角不是极客"
    uids = uids.read
    uids = uids.strip.split("\n")
    uids = uids.uniq
    uids.each{|uid|
      uid = uid.strip
      #返回uid关注的用户uids
      begin
        ids = task.api.friendships.friends_ids(uid:uid,count:5000).ids
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
  
  #极客粉丝去除重复的
  
  name = "全球IT视角"
  filename = "#{name}极客粉丝2"
  CSV.open filename,"wb" do |csv|
    uids = open "全球IT视角极客粉丝"
    uids = uids.read
    uids = uids.strip.split("\n")
    uids = uids.uniq
    uids.each do |uid|
      csv << [uid]
    end
  end 
  
  #2000粉丝关注38个帐号的数量统计
  
  task = GetUserTagsTask.new
  filename = "30W-count最终3.csv"
  CSV.open filename,"wb" do |csv|
    csv << %w{主号uid 关注uid}
    
    uids = open "all-uids"
    uids = uids.read
    uids = uids.strip.split("\n")
    
    uidss = open "38-uid"
    uidss = uidss.read
    uidss = uidss.strip.split("\n")
    
    uids.each{|uid|
      num = 0
      begin
          uid = uid.strip
          ids = task.api.friendships.friends_ids(uid:uid,count:5000).ids
          if !ids.blank?
            uidss.each do |suid|
              if ids.include?(suid.to_i)
                num += 1
              end  
            end
            elsif ids.nil?
              csv << [uid,'返回异常']
          end         
          csv << [uid,num]
        rescue Exception =>e
          if e.message =~ /out of limitation/
            csv << [uid,'获取异常']
            next
            elsif e.message =~ /User dose not exists!/
              csv << [uid,'此用户已被屏蔽']
        end
      end
    }
  end
