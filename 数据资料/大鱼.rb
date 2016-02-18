    #创建xlsx文件里面的页码名字
=begin
  def generate_excel_report
   sheets = [
             ["#{name}近期微薄列表","weibo_list_file"],
             ["微薄活动用户信息","get_weibo_list"],
             ["随机500互动用户共同关注排行前1000及信息","new_fans_old_fans"],#xiaowei:变化地方 信赖粉丝贡献
             ["随机500互动标签排行","weibo_stats_in_two_weeks"],
             ["随机500互动关键词排行","weibo_status_hourly_in_one_week"],
             ["#{name}粉丝列表","interact_users_for_last_week"],
             ["#{name}粉丝活跃度","interact_employees_for_last_week"], 
             ["#{name}粉丝共同关注排行前1000及信息","new_fans_verify_type_stats"],
             ["#{name}粉丝标签排行","new_fans_ranking"],   
             ["#{name}粉丝关键词排行","weibo_new_fans_hourly_in_one_week"],
             ["#{name}粉丝近100条微薄","link_click_count"],
            ]

    book = Spreadsheet::Workbook.new
    sheets.each{|name, method|
      next if !@include_sheets.blank? && !@include_sheets.include?(method)
      sheet = book.create_worksheet :name=>name

      puts "========================= create sheet #{name} =============================="
      self.send method, sheet
      puts "------------------------- end create sheet #{name} ---------------------------"

      puts "!!!!!!!!!!!!!!!!!!! start generate excel file"
      book.write @export_file #xlsx format will dead
    }
  end
  
  def sheet_set(sheet,row,col,data)
    if data.is_a? Array
      data.each{|d|
        sheet[row,col] = d
        col += 1
      }
    else
      sheet[row,col] = data
    end
  end
=end
  
  name = "韩后"
  target_uid = ReportUtils.names_to_uids([name],true)[0]
  folder = "data/#{name}-张桢"
  Dir.mkdir folder if !Dir.exist? folder

  #微博列表 
  weibo_list_file = "#{folder}/微博列表-#{name}.csv"  #微薄列表
  ReportUtils.export_weibo_list([target_uid],weibo_list_file,Time.new(2014,10,01),Time.new(2015,01,26)) #从接口提取这个人的微博列表 
  #3，数据B：提取与全部帖子互动的UID列表（包含以下维度：昵称、性别、地域、认证类型、关注数、粉丝数、微博数、单条微博平均互动量、开通微博时间）
  #接口提取 api 通过url 查出互动人信息列表(大文) 

  #直接导出的

  urls = [] # init urls
  CSV.open(weibo_list_file).each{|line|
    if line[6] != "URL"
      urls << line[6]
    end
  }
  
  filename = "#{folder}/互动人信息列表-#{name}.csv" #互动人信息
  task = GetUserTagsTask.new
  @compare_uids = {}
  CSV.open filename,"wb" do |csv|
    csv << ['url']+WeiboAccount.to_row_title(:default) +['主号互动次数','是否是主号粉丝']
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
            res = task.stable{task.api.comments.show(weibo_id,count:200,page:page)}#根据weibo_id查评论人信息
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

#这快儿需要随机取出500个互动人的id(不够的话全部取出) 得到500人的共同关注

  uids = @compare_uids.keys.sample 500

  #数据F：提取【数据D】随机抽取500查出互动量#这个互动量是楼上随机抽取的500互动用户

  filename = "#{folder}/随机500活跃度-#{name}.csv"
  CSV.open(filename,"wb"){ |csv|
  csv << %w{uid 平均转发率 平均评论率 平均转发 平均评论 活跃度 原创占比}
  uids.each do|uid|
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

  #互动人共同关注
  keywords = {}
  task = GetUserTagsTask.new
  CSV.open("#{folder}/共同关注_#{name}-粉丝.csv","wb"){|csv|
    csv << %w{UID 共同关注次数}
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
  }
  
  #互动人标签排行
  CSV.open("#{folder}/标签排行_#{name}-粉丝.csv","wb"){|csv|
    csv << %w{标签 标签排行}
    all_tags = {}
    task = GetUserTagsTask.new
    uids.in_groups_of(20).each do |uid|
      res = task.stable{task.api.tags.tags_batch uid.compact*","}
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
    all_tags.sort{|a,b| b[1]<=>a[1]}.each{|line|
          csv << line
        } 
  }
  
  #互动人关键词排行
  CSV.open("#{folder}/关键词排行_#{name}-粉丝.csv","wb"){|csv|
    csv << %w{关键词 关键词数量}
    all_keywords = {}
    url = "http://www.tfengyun.com/user.php?action=keywords&userid="
    task = GetUserTagsTask.new
      uids.each_with_index do |uid,index|
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
  

  #==========================以上都是针对随机的500互动人的关键词，标签，共同关注
  #7.数据D：提取所能提及的全量粉丝UID列表（包含以下维度：昵称、性别、地域、认证类型、关注数、粉丝数、微博数、单条微博平均互动量、开通微博时间）途尚咖啡twosome},true) #巴黎贝甜面包店 1653399282,BreadTalk_面包新语 2205618490,漫咖啡中国 2476750895,咖啡陪你caffebene 2759346065
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

  #取出500粉丝
  uids = fans_uids[0..500]
  debugger
  #粉丝共同关注
  keywords = {}
  task = GetUserTagsTask.new
  CSV.open("#{folder}/共同关注_#{name}-粉丝.csv","wb"){|csv|
    csv << %w{UID 共同关注次数}
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
  }
  
  #粉丝标签排行
  CSV.open("#{folder}/标签排行_#{name}-粉丝.csv","wb"){|csv|
    csv << %w{标签 标签排行}
    all_tags = {}
    task = GetUserTagsTask.new
    uids.in_groups_of(20).each do |uid|
      res = task.stable{task.api.tags.tags_batch uid.compact*","}
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
    all_tags.sort{|a,b| b[1]<=>a[1]}.each{|line|
          csv << line
        } 
  }
  
  #粉丝关键词排行
  CSV.open("#{folder}/关键词排行_#{name}-粉丝.csv","wb"){|csv|
    csv << %w{关键词 关键词数量}
    all_keywords = {}
    url = "http://www.tfengyun.com/user.php?action=keywords&userid="
    task = GetUserTagsTask.new
      uids.each_with_index do |uid,index|
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

  # 各100 条微博 这是随机抽取的500个粉丝的每个人的前100条微薄
    filename = "#{folder}/近100条微博-#{name}.csv"
    CSV.open(filename,"wb"){|csv|
      csv << %w{name 微博内容 发布时间 转发数 评论数 互动总数 URL 原创 发布来源 原微博uid  原微博人昵称  }
      task = GetUserTagsTask.new
      uids.each{|uid|
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
