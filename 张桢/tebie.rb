

  #去除重复的用户
  
  filename "中国数量.csv"
  CSV.open filename,"wb" dp |csv|
    csv << %w{UID}
    uids = open "intel-uid"
    uids = uids.read
    uids = uids.strip.split("\n")
    uids = uids.uniq
    uids.each do |uid|
      csv << [uid]
    end
  end

  #两个帐号匹配信息

  name = "芯品汇终极活跃度"
  filename = "#{name}.csv"
  CSV.open filename,"wb" do |csv|
    old_csv = CSV.open "xph7W-天数最新1.csv"
    csv << %w{UID 昵称	 位置 	性别	 粉丝	 关注	 微博 	注册时间 	认证信息	 认证原因	 备注 	标签 自身活跃度 极客标签 游戏标签 动漫标签 美剧标签 体育标签 关注极客 关注游戏 关注动漫 关注影视 关注体育}
    jike_tags = get_jike_tags #极客标签
    game_tags = get_game_tags #游戏标签
    anime_tags = get_anime_tags #动漫标签
    meiju_tags = get_meiju_tags #美剧标签
    play_tags = get_play_tags #体育标签
    
    old_csv.each do |line|
      
      user_uid = line[0] #用户uid      
      note = line[10] #备注
      type = line[8] #认证类型
      user_tags = line[11] #用户标签
      
      jike = tags_think(jike_tags,note,type,user_tags) #极客标签
      game = tags_think(game_tags,note,type,user_tags) #游戏标签
      anime = tags_think(anime_tags,note,type,user_tags) #动漫标签
      meiju = tags_think(meiju_tags,note,type,user_tags) #美剧标签
      play = tags_think(play_tags,note,type,user_tags) #体育标签
      
      csv << [line[0],line[1],line[2],line[3],line[4],line[5],line[6],line[7],line[8],line[9],line[10],line[11],line[16],jike,game,anime,meiju,play]
      
    end
  end
  


  
  
  def get_jike_tags
    uids = open "intel-uid"
    uids = uids.read
    uids = uids.strip.split("\n")
    uids = uids.uniq
    puts uids.size
  end
    
  #user = task.stable{task.api.users.show(screen_name:"可口可乐")}

  name = "筛选"
  filename = "#{name}ITDM"
  CSV.open filename,"wb" do |csv|
  
    keywords = open "think-keywords"
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
  
  
  name = "筛选"
  filename = "#{name}ITDM"
  CSV.open filename,"wb" do |csv|
  
    keywords = open "think-keywords"
    keywords = keywords.read
    keywords = keywords.strip.split("\n")
    keywords = keywords.uniq
    
    old_csv = CSV.open "商用频道粉丝信息.csv"
    
    old_csv.each do |line|
      if line[0] != "UID"
        if line[2] != nil
        #认证原因 、简介、标签
        uid = line[0] #用户
        why = line[9] #认证信息
        beizhu = line[10] #备注
        tags = line[11] #标签
        if beizhu != nil && why != nil && tags != nil#111
          content = why+beizhu+tags
          keywords.each do |word|
            if content.include?(word)
              csv << [uid]
            end
          end
          elsif why == nil && beizhu != nil && tags != nil#011
            why = "aaa"
            content = why+beizhu+tags
            keywords.each do |word|
              if content.include?(word)
                csv << [uid]
              end
            end
            elsif why == nil && beizhu == nil && tags != nil#001
              why = "aaa"
              beizhu = "bbb"
              content = why+beizhu+tags
              keywords.each do |word|
                if content.include?(word)
                  csv << [uid]
                end
              end
            end
            elsif why == nil && beizhu == nil && tags == nil#000
              why = "aaa"
              beizhu = "bbb"
              tags = "ccc"
              content = why+beizhu+tags
              keywords.each do |word|
                if content.include?(word)
                  csv << [uid]
                end
              end
              elsif why =! nil && beizhu != nil && tags == nil#110
                tags = "ccc"
                content = why+beizhu+tags
                keywords.each do |word|
                  if content.include?(word)
                    csv << [uid]
                  end
                end
                elsif why =! nil && beizhu == nil && tags != nil#101
                  beizhu = "ccc"
                  content = why+beizhu+tags
                  keywords.each do |word|
                    if content.include?(word)
                      csv << [uid]
                    end
                  end
              elsif why == nil && beizhu != nil && tags == nil#101
                why = "ccc"
                tags = "bbb"
                content = why+beizhu+tags
                keywords.each do |word|
                  if content.include?(word)
                    csv << [uid]
                  end
                end
              end
            end
          end
  
  
  #代码优化
  
  name = "测试文件1.csv"
  filename = "#{name}极客粉丝"
  CSV.open filename,"wb" do |csv|
  
    keywords = open "jike-keywords"
    keywords = keywords.read
    keywords = keywords.strip.split("\n")
    keywords = keywords.uniq
    
    #如果满足了前边的条件就不执行后边的代码了
    old_csv = CSV.open "测试-12-092000个粉丝信息.csv"
    
    old_csv.each do |line|
        if line[2] != nil
        uid = line[1] #用户
        infor = line[9] #认证信息
        beizhu = line[11] #备注
        tags = line[12] #标签
        if beizhu != nil && tags != nil 
          elsif beizhu == nil && tags != nil
            beizhu = "aaa"
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
  
  task = GetUserTagsTask.new
  filename = "ceshi.csv"
  CSV.open filename,"wb" do |csv|
    csv << %w{主号uid 关注uid}
    
    uids = open "ceshi"
    uids = uids.read
    uids = uids.strip.split("\n")
    
    type_idss = open "game-uids"
    type_idss = type_idss.read
    type_idss = type_idss.strip.split("\n")
    
    uids.each{|uid|
      num = 0
      begin
          uid = uid.strip
          ids = task.api.friendships.friends_ids(uid:uid,count:5000).ids
          if !ids.blank?
            type_idss.each do |tuid|
              if ids.include?(tuid.to_i)
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
  
  
  #标签判断封装（这快儿代码是需要优化的）
  
  def tags_think(tags,note,type,user_tags)
    tag_status = "N"
    if note != nil && user_tags != nil && type != nil
      elsif note == nil && user_tags != nil
        note = "aaa"
        elsif note != nil && user_tags == nil
          user_tags = "bbb"
          content = type+note+user_tags
          tags.each do |tag|
            if content.include?(tag)
              tag_status = "Y"
            end
          end
        end
    return tag_status
  end
  
  #读取文件封装用户类型统计
  def  users_think(uids,user_uid)
    task = GetUserTagsTask.new
      num = 0
      begin
          user_uid = user_uid.strip
          ids = task.api.friendships.friends_ids(uid:user_uid,count:5000).ids
          if !ids.blank?
            uids.each do |uid|
              if ids.include?(uid.to_i)
                num += 1
              end  
            end
            elsif ids.nil?
             return 0
          end         
          return num
        rescue Exception =>e
          if e.message =~ /out of limitation/
            return 0
            elsif e.message =~ /User dose not exists!/
            return 0
        end
      end
  end
  
    def get_num(user_uid)
      jikes = open "jike-uids"
      jikes = jikes.read
      jikes = jikes.strip.split("\n")
      jikes = jikes.uniq
      task = GetUserTagsTask.new
        num = 0
        begin
            ids = task.api.friendships.friends_ids(uid:user_uid,count:5000).ids
            if !ids.blank?
              jikes.each do |uid|
                if ids.include?(uid.to_i)
                  num += 1
                end  
              end
              elsif ids.nil?
               return 0
            end         
            return num
          rescue Exception =>e
            if e.message =~ /out of limitation/
              return 0
              elsif e.message =~ /User dose not exists!/
              return 0
          end
        end
    
    filename = "三个交集用户.csv"
    CSV.open filename,"wb" do |csv|
    
      jius = open "jike-jiu-uid"    
      jius = jius.read
      jius = jius.strip.split("\n")
      jius = jius.uniq
    
      shis = open "jike-shi-uid"
      shis = shis.read
      shis = shis.strip.split("\n")
      shis = shis.uniq
      
      sys = open "jike-sy-uid"
      sys = sys.read
      sys = sys.strip.split("\n")
      sys = sys.uniq
      
      jius.each{|juid|
        shis.each{|suid|
          sys.each{|syuid|
            if juid == suid && juid == syuid && suid == syuid
              csv << [juid]
            end
          }
        }          
      }      
    end
    
  #计算一个用户的列表
  
  def user_test(uid,follows,groups)
    row = []
    groups.each{|group|
      m = 0
      follows.each{|id|
        group.each{|id2|
          if id == id2
            m += 1
          end
        }
      }
      row << m
    }
   row
  end  
  
