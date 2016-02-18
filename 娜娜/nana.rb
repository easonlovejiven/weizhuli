  
  #取某个监控帐号的最新粉丝总数有问题
  
  filename = "最新粉丝.csv"
  CSV.open filename,"wb" do |csv|
    csv << %w{UID 昵称 粉丝数量}
    uids = open "uids"
    uids = uids.read
    uids = uids.strip.split("\n")
    uids.each do |uid|
      wasd = WeiboAccountSnapDaily.where("uid = ?",uid).order("date desc").limit(1)
      time = wasd[0].date.strftime("%Y-%m-%d %H:%M:%S")
      wa = WeiboAccountSnapDaily.where("uid = ? and date = ?",uid,time)
      mwa = MonitWeiboAccount.find_by_uid(uid)
      csv << [uid,mwa.screen_name,wa[0].followers_count]
    end
  end

  #取某个时间点监控帐号的粉丝情况

  filename = "总粉丝.csv"
  task = GetUserTagsTask.new
  CSV.open filename,"wb" do |csv|
    csv << %w{UID 昵称 总粉丝数}
    sum = 0
    uids = open "uids"
    uids = uids.read
    uids = uids.strip.split("\n")
    uids.each do |uid|
      sum = WeiboAccountSnapDaily.where("uid = ? and date = ?",uid,"2014-11-03")
      mwa = MonitWeiboAccount.find_by_uid(uid)
      if !sum.blank?
        csv << [uid,mwa.screen_name,sum[0].followers_count]
        elsif
          csv << [uid,mwa.screen_name,nil]
      end
    end
  end

  #每条微薄关键词统计
  
    require 'rseg'
    Rseg.load
    filename = "娜娜-层级.csv" #针对每条微博的关键词量
    #全局变量统计关键词数量 
      keywords = open "keywords"
      keywords = keywords.read
      keywords = keywords.strip.split("\n")
      words_stats = {}
      keywords.each{|word|
        word = word.strip
        words_stats[word] = 0
      }
    CSV.open filename,"wb" do |csv|
      csv << %w{URL 传播层级 BUZZ声量}
      urls = open "urls"
      urls = urls.read
      urls = urls.strip.split("\n")
      urls = urls.uniq 
      urls.each do |url|
        weibo_id = WeiboMidUtil.str_to_mid URI.parse(url.strip).path.split("/").last
        forwards = WeiboForward.where("weibo_id = ?",weibo_id)
        comments = WeiboComment.where("weibo_id = ?",weibo_id)
         # 转发
        if !forwards.blank?
          forwards.each do |forward|
            #得到一个用户信息对象
            forward_text = MForward.find_by_id(forward.forward_id)
            if !forward_text.blank?
              ftext = forward_text.text.strip
              @str = ""
              keywords.each{|w|
                @key = w.strip
                if ftext.include?(@key)
                  @str += @key
                  @str = @str += ","
                  words_stats[@key] += 1
                end
              }
            end
          end
        end
      
        # 评论
        if !comments.blank?
          comments.each do |comment|
            #得到一个用户信息对象
            comment_text = MComment.find_by_id(comment.comment_id)
            if !comment_text.blank?
              @str = ""
              ctext = comment_text.text.strip
              keywords.each{|w|
                @key = w.strip
                if ctext.include?(@key)
                  @str += @key
                  @str = @str += ","
                  words_stats[@key] += 1
                end
              }
            end
          end
        end
        
        num = words_stats.values.sum
        #每循环一个连接都要清空一下values
        keywords.each{|w|
          @key = w.strip
          words_stats[@key] = 0
        }
        
        #以上是BUZZ声量
        
        #以下是传播层级
        WeiboForward.analyze_tree(weibo_id)
          records = WeiboForwardRelation.find_by_sql <<-EOF
            select depth,count(*) as num from weibo_forward_relations where weibo_id = #{weibo_id} group by depth 
          EOF
          a = 0
          b = 0 
          records.each do |line|
            if line.depth != 0
              a = a + line.depth*line.num
              b = b + line.num
            end
          end
          if b != 0
            c = a.to_f/b.to_f
              csv << [url,c,num]
            elsif
              csv << [url,0,num]
          end
      end
    end
    
    #BUZZ声量
    require 'rseg'
    Rseg.load
    filename = "intel-buzz.csv" #针对每条微博的关键词量
    #全局变量统计关键词数量 
      keywords = open "keywords"
      keywords = keywords.read
      keywords = keywords.strip.split("\n")
      words_stats = {}
      keywords.each{|word|
        word = word.strip
        words_stats[word] = 0
      }
    CSV.open filename,"wb" do |csv|
      csv << %w{URL BUZZ声量}
      urls = open "intel-url"
      urls = urls.read
      urls = urls.strip.split("\n")
      urls = urls.uniq 
      urls.each do |url|
        weibo_id = WeiboMidUtil.str_to_mid URI.parse(url.strip).path.split("/").last
        forwards = WeiboForward.where("weibo_id = ?",weibo_id)
        comments = WeiboComment.where("weibo_id = ?",weibo_id)
         # 转发
        if !forwards.blank?
          forwards.each do |forward|
            #得到一个用户信息对象
            forward_text = MForward.find_by_id(forward.forward_id)
            if !forward_text.blank?
              ftext = forward_text.text.strip
              @str = ""
              keywords.each{|word|
                @key = word.strip
                if ftext.include?(@key)
                  @str += @key
                  @str = @str += ","
                  words_stats[@key] += 1
                end
              }
            end
          end
        end
      
        # 评论
        if !comments.blank?
          comments.each do |comment|
            #得到一个用户信息对象
            comment_text = MComment.find_by_id(comment.comment_id)
            if !comment_text.blank?
              @str = ""
              ctext = comment_text.text.strip
              keywords.each{|word|
                @key = word.strip
                if ctext.include?(@key)
                  @str += @key
                  @str = @str += ","
                  words_stats[@key] += 1
                end
              }
            end
          end
        end
        
        num = words_stats.values.sum
        #每循环一个连接都要清空一下values
        keywords.each{|w|
          @key = w.strip
          words_stats[@key] = 0
        }
        csv << [url,num]
      end
    end
    
  #@数
  filename = "xph@数.csv"
  CSV.open filename,"wb" do |csv|
    csv << %w{内容}
    old_csv = CSV.open "xph.csv"
    old_csv.each do |line|
      content = line[0]
      if content.include?("@英特尔芯品汇")
        csv << line
      end
    end
  end
  
  #娜娜整套模板
  
  #每条微博的平均传播层数

    filename = "测试层级.csv"
    CSV.open filename,"wb" do |csv|
      csv << %w{URL 平均数量}
      #urls = open 'urla'
      #urls = urls.read
      #urls = urls.strip.split("\n")
        #先更新每条微薄
        url = "http://weibo.com/2011912170/C3X9qkv6N"
        weibo_id = WeiboMidUtil.str_to_mid URI.parse(url.strip).path.split("/").last
        WeiboForward.analyze_tree(weibo_id)
        records = WeiboForwardRelation.find_by_sql <<-EOF
          select depth,count(*) as num from weibo_forward_relations where weibo_id = #{weibo_id} group by depth 
        EOF
        numA = 0
        numB = 0
        result = 0
        records.each do |line|
          if line.depth != 0
            numA = numA + line.depth*line.num
            numB = numB + line.num
          end
        end
        if numB != 0
          result = numA.to_f/numB.to_f
            #保留两位小数
            csv << [url,result]
          elsif
            csv << [url,1]
        end
      #end
    end
    
    #更新连接
    
    def asdf
      urls = open 'urls'
      urls = urls.read
      urls = urls.strip.split("\n")
      urls.each do |url|
        weibo_id = WeiboMidUtil.str_to_mid URI.parse(url.strip).path.split("/").last
        WeiboForward.analyze_tree(weibo_id)
      end
    end

  #每条微博的有效性占比

  require 'rseg'
  Rseg.load

  filename = "xph互动内容的有效性统计-有效占比.csv"
  CSV.open filename,"wb" do |csv|
  csv << %w{URL 发布时间 互动内容 有效性占比 动作}
  urls = open "/home/rails/Desktop/xph-urls-yxzb"
  urls = urls.read
  urls = urls.strip.split("\n")
  urls.each do |url|
  page = 1
  while true
    comments = WeiboComment.where("uid = ? and comment_at between ? and ?",2637370247,start_time,end_time).paginate(per_page:1000, page:page)
    break if comments.blank?
    comments.each do |comment|
      #微博连接
      url = "http://weibo.com/"+2637370247.to_s+"/"+WeiboMidUtil.mid_to_str(comment.weibo_id.to_s)
      #微博发布时间
      comment_date = comment.comment_at.strftime("%Y-%m-%d %H:%S")  
      mc = MComment.find(comment.comment_id)
      if !mc.blank? #如果不等于空的话(这块儿做了个非空的判断)
        content = mc.text #内容
        #情感分析
        result = content != "转发微博" && !content.gsub(/\[[^\]]+\]/,"").blank?
        csv << [url,comment_date,content,result,'评论']
      end
     end
    page+=1
   end
    page = 1
   while true
    forwards = WeiboForward.where("uid = ? and forward_at between ? and ?",2637370247,start_time,end_time).paginate(per_page:1000, page:page)
    break if forwards.blank?
    forwards.each do |forward|
      #微博连接
      url = "http://weibo.com/"+2637370247.to_s+"/"+WeiboMidUtil.mid_to_str(forward.weibo_id.to_s)
      #微博发布时间
      forward_date = forward.forward_at.strftime("%Y-%m-%d %H:%S")
      fc = MForward.find(forward.forward_id)
      if !fc.blank? #如果不等于空的话(这块儿做了个非空的判断)
        content = fc.text
        #情感分析
        result = content != "转发微博" && !content.gsub(/\[[^\]]+\]/,"").blank?
        csv << [url,forward_date,content,result,'转发']
      end
     end
    page+=1
    end
   end
  end

  
  #BUZZ问题
  
  require 'rseg'
  Rseg.load
  filename = "heyang-BUZZ.csv" #针对每条微博的关键词量
  #全局变量统计关键词数量
    keywords = open 'keywords-buzz'#文件的路径
    keywords = keywords.read
    keywords = keywords.strip.split("\n")
    words_stats = {}
    keywords.each{|word|
      word = word.strip
      words_stats[word] = 0
    }
  CSV.open filename,"wb" do |csv|
    csv << %w{URL BUZZ声量}
    urls = open "heyang-url"
    urls = urls.read
    urls = urls.strip.split("\n")
    urls = urls.uniq 
    urls.each do |url|
      weibo_id = WeiboMidUtil.str_to_mid URI.parse(url.strip).path.split("/").last
      forwards = WeiboForward.where("weibo_id = ?",weibo_id)
      comments = WeiboComment.where("weibo_id = ?",weibo_id)
       # 转发
      if !forwards.blank?
        forwards.each do |forward|
          #得到一个用户信息对象
          forward_text = MForward.find_by_id(forward.forward_id)
          if !forward_text.blank?
            ftext = forward_text.text.strip
            @str = ""
            keywords.each{|w|
              @key = w.strip
              if ftext.include?(@key)
                @str += @key
                @str = @str += ","
                words_stats[@key] += 1
              end
            }
          end
        end
      end
    
      # 评论
      if !comments.blank?
        comments.each do |comment|
          #得到一个用户信息对象
          comment_text = MComment.find_by_id(comment.comment_id)
          if !comment_text.blank?
            @str = ""
            ctext = comment_text.text.strip
            keywords.each{|w|
              @key = w.strip
              if ctext.include?(@key)
                @str += @key
                @str = @str += ","
                words_stats[@key] += 1
              end
            }
          end
        end
      end
      
      #num = words_stats.values.sum
      #每循环一个连接都要清空一下values
      csv << [url,words_stats]
    end
  end
  
  filename = "娜娜-AA.csv"
  CSV.open filename,"wb" do |csv|
    require 'rseg'
    Rseg.load
    #全局变量统计关键词数量
      keywords = ['加多宝','JDB','凉茶']#文件的路径
      words_stats = {}
      keywords.each{|word|
        word = word.strip
        words_stats[word] = 0
      }
      csv << %w{URL 传播层级 BUZZ声量}
      urls = open "urla2"
      urls = urls.read
      urls = urls.strip.split("\n")
      urls = urls.uniq
      urls.each do |url|
        weibo_id = WeiboMidUtil.str_to_mid URI.parse(url.strip).path.split("/").last
        forwards = WeiboForward.where("weibo_id = ?",weibo_id)
        comments = WeiboComment.where("weibo_id = ?",weibo_id)
         # 转发
        if !forwards.blank?
          forwards.each do |forward|
          #得到一个用户信息对象
          forward_text = MForward.find_by_id(forward.forward_id)
          if !forward_text.blank?
            ftext = forward_text.text.strip
            @str = ""
            keywords.each{|w|
              @key = w.strip
              if ftext.include?(@key)
                @str += @key
                @str = @str += ","
                words_stats[@key] += 1
              end
            }
          end
        end
      end
    
      # 评论
      if !comments.blank?
        comments.each do |comment|
          #得到一个用户信息对象
          comment_text = MComment.find_by_id(comment.comment_id)
          if !comment_text.blank?
            @str = ""
            ctext = comment_text.text.strip
            keywords.each{|w|
              @key = w.strip
              if ctext.include?(@key)
                @str += @key
                @str = @str += ","
                words_stats[@key] += 1
              end
            }
          end
        end
      end
      num = words_stats.values.sum
      #每循环一个连接都要清空一下values
      keywords.each{|w|
        @key = w.strip
        words_stats[@key] = 0
      }
      
      #以上是BUZZ声量
      
      #以下是传播层级
      WeiboForward.analyze_tree(weibo_id)
        records = WeiboForwardRelation.find_by_sql <<-EOF
          select depth,count(*) as num from weibo_forward_relations where weibo_id = #{weibo_id} group by depth 
        EOF
        a = 0
        b = 0
        records.each do |line|
          if line.depth != 0
            a = a + line.depth*line.num
            b = b + line.num
          end
        end
        if b != 0
          c = a.to_f/b.to_f
            csv << [url,c,num]
          elsif
            csv << [url,1,num]
        end
    end
  end
  
  #微薄24小时发布趋势
  
  filename = "时间-趋势.csv"
  CSV.open filename,"wb" do |csv|
    csv << %w{Time 发布数量}
    old_csv = CSV.open "time.csv"
    old_csv.each{|line|
      time = line[0]
      time = time[9,2]
      csv << [time]
    }
  end
  
  #6条微薄的互动趋势
  filename = "时间趋势列表.csv"
  CSV.open filename,"wb" do |csv|
    csv << %w{Time 转发 评论 互动数}
    old_csv = CSV.open "新增粉丝列表-fans.csv"
    old_csv.each{|line|
      time = line[1]
      time = time[0,13]
      csv << [time]
    }
  end
  
  #6条微薄的互动趋势
  filename = "time-new.csv"
  CSV.open filename,"wb" do |csv|
    urls = open 'time'
    urls = urls.read
    urls = urls.strip.split("\n")
    urls.each{|time|
      time = time[0,16]
      csv << [time]
    }
  end
  
  #娜娜趋势统计
  filename = "转发贴-趋势.csv"
  CSV.open filename,"wb" do |csv|
    csv << %w{时间 转发 评论 互动}
    status = {}
    old_csv = CSV.open "转发贴.csv"
    #存放评论的时间
    old_csv.each{|line|
      if line[0] != "时间"
        status[line[0]] = line[1]
      end
    }
    #存放转发的时间
    old_csv.each{|line|
      if line[2] != "时间"
        if status[line[2]].blank?
            status[line[2]] = line[3]
          end
            status[line[2]] += line[3]
      end
    }
    status.sort{|a,b| b[1]<=>a[1]}.each do |line|
        csv << line
     end
  end
  
  #找到一条微薄的原微薄uid
  filename = "gw-uid.csv"
  CSV.open filename,"wb" do |csv|
    task = GetUserTagsTask.new
    csv << %w{URL uid}
    urls = open "gw-url"
    urls = urls.read
    urls = urls.strip.split("\n")
    urls.each do |url|
      weibo_id = WeiboMidUtil.str_to_mid URI.parse(url.strip).path.split("/").last
      res = task.stable{task.api.statuses.repost_timeline(id:weibo_id)}
      debugger
    end
  end
