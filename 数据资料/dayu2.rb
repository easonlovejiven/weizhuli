    name = "英特尔中国"
    target_uid = ReportUtils.names_to_uids([name],true)[0]
    folder = "data/#{name}"
    Dir.mkdir folder if !Dir.exist? folder

    #1,微博列表
    weibo_list_file = "#{folder}/微博列表-#{name}.csv"
    ReportUtils.export_weibo_list([target_uid],weibo_list_file,Time.new(2015,03,30),Time.new(2015,04,06))#从接口提取这个人的微博列表 
    #2,数据B：提取与全部帖子互动的UID列表（包含以下维度：昵称、性别、地域、认证类型、关注数、粉丝数、微博数、单条微博平均互动量、开通微博时间）
    #接口提取 api 通过url 查出互动人信息列表(大文)

    #取出微薄列表当中的连接跑出互动人
    urls = [] # init urls
    CSV.open(weibo_list_file).each{|line|
      if line[6] != "URL"
        urls << line[6]
      end
    }
    
    
    
    #3,取出微薄列表当中的连接跑出互动人
    filename = "#{folder}/互动人信息列表-#{name}.csv"
    task = GetUserTagsTask.new
    @compare_uids = {}
    CSV.open filename,"wb" do |csv|
      csv << ['url']+WeiboAccount.to_row_title(:default) +['主号互动次数']
      urls.each do|url|
        puts url
        next if url.nil?
        weibo_id = WeiboMidUtil.str_to_mid url.split("/").last# http://weibo.com/2637370927/AjBZqpI56
        puts url
        page = 1
        genders = {'m'=>"男",'f'=>"女"}
        processing = true
          begin
            begin
              res = task.stable{task.api.statuses.repost_timeline(weibo_id.to_s,count:200,page:page)}#根据weibo_id查转发人信息count
                if !res.reposts.blank?
                   res.reposts.each do |line|
                     row = []
                    if line.blank?
                       processing = false
                       break
                    end
                    use = line.user
                    gender = genders[use.gender]
                    verified_type = WeiboAccount.human_verified_type(use.verified_type)*','
                    @compare_uids[use.id.to_s] ||= [1,{'url'=>url,'uid' =>use.id,'screen_name' =>use.screen_name,'location' =>use.location,'gender'=>gender,'followers_count'=>use.followers_count,'friends_count'=>use.friends_count,'statuses_count'=>use.statuses_count,'created_at'=>Time.parse(use.created_at),'verified_type'=>verified_type,'verified_reason'=>use.verified_reason}]
                   !@compare_uids[use.id.to_s].nil? if @compare_uids[use.id.to_s][0] +=1
                   end
                 else
                  processing = false
                 end
            rescue SystemExit, Interrupt,IRB::Abort
                raise
            rescue Exception=>e
              puts e.message
              if e.message =~ / for this time/
                sleep(300)
              end
              next
            end
            page+=1
          end while processing == true
          page = 1
          processing == true
          begin
            begin
              res = task.stable{task.api.comments.show(weibo_id,count:200,page:page)}
              #根据weibo_id查评论人信息
                if !res.comments.blank? 
                   res.comments.each do |line|
                    row = []
                    if line.nil?
                       processing = false
                       break
                    end
                    use = line.user
                    gender = genders[use.gender]
                    verified_type = WeiboAccount.human_verified_type(use.verified_type)*','
                    @compare_uids[use.id.to_s] ||= [1,{'url'=>url,'uid' =>use.id,'screen_name' =>use.screen_name,
                    'location' =>use.location,'gender'=>gender,'followers_count'=>use.followers_count,
                    'friends_count'=>use.friends_count,'statuses_count'=>use.statuses_count,
                    'created_at'=>Time.parse(use.created_at),'verified_type'=>use.verified_type,
                    'verified_reason'=>verified_reason}]
                   !@compare_uids[use.id.to_s].nil? if @compare_uids[use.id.to_s][0] +=1
                   end
                 else
                  processing = false
                 end
             rescue SystemExit, Interrupt,IRB::Abort
                raise
             rescue Exception=>e
              puts e.message
              if e.message =~ / for this time/
                sleep(300)
              end
              next
             end
             page+=1
          end while processing == true
      end
        @compare_uids.keys.each do |uid|
          puts uid
          row = []
          row = @compare_uids[uid][1].values
          row << @compare_uids[uid][0]
          row << ''
          csv << row
       end
    end

    #随机抽取500个互动人
    uids = @compare_uids.keys.sample 500
    
    #4,随机500互动用户共同关注
    keywords = {}
    CSV.open("#{folder}/共同关注_#{name}-随机500互动用户.csv","wb"){|csv|
      uids.each{|uid|
        begin
          ids = task.api.friendships.friends_ids(uid:uid,count:5000).ids
          ids.each{|id|
            next if id.nil? 
            keywords[id.to_s] ||= 0
            keywords[id.to_s] += 1
          }
        rescue Exception =>e
          puts e.message
          next
        end
      }
      keywords.sort{|a,b| b[1]<=>a[1]}.each do |line|
          csv << line
      end
    } && nil
    
    #随机500用户取出前共同关注前1000
    filename = "#{folder}/hudong_foucs_1000.csv"
    CSV.open filename,"wb" do |csv|
      #共同关注_韩后-随机500互动用户
      suiji500_old_csv = CSV.open "#{folder}/共同关注_#{name}-随机500互动用户.csv"
      suiji_num = 0
      suiji500_old_csv.each{|line|
        suiji_num += 1
        if suiji_num <= 1000
          csv << line
        end
      }
    end
    
    #补充取出前共同关注前1000信息用户信息
      #%w{UID 昵称 位置 性别 粉丝 关注 微博 注册时间 认证信息 认证原因 备注 标签}
      filename = "#{folder}/随机500互动用户共同关注前1000信息.csv"
      CSV.open filename,"wb" do |csv|
        old_csv = CSV.open "#{folder}/hudong_foucs_1000.csv"
        csv << %w{关注数 UID 昵称 位置 性别 粉丝 关注 微博 注册时间 认证信息 认证原因 备注 标签 最后一条微薄时间}
        old_csv.each{|line|
          uid = line[0].strip.to_i
         begin #解决异常
             res = task.stable{task.api.users.show(uid:uid)}
             if !res.blank?
                account = task.save_weibo_user(res)
             else
              csv << [line[1],uid,"此用户已屏蔽"]
              next
             end
          rescue Exception=>e
            csv << [line[1],uid,"信息有异常"]
            next
          end
          if res.status.nil?
            csv << [line[1]] + account.to_row(:full) + ["此用户没有发过微博"]
            next
          end
       csv << [line[1]] + account.to_row(:full) + [DateTime.parse(res.status.created_at).strftime("%Y-%m-%d %H:%S")]
       }
      end
    
    #5,随机500用户标签排行
    keywords = {}
    all_tags = {}
    uids.in_groups_of(20).each{|uid_group|
      begin
      res = task.stable{task.api.tags.tags_batch uid_group.compact*","}
      res.each{|tag|
          tags = tag.tags 
          tags.each{|info|
            info.delete "weight"
            tag_name = info.to_a.first[1]
            all_tags[tag_name] ||= 0
            all_tags[tag_name] += 1
          }
        }
      end
    } && nil
    filename = "#{folder}/标签排行-#{name}-随机500互动用户.csv"#"#{folder}/ 2-标签排行.csv"
    CSV.open(filename,"wb"){ |csv|
      all_tags.sort{|a,b| b[1]<=>a[1]}.each{|line|
        csv << line
      }
    }  && nil

  #6,随机500用户关键词排行

    all_keywords = {}
    url = "http://www.tfengyun.com/user.php?action=keywords&userid="
    uids.each_with_index{|uid,index|
      begin
        res = Net::HTTP.get URI.parse(url+uid.to_s)
        keywords = JSON.parse(res)

        puts "#{index} : #{keywords['keywords']}"
        keywords['keywords'].each do |kw|
          all_keywords[kw] ||= 0
          all_keywords[kw] += 1
        end
      rescue Timeout::Error
        debugger
        puts "#{uid} Timeout Error"
      end
    }
    filename = "#{folder}/关键词排行-#{name}-随机500用户.csv"#"#{folder}/keywords.csv"
    CSV.open(filename,"wb"){|csv|
      all_keywords.sort{|a,b| b[1]<=>a[1]}.each{|line|
        csv << line
      }
    } && nil

    #7,分析帐号500粉丝：提取所能提及的全量粉丝UID列表（包含以下维度：昵称、性别、地域、认证类型、关注数、粉丝数、微博数、单条微博平均互动量、开通微博时间）途尚咖啡twosome},true) #巴黎贝甜面包店 1653399282,BreadTalk_面包新语 2205618490,漫咖啡中国 2476750895,咖啡陪你caffebene 2759346065
    filename = "#{folder}/粉丝列表-#{name}.csv"
    task = GetUserTagsTask.new
    fans_uids = []
    CSV.open filename,"wb" do |csv|
       csv << ['主号uid']+ WeiboAccount.to_row_title(:full)
          begin
          friend_ids = task.stable{task.api.friendships.followers_ids(:uid=>target_uid, :count=>5000).ids} 
          rescue Exception=>e
            puts 'error:'
            puts e.class
            puts e.message
            if e.message =~ / for this time/
              sleep(300)
            end
            next
          end
        friend_ids.each do|uid|
         begin
            account = task.load_weibo_user(uid)
         rescue Exception=>e
          if e.message =~ / for this time/
              sleep(300)
          end
          csv << [target_uid,uid]
          next
         end
           next if account.blank?
           csv << [target_uid]+ account.to_row(:full)
           fans_uids << uid
        end
    end
    
    #随机抽取500粉丝的uid
    #uids = fans_uids.sample 500这块儿只抽取了有信息的
    #抽取全部uid
    fans_uids = []
    fans_old_csv = CSV.open "#{folder}/粉丝列表-#{name}.csv"
    fans_old_csv.each{|line|
      uid = line[1]
      if uid != "UID"
        fans_uids << uid
      end
    }
    
    #8,随机500粉丝标签排行
    keywords = {}
    all_tags = {}
    fans_uids.in_groups_of(20).each{|uid_group|
      begin
        res = task.stable{task.api.tags.tags_batch uid_group.compact*","}
        res.each{|tag|
          tags = tag.tags
          tags.each{|info|
            info.delete "weight"
            tag_name = info.to_a.first[1]
            all_tags[tag_name] ||= 0
            all_tags[tag_name] += 1
            }
          }
      end
    } && nil
    filename = "#{folder}/500粉丝标签排行-#{name}.csv"#"#{folder}/ 2-标签排行.csv"
    CSV.open(filename,"wb"){ |csv|
      all_tags.sort{|a,b| b[1]<=>a[1]}.each{|line|
        csv << line
      }
    }  && nil
    
    #8,随机500粉丝共同关注排行
    keywords = {}
    CSV.open("#{folder}/500粉丝共同关注_#{name}.csv","wb"){|csv|
      fans_uids.each{|uid|
        begin
          ids = task.api.friendships.friends_ids(uid:uid,count:5000).ids
          ids.each{|id|
            next if id.nil? 
            keywords[id.to_s] ||= 1
            !keywords[id.to_s].nil? if keywords[id.to_s]+=1
          }
        rescue Exception =>e
          next
        end
      }
      keywords.sort{|a,b| b[1]<=>a[1]}.each do |line|
        csv << line
      end
    } && nil
    
    #取出前共同关注前1000
    #随机500用户取出前共同关注前1000
    filename = "#{folder}/fans_foucs_1000.csv"
    CSV.open filename,"wb" do |csv|
      #共同关注_韩后-随机500互动用户
      suiji500_old_csv = CSV.open "#{folder}/500粉丝共同关注_#{name}.csv"
      suiji_num = 0
      suiji500_old_csv.each{|line|
        suiji_num += 1
        if suiji_num <= 1000
          csv << line
        end
      }
    end
    #补充取出前共同关注前1000信息
    filename = "#{folder}/500粉丝共同关注前1000信息.csv"
    CSV.open filename,"wb" do |csv|
      csv << %w{关注数 UID 昵称 位置 性别 粉丝 关注 微博 注册时间 认证信息 认证原因 备注 标签 最后一条微薄时间}
      old_csv = CSV.open "#{folder}/fans_foucs_1000.csv"
      old_csv.each{|line|
      uid = line[0].strip.to_i
     begin #解决异常
         res = task.stable{task.api.users.show(uid:uid)}
         if !res.blank?
            account = task.save_weibo_user(res)
         else
          csv << [line[1],uid,"此用户已屏蔽"]
          next
         end
      rescue Exception=>e
        csv << [line[1],uid,"信息有异常"]
        next
      end
      if res.status.nil?
        csv << [line[1]] + account.to_row(:full) + ["此用户没有发过微博"]
        next
      end
     csv << [line[1]] + account.to_row(:full) + [DateTime.parse(res.status.created_at).strftime("%Y-%m-%d %H:%S")]
     }
    end
    #9,随机500粉丝关键词排行
    CSV.open("#{folder}/500粉丝关键词_#{name}.csv","wb"){|csv|
    all_keywords = {}
    url = "http://www.tfengyun.com/user.php?action=keywords&userid="
    task = GetUserTagsTask.new
    fans_uids.each_with_index do |uid,index|
      begin
        res = task.stable{Net::HTTP.get URI.parse(url+uid.to_s)}
        keywords = JSON.parse(res)
        puts "#{index} : #{keywords['keywords']}"
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
    }

    #10, 随机500粉丝各100 条微博
    filename = "#{folder}/500粉丝近100条微博-#{name}.csv"
    CSV.open(filename,"wb"){|csv|
      csv << %w{name 微博内容 发布时间 转发数 评论数 互动总数 URL 原创 发布来源 原微博uid  原微博人昵称}
      task = GetUserTagsTask.new
      fans_uids.each{|uid|
        uid = uid.strip.to_i
        begin
          res = task.stable{task.api.statuses.user_timeline(uid:uid,count:100, page:1)}
          if !res['statuses'][0].nil?
            res['statuses'].each{|w|
              srouce = ActionView::Base.full_sanitizer.sanitize(w.source) #去出所有的标签
              url = "http://weibo.com/#{uid}/#{WeiboMidUtil.mid_to_str(w.id.to_s)}"
              post_at = Time.parse(w.created_at).strftime("%Y-%m-%d %H:%M")
              count = w.reposts_count + w.comments_count
              origin = !w.retweeted_status
              wuserid = ''
              wuserscreen_name = ''
              if !w.user.nil?
                wuserid = w.user.id
                wuserscreen_name = w.user.screen_name
              end
              csv << [w.user.screen_name, w.text,post_at, w.reposts_count, w.comments_count,count, url,origin, srouce,wuserid,wuserscreen_name]
            }
        end
        rescue Exception=>e
          puts e.message
        end
      }
    }

    #11,随机抽取500粉丝活跃度

    filename = "#{folder}/500粉丝活跃度-#{name}.csv"
    CSV.open(filename,"wb"){ |csv|
    csv << %w{uid 平均转发率 平均评论率 平均转发 平均评论 活跃度 原创占比}
    fans_uids.each do|uid|
     row = []
     puts uid
     weiboEvaluates = WeiboUserEvaluate.where("uid = ?",uid).first
     if weiboEvaluates.nil? || weiboEvaluates.origin_rate == -1
      begin
      weiboEvaluates= WeiboAccount.find_by_uid(uid).update_evaluates
      rescue IRB::Abort
        raise $!
      rescue Exception=>e
        puts e.message
        csv << [uid]
        next
      end
     end
     evaluates =   weiboEvaluates.forward_average + weiboEvaluates.comment_average
     puts evaluates
     row << uid
     row << weiboEvaluates.forward_rate/100.0
     row << weiboEvaluates.forward_rate/100.0
     row << weiboEvaluates.forward_average/100.0
     row << weiboEvaluates.comment_average/100.0
     row << evaluates/100.0
     row << weiboEvaluates.origin_rate
     csv << row
      end
    } && nil
    
