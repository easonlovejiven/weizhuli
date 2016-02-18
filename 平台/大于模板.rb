  
#这些方法都实现了,但是需要将这些方法封装到一个类中

temp = NewTemplate.new("INTEL China")
temp.generate "./aaa.xlsx"

#TODO: 

  =begin
    def generate_excel_report #表格名称,和调用相应的方法
   sheets = [
             ["数据A 全部帖子列表","all_the_post_list"], 
             ["数据B1部分非活动帖互动人信息","some_nohudong_info"],
             ["数据B提取与全部帖子互动的UID列表(抽样500)","new_fans_old_fans"],
             ["数据C［提取数据B］的共同关注前500名列表","weibo_stats_in_two_weeks"],
             ["数据C1 提取［数据B］标签排行","weibo_status_hourly_in_one_week"],
             ["数据C2提取［数据B］近期发布的微博当中关键词的排行","interact_users_for_last_week"],
             ["数据D提取所能提及的全量粉丝UID列表","interact_employees_for_last_week"], 
             ["c","new_fans_verify_type_stats"],
             ["数据F提取［数据D］微博100以上","new_fans_ranking"],   
             ["数据F提取［数据D］随即抽取500查出互动量","weibo_new_fans_hourly_in_one_week"],
            ]
    book = Spreadsheet::Workbook.new
    sheets.each{|name, method| #去循环遍历封装的一些方法和名称
      next if !@include_sheets.blank? && !@include_sheets.include?(method)
      sheet = book.create_worksheet :name=>name

      puts "========================= create sheet #{name} =============================="
      self.send method, sheet #匹配动态调用方法 动态的根据名字调用函数
      puts "------------------------- end create sheet #{name} ---------------------------"

      puts "!!!!!!!!!!!!!!!!!!! start generate excel file"
      book.write @export_file #xlsx format will dead
    }
  =end
  
  #end
  
  #(1)
  name = "CHC动作电影频道"
  target_uid = ReportUtils.names_to_uids([name],true)[0] #得到主号的帐号(传一个主号的name可以得到帐号) 

  #(2)
  folder = "data/#{name}-大于模板" 
  Dir.mkdir folder if !Dir.exist? folder

  #微博列表("数据A 全部帖子列表") ===================================>>1
  weibo_list_file = "#{folder}/微博列表-#{name}.csv"
  ReportUtils.export_weibo_list([target_uid],weibo_list_file,Time.new(2012,6,30),Time.new(2014,9,2)) #从接口提取这个人的微博列表
 
  #3，数据B：提取与全部帖子互动的UID列表（包含以下维度：昵称、性别、地域、认证类型、关注数、粉丝数、微博数、单条微博平均互动量、开通微博时间）
  #接口提取 api 通过url 查出互动人信息列表(大文) 

  #直接导出的

  #主号发布的微博url
  urls = [] # init urls 

  interaction_number = 0
  CSV.open(weibo_list_file).each{|line|
    next if interaction_number > 1000
    next if line.last =~ /活动/
    next if !(line[-3] =~ /http/)
    next if line[5].to_i > 100
    urls << line[-3]
    interaction_number += line[5].to_i
  }
    

  #数据B1部分非活动帖互动人信息 =========================================>>2
  filename = "#{folder}/互动人信息列表-#{name}.csv" #与一些主号的互动次数
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

  #数据C［提取数据B］的共同关注前500名列表 =====================================>> 4
uids = @compare_uids.keys[0..500] #取出500个用户
keywords = {}
CSV.open("#{folder}/共同关注_#{name}-互动人.csv","wb"){|csv|
  uids.each{|uid|
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

  filename = "#{folder}/标签排行-#{name}-互动用户.csv"
  CSV.open(filename,"wb"){ |csv|
    all_tags.sort{|a,b| b[1]<=>a[1]}.each{|line|
      csv << line
    }
  }  && nil

# 最近微博关键词内容(数据C2提取［数据B］近期发布的微博当中关键词的排行) =========================>>6

all_keywords = {}
url = "http://www.tfengyun.com/user.php?action=keywords&userid="
uids.each_with_index{|uid,index|
  begin
    res = Net::HTTP.get URI.parse(url+uid.to_s)
    keywords = JSON.parse(res)
    puts "#{index} : #{keywords['keywords']}"
    keywords['keywords'].each do |kw|
      all_keywords[kw] ||= 0 #当没有关键词时(all_keywords == nill)时 将0赋给这个变量 all_keywords[kw]
      all_keywords[kw] += 1
    end
  rescue Timeout::Error
    puts "#{uid} Timeout Error"
  end
}

filename = "#{folder}/keywords-#{name}.csv"#"#{folder}/keywords.csv"
CSV.open(filename,"wb"){|csv|
  all_keywords.sort{|a,b| b[1]<=>a[1]}.each{|line|
    csv << line
  }
} && nil

#7.数据D：提取所能提及的全量粉丝UID列表（包含以下维度：昵称、性别、地域、认证类型、关注数、粉丝数、微博数、单条微博平均互动量、开通微博时间）途尚咖啡twosome},true) #巴黎贝甜面包店 1653399282,BreadTalk_面包新语 2205618490,漫咖啡中国 2476750895,咖啡陪你caffebene 2759346065

filename = "#{folder}/粉丝列表-#{name}.csv"   #=======================>> 7
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

uids = fans_uids[0..500]

keywords = {}
CSV.open("#{folder}/共同关注_#{name}-粉丝.csv","wb"){|csv|
  uids.each{|uid|
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

# 获取标签排行  new by huye 数据C1 提取［数据B］标签排行  ============================>>5

  keywords = {}

  all_tags = {} #里边儿存放着得到的标签 
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

  filename = "#{folder}/标签排行-#{name}-粉丝.csv"#"#{folder}/ 2-标签排行.csv"
  CSV.open(filename,"wb"){ |csv|
    all_tags.sort{|a,b| b[1]<=>a[1]}.each{|line|
      csv << line
    }
  }  && nil

  #获取关键词排行=>>数据E提取［数据D］的共同关注前500名列表 ======================>>8
  keywords = {}
  CSV.open("#{folder}/共同关注_#{name}-粉丝.csv","wb"){|csv| #共同关注前500名列表
    uids.each{|uid|
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


  # 每个用户的各100条微博=>>数据F提取［数据D］微博100以上 =======================>>9
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

  #数据F：提取【数据D】随机抽取500查出互动量 (主号的互动粉丝互动量) 需要手动添加每个用户的基本信息,需要从接口当中取=======>>10

  z_uid = 2637370247#与某个主号的
  start_time = '2014-09-01'#开始时间
  end_time = '2014-10-01'
  filename = "73066与中国的有互动的粉丝信息最新33-九月份.csv"
  sum = 0
  CSV.open filename,"wb" do |csv|
    csv << %w{UID 评论 转发 昵称 位置 性别 粉丝 关注 微博 注册时间 认证类型 认证原因 备注 标签 平均转发率 平均评论率 平均转发 平均评论 平均互动量 活跃度 原创占比 日均发帖量 近七天发贴量}
    uids = open '/home/rails/Desktop/uids'#文件的路径
    uids = uids.read
    uids = uids.strip.split("\n")
    uids.each do |uid|
      uid = uid.strip
      weibo_account = WeiboAccount.where("uid = ?",uid)
      we = WeiboUserEvaluate.find_by_uid(uid)
      muser = MUser.find_by_id(uid.to_i) #可以取出用户备注信息
      comment_num = WeiboComment.where("uid = ? and comment_at between ? and ?",z_uid,start_time,end_time).where("comment_uid = ?",uid).count("distinct comment_id")
      forward_num = WeiboForward.where("uid = ? and forward_at between ? and ?",z_uid,start_time,end_time).where("forward_uid = ?",uid).count("distinct forward_id")
      if !weibo_account.blank?
      screen_name = weibo_account[0].screen_name #昵称
      location = weibo_account[0].location #位置
      #weibo_account[0].gender == 0 ? @sex = "女" : @sex = "男"
      @sex = weibo_account[0].human_gender
      followers_count = weibo_account[0].followers_count #粉丝
      friends_count = weibo_account[0].friends_count #关注
      statuses_count = weibo_account[0].statuses_count #微博数量
      if !weibo_account[0].created_at.blank?
        created_at = weibo_account[0].created_at.strftime("%Y-%m-%d %H:%M:%S") #用户创建(注册)时间 #有些用户的信息里边儿并没有注册时间(这里要做个判断)
      end
      verified_type = weibo_account[0].verified_type #认证类型
      #调用认证类型的方法
      @type_name = weibo_account[0].human_verified_type #这块儿怎样将数组转换成文字格式
      @name_str = "" #存放认证类型
        #将认证类型的这个数组循环遍历  
        @type_name.each do |name|
          if !@name_str.blank?
            @name_str += name+","
          end
        end
         @name_str = @name_str[0,@name_str.length-1]
      if !we.blank? #在这块儿要做个非空判断

          avg_forward_rate = we.forward_rate/100.0 #平均转发率
          avg_comment_rate = we.comment_rate/100.0 #平均评论率
          avg_forward_average = we.forward_average/100.0 #平均转发数
          avg_comment_average = we.comment_average/100.0 #平均评论数
          avg_interactive = avg_forward_average+avg_comment_average #平均互动
          evaluates = avg_forward_average+avg_comment_average #活跃度
          origin_rate = we.origin_rate #原创占比
          day_posts = we.day_posts #日均发贴量
          day_posts_in_weeks = we.day_posts_in_week #近七天发贴量
          if !muser.blank?
            length = muser.tags.size
            if length == 0
              csv << [uid,comment_num,forward_num,screen_name,location,@sex,followers_count,friends_count,statuses_count,created_at,@name_str,nil,muser.description,nil,
avg_forward_rate,avg_comment_rate,avg_forward_average,avg_comment_average,avg_interactive,evaluates,origin_rate,day_posts,day_posts_in_weeks]
             elsif 
                length > 0
            tag_str = ""
            muser.tags.each do |t|
              tag_str += t + ","
            end
              tag_str = tag_str[0,tag_str.length-1]
            csv << [uid,comment_num,forward_num,screen_name,location,@sex,followers_count,friends_count,statuses_count,created_at,@name_str,nil,muser.description,tag_str,
avg_forward_rate,avg_comment_rate,avg_forward_average,avg_comment_average,avg_interactive,evaluates,origin_rate,day_posts,day_posts_in_weeks]      
          end
        end
        end
      end
    end
  end
