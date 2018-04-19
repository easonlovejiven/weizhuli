  name = "354" #一个小时2W 
  filename = "#{name}信息.csv"
  CSV.open filename,"wb" do |csv|
    task = GetUserTagsTask.new
    csv << WeiboAccount.to_row_title(:full) + %w{平均转发率 平均评论率 平均转发 平均评论 活跃度 原创占比 日均发帖量 近七天发贴量}
    uids = open "354-uid"
    uids = uids.read
    uids = uids.strip.split("\n")
    uids = uids.uniq
    uids.each do |uid|
      uid = uid.strip
      begin
       wa = WeiboAccount.find_by_uid(uid)
       row = []
         account = task.load_weibo_user(uid)
         weiboEvaluates = WeiboUserEvaluate.where("uid = ?",uid).first
         if weiboEvaluates.nil? || weiboEvaluates.origin_rate == -1
            weiboEvaluates= WeiboAccount.find_by_uid(uid).update_evaluates #更新一下用户的活跃度信息
         end
         evaluates =   weiboEvaluates.forward_average + weiboEvaluates.comment_average
         row << weiboEvaluates.forward_rate/100.0
         row << weiboEvaluates.forward_rate/100.0
         row << weiboEvaluates.forward_average/100.0
         row << weiboEvaluates.comment_average/100.0
         row << evaluates/100.0
         row << weiboEvaluates.origin_rate
         row << weiboEvaluates.day_posts
         row << weiboEvaluates.day_posts_in_week
         
         if !account.blank?
          csv << account.to_row(:full) + row
          elsif #这个帐号可能是库里边儿没有的
            csv << [uid,'找不到信息']
         end
      rescue Exception=>e
          if e.message =~ /User does not exists!/
            csv << [uid,"此用户不存在"]
            elsif e.message =~ /requests out of/
              debugger
              sleep 2700
            end
        end
      end
    end
  end
  
  #合并两个csv文件
  #商用频道：两个都在本地跑
  #芯品汇：信息在app21；时间在app5：断了
  
  #最后一条微薄时间
  #只跑出没有时间的用户
  filename = "354-时间.csv" #一个小时3W
  CSV.open filename,"wb" do |csv|
    csv << %w{UID 时间 距离现在的天数}
    task = GetUserTagsTask.new
    day = 0
    uids = open "354-uid"
    uids = uids.read
    uids = uids.strip.split("\n")
    uids = uids.uniq
    uids.each do |uid|
      uid = uid.strip
      begin
        res = task.stable{task.api.users.show(uid:uid)}
        if !res.blank?
          if !res.status.blank?
            last_time = DateTime.parse(res.status.created_at).strftime("%Y-%m-%d %H:%S") #近一条微博时间
            now_time = Date.parse(Time.now.strftime("%Y-%m-%d %H:%S"))
            last_time = Date.parse(last_time)
            day = (now_time-last_time).to_i
            csv << [uid,last_time,day]
            elsif res.status.blank?
              csv << [uid,"此用户没有发过微薄"]
          end
          elsif res.blank?
            csv << [uid,"取不到用户信息"]
        end
      rescue Exception=>e
        if e.message =~ /User does not exists!/
          csv << [uid,"此用户已被屏蔽"]
        end
      end
    end
  end
  
  filename = "母亲节-最终2.csv"
  CSV.open filename,"wb" do |csv|
  
    old_csv1 = CSV.open "母亲节-补充.csv"
    old_csv1.each do |line|
      csv << line
    end
    
    old_csv2 = CSV.open "母亲节-补充-2.csv"
    old_csv2.each do |line|
      csv << line
    end
    
    old_csv3 = CSV.open "母亲节-补充-3.csv"
    old_csv3.each do |line|
      csv << line
    end
    
  end
  
  #去除标题
  
  filename = "搜索.csv"
  CSV.open filename,"wb" do |csv|
    old_csv = CSV.open "最终搜索.csv"
    old_csv.each{|line|
      if line[0] != "UID"
        csv << line
      end
    }
  end
  
  #商用频道：两个都在本地跑
  #芯品汇：信息在app21；时间在app5：断了
  
  filename = "时间.csv"
  CSV.open filename,"wb" do |csv|
    day = 0
    old_csv = CSV.open "yl-最后一条微薄时间补.csv"
    old_csv = old_csv.read
    old_csv.each do |line|
      if line[2] != nil
        day = line[2].to_i
        if day < 90
          csv << line
        end
      end
    end
  end
  
  def get
    day = 0
    num = 0
    old_csv = CSV.open "yl-最后一条微薄时间补.csv"
    old_csv.each do |line|
      if line[2] != nil
        day = line[2].to_i
        if day < 30
          num += 1
        end
      end
    end 
    puts num
  end
  
  #固定数组里边儿抽出随机的量完全正确
  
  #十万个元素当中取出500个元素
  hash = {}
  filename = "1000.csv"
  CSV.open filename,"wb" do |csv|
    keywords = open "8626"
    keywords = keywords.read
    keywords = keywords.strip.split("\n")
    keywords = keywords.uniq
    num = 0
    #用来存放hash里边儿的值
    array = []
    rows = []
    keywords.each{|word|
      num += 1
      hash[word] = num
    }
    #随机取出其中的500个元素 weixin.response_text(params[:xml][:FromUserName],"A"),
    array = [*1..keywords.size].sample 1000
    
    #将hash里边儿的key和alue进行互换
    hash = hash.invert
    
    array.each{|arr|
      rows = []
      line = hash[arr]
      if !line.blank?
        rows << line
        csv << rows
      end
    }
  end
  
  arr = [
      weixin.response_text(params={:xml=>{:FromUserName=>"123123412341234143"}},"您好，我们已经将1万元按要求转入你的账户，请在第61秒时进行确认，否则转账作废。"),
      weixin.response_text(params={:xml=>{:FromUserName=>"123123412341234143"}},"提前串通你的整个部门，例如：可以在部门内部群，或者好闺蜜/基友内部群说，我跟听行政说我们明天可以放半天假噢....这样~你就可以在明天早晨安安稳稳的等着他/她递请假条啦~"),
      weixin.response_text(params={:xml=>{:FromUserName=>"123123412341234143"}},"抓住不在电脑旁边的几分钟或者故意将其支开某人（不会不知道怎么做吧？），将其所有打开的窗口最小化并将任务栏拖到屏幕上方并隐藏，然后使用Print Screen键捕捉其桌面。打开“画图”程序，按下Ctrl＋v粘贴刚才所抓图片，并将其保存为*.bmp格式。回到桌面，将刚才所保存的图片设置为桌面，然后你就会见到...啧啧啧，你太狠心了..."),
      weixin.response_text(params={:xml=>{:FromUserName=>"123123412341234143"}},"小智今天收到一封邮件，邮件名称是“你不懂，我不说”，赶快打开邮件，里面还有一个压缩文件，下载下来，解压缩，里面还有一个压缩文件，再解压缩，里面还有一个压缩文件，还解压缩...五十六次之后我终于看见了里面的一张图片...上面一只小狗，很可爱的摇着尾巴..."),
      weixin.response_text(params={:xml=>{:FromUserName=>"123123412341234143"}},"如果有人想骗你但是被你看穿了，你大可以将他收服，然后成立统一战线联盟，合二人之力去开创更为广阔的天地，骗倒更多人。"),
      weixin.response_text(params={:xml=>{:FromUserName=>"123123412341234143"}},"一走进公司，正准备坐下时，古灵精怪的大闺蜜雯雯跑过来拦住我：“别坐，千万别坐”，“怎么了?”我心一惊，莫非她想“整蛊”我?“刚刚一只鸟飞到公司来了，在你的椅子上拉了一包屎，我刚刚用水把屎擦干净的，你等会儿再坐。”“哈哈…写字楼里怎么会有鸟啊…想暗算我”，我心想：“也不看看小智是什么人物，想暗算我?没门。”于是，我扑哧一声笑了：“你当我是白痴啊，今天是‘愚人节’啊”。说完，我一屁股就往椅子上一坐，只听到轰地一声，我摔倒在地上，“哎哟……椅子是坏的..."),
      weixin.response_text(params={:xml=>{:FromUserName=>"123123412341234143"}},"拿一截绳子，拦住一位同事，要他帮忙测量一下尺寸。再拿着绳子的另一头，转过楼角，又拦住另一位同事，如法炮制。然后你就可以躲在一边看热闹去了。两头的人可能会等上十几分钟，见没有动静才放下绳头，去找对方问个明白，也许还会...")
    ]
          res = [*1..arr.size].sample 1
  
  #500个粉丝
  name = "EMC中国-云计算"
  filename = "#{name}活跃粉丝1.csv" #一个小时3W
  CSV.open filename,"wb" do |csv|
    task = GetUserTagsTask.new
    #z_uid = 2637370927
    day = 0#距离现在的天数
    rows = []
    old_csv = CSV.open "EMC中国-云计算2000个粉丝信息.csv"
    old_csv.each do |line|
      if line[0] != "UID"
        uid = line[0].to_i
        begin
          res = task.stable{task.api.users.show(uid:uid)}
          if !res.blank?
            if !res.status.blank?
              last_time = DateTime.parse(res.status.created_at).strftime("%Y-%m-%d %H:%S") #近一条微博时间
              last_time = Date.parse(last_time)
              now_time = Date.parse(Time.now.strftime("%Y-%m-%d %H:%S"))
              day = (now_time-last_time).to_i
              csv << [uid,last_time,day]
              elsif res.status.blank?
                csv << [uid,'此用户没有发过微博']
            end
            elsif res.blank?
              csv << [uid,'取不到信息']  #可能是被屏蔽了
            end
        rescue Exception=>e
          if e.message =~ /User does not exists!/
            csv << [uid,"此用户已被屏蔽"]
          end
        end
      end
    end
  end
  
  #芯品汇所有粉丝(这快儿要分页处理了)
  
  filename = "-all-uid"
  CSV.open filename,"wb" do |csv|
    z_uid = 1979838530
    wrus = WeiboUserRelation.where("uid = ?",z_uid)
    wrus.each do |wru|
      uid = wru.by_uid
      csv << [uid]
    end
  end
  
  #(2)
  filename = "intel-all-uid"
  CSV.open filename,"wb" do |csv|
    z_uid = 2637370927
    wrus = WeiboUserRelation.where("uid = ?",z_uid)
    wrus.each do |wru|
      uid = wru.by_uid
      csv << [uid]
    end
  end
  
  #现在是否是粉丝
  
  name = "商用频道" #app3(1);商用频道最新粉丝信息app3(0)
  filename = "#{name}粉丝判断补充.csv"
  CSV.open filename,"wb" do |csv|
    z_uid = 2295615873
    task = GetUserTagsTask.new
    csv << %w{UID 现在是否是粉丝}
    uids = open "wu-uid"
    uids = uids.read
    uids = uids.strip.split("\n")
    uids = uids.uniq
    uids.each do |uid|
      uid = uid.strip
      begin
        res = task.stable{task.api.friendships.show(source_id:uid,target_id:z_uid)}
        wur = WeiboUserRelation.where("uid = ? and by_uid = ?",z_uid,uid)
        if !res.blank?
          if !res.source.blank?
            istargetfans = res.source.following ? "Y" : "N"
            csv << [uid,istargetfans,]
            elsif res.source.blank?
              csv << [uid,'目标用户不存在']
          end
          elsif res.blank?
            csv << [uid,'找不到用户']
          end
      rescue Exception=>e
          if e.message =~ /does not exists!/
            csv << [uid,"此用户已屏蔽"]
          next
        end
      end
    end
  end
  
  #得到
  
  def get
    key = "2751696217"
    secret = "3dbddd005fc1af2600f795806cc372bc"
    WeiboOAuth2::Config.api_key = key
    WeiboOAuth2::Config.api_secret = secret
    @client = WeiboOAuth2::Client.new
    u = "18813015535"
    p = "y159357l"
    t = @client.auth_password.get_token(u,p)
    token = t.token# "2.005wKAMBDtpNADc71e3fbde2T8XNWB"
  end
  
  filename = "用户-tokens.csv"
  CSV.open filename,"wb" do |csv|
  old_csv = CSV.open "1000_weibo_accounts.csv"
  old_csv.each do |line|
    begin
      key = "2751696217"
      secret = "3dbddd005fc1af2600f795806cc372bc"
      WeiboOAuth2::Config.api_key = key
      WeiboOAuth2::Config.api_secret = secret
      @client = WeiboOAuth2::Client.new
      uname = line[0]
      pwd = line[1]
      t = @client.auth_password.get_token(uname,pwd)
      csv << [t.token]
      rescue Exception=>e
        if e.message =~ /username or password error/
          csv << ["昵称或者密码不正确"]
        end
      end
    end
  end
  
  else
    arr = [
      weixin.response_text(params[:xml][:FromUserName],"注意了，快，快看你的左边，再看你的右边，你知道么，最近刚溜出来一个神经病，他的特征就是拿着手机东张西望。哈哈哈，不服来战~"),
      weixin.response_text(params[:xml][:FromUserName],"您好，我们已经将1万元按要求转入你的账户，请在第61秒时进行确认，否则转账作废。"),
      weixin.response_text(params[:xml][:FromUserName],"提前串通你的整个部门，例如：可以在部门内部群，或者好闺蜜/基友内部群说，我跟听行政说我们明天可以放半天假噢....这样~你就可以在明天早晨安安稳稳的等着他/她递请假条啦~"),
      weixin.response_text(params[:xml][:FromUserName],"抓住不在电脑旁边的几分钟或者故意将其支开某人（不会不知道怎么做吧？），将其所有打开的窗口最小化并将任务栏拖到屏幕上方并隐藏，然后使用Print Screen键捕捉其桌面。打开“画图”程序，按下Ctrl＋v粘贴刚才所抓图片，并将其保存为*.bmp格式。回到桌面，将刚才所保存的图片设置为桌面，然后你就会见到...啧啧啧，你太狠心了..."),
      weixin.response_text(params[:xml][:FromUserName],"小智今天收到一封邮件，邮件名称是“你不懂，我不说”，赶快打开邮件，里面还有一个压缩文件，下载下来，解压缩，里面还有一个压缩文件，再解压缩，里面还有一个压缩文件，还解压缩...五十六次之后我终于看见了里面的一张图片...上面一只小狗，很可爱的摇着尾巴..."),
      weixin.response_text(params[:xml][:FromUserName],"如果有人想骗你但是被你看穿了，你大可以将他收服，然后成立统一战线联盟，合二人之力去开创更为广阔的天地，骗倒更多人。"),
      weixin.response_text(params[:xml][:FromUserName],"一走进公司，正准备坐下时，古灵精怪的大闺蜜雯雯跑过来拦住我：“别坐，千万别坐”，“怎么了?”我心一惊，莫非她想“整蛊”我?“刚刚一只鸟飞到公司来了，在你的椅子上拉了一包屎，我刚刚用水把屎擦干净的，你等会儿再坐。”“哈哈…写字楼里怎么会有鸟啊…想暗算我”，我心想：“也不看看小智是什么人物，想暗算我?没门。”于是，我扑哧一声笑了：“你当我是白痴啊，今天是‘愚人节’啊”。说完，我一屁股就往椅子上一坐，只听到轰地一声，我摔倒在地上，“哎哟……椅子是坏的..."),
      weixin.response_text(params[:xml][:FromUserName],"拿一截绳子，拦住一位同事，要他帮忙测量一下尺寸。再拿着绳子的另一头，转过楼角，又拦住另一位同事，如法炮制。然后你就可以躲在一边看热闹去了。两头的人可能会等上十几分钟，见没有动静才放下绳头，去找对方问个明白，也许还会...")
    ]
    res = arr[rand(0..arr.size-1)]
    
  #接口提取用户uid
  
  task = GetUserTagsTask.new
  filename = "236帐号.csv"
  CSV.open filename,"wb" do |csv|
    names = open "names"
    names = names.read
    names = names.strip.split("\n")
    names = names.uniq
    names.each do |name|
      name = name.strip
      begin
      res = task.stable{task.api.users.show(screen_name:name)}
        if !res.blank?
          csv << [name,res.id]
          else
            csv << [name,nil]
        end
        rescue Exception=>e
        if e.message =~ /User does not exists!/
          csv << [name,"此用户不存在"]
          else
            raise e
        end
      end
    end
  end
  
  #从库里边儿取活跃度
  
  task = GetUserTagsTask.new
  filename = "zz-uids"
  CSV.open filename,"wb" do |csv|
    names = open "names"
    names = names.read
    names = names.strip.split("\n")
    names = names.uniq
    names.each do |name|
      wa = WeiboAccount.find_by_screen_name(name)
      if wa != nil
        csv << [wa.uid]
        else
          csv << ['用户不存在']
      end
    end
  end
  
  #接口提取指定帐号2000粉丝信息 
    
  name = "Mike隋"
  filename = "#{name}500个粉丝信息.csv"
  CSV.open filename,"wb" do |csv|
     task = GetUserTagsTask.new
       titles = ['主号uid']+ WeiboAccount.to_row_title(:full)
       csv << titles
          target_id = 1686659730
          begin
            friend_ids = task.stable{task.api.friendships.followers_ids(:uid=>target_id, :count=>5000).ids}
            debugger
            rescue Exception=>e
              puts 'error:类'
              if e.message =~ / for this time/
                sleep(300)
              end
              csv << [target_id]
              next
            end
            friend_ids.each do|uid|
              begin
                account = task.load_weibo_user(uid)
              rescue Exception=>e
                if e.message =~ / for this time/
                  sleep(300)
                end
                csv << [target_id,uid,'此用户已被屏蔽']
                next
              end
              next if account.blank?
              csv << [target_id]+ account.to_row(:full)
        end
  end
  
  #抽取2000粉丝当中的500名
  
  name = "bds"
  filename = "#{name}500粉丝"
  CSV.open filename,"wb" do |csv|
    index = 0
    old_csv = CSV.open "微薄的互动内容贝蒂斯橄榄油.csv"
    old_csv.each do |line|
      index += 1
      if line[0] != "uid"
        if index % 5 == 0
          c sv << [line[0]]
        end
      end
    end
  end
  
  #去除重复的
  
  filename = "AAA"
  CSV.open filename,"wb" do |csv|
    uids = open "aaa-uid"
    uids = uids.read
    uids = uids.strip.split("\n")
    uids = uids.uniq
    uids.each{|uid|
      csv << [uid]
    }
  end
  
  #取出一个数组2000个当中的500粉丝
  
  filename = "hebei-uid"
  CSV.open filename,"wb" do |csv|
    uids = open "hebei-2000"
    uids = uids.read
    uids = uids.strip.split("\n")
    uids = uids.uniq
    index = 0
    uids.each{|uid|
      index += 1
      if index % 4 == 0
        csv << [uid]
      end
    }
  end
  #统计被屏蔽的用户量
  
  def get
    num = 0
    old_csv = CSV.open "IT数码搜罗2000个粉丝信息.csv"
    old_csv.each{|line|
      var = line[2]
      if var == "此用户已被屏蔽"
        num += 1
      end
    }
    puts num
  end
  
  
  #在上面的基础上只取出粉丝的uid
  
  name = "只取出粉丝的uid"
  filename = "#{name}.csv"
  CSV.open filename,"wb" do |csv|
     task = GetUserTagsTask.new
      uids = open ""
      uids = uids.read
      uids = uids.strip.split("\n")
      uids.each do |target_id|
        task = GetUserTagsTask.new
        ids = task.stable{task.api.friendships.followers_ids(:uid=>1985391034, :count=>5000).ids}
        ids.each{|id|
          csv << [target_id,id]
        }
    end
  end
  
  #匹配(以多匹配多的) 
  
    hash = {}
    filename = "gw-转发趋势.csv"
    CSV.open filename,"wb" do |csv|
      old_csv = CSV.open '近3个月idf.csv'
      
      old_csv.each{|line|
        uid = line[0]
        hash[uid] = line
      }
      
      uids = CSV.open "日期统计.csv"
      
      uids.each do |line|
        line = hash[line[0]]
        if !line.blank?
          csv << line
          else
            csv << [line,0]
        end
      end
    end
    
    filename = "转发贴-2-趋势.csv"
    CSV.open filename,"wb" do |csv|
      csv << %w{互动日期 评论 转发 互动}
      old_csv = CSV.open "zf-转发趋势.csv"
      old_csv.each{|line|
          csv << [line[0],line[1],line[2],line[1].to_i+line[2].to_i]
      }
    end
  
  
  filename = "初次筛选.csv"
  CSV.open filename,"wb" do |csv|
    
    old_csv = CSV.open "何阳单个词1.csv"
    
    keywords = ['车','骑','开','维修','驾','辆']
    
    old_csv.each{|line|
      if line[0] != "UID"
        content = line[14]
        keywords.each{
          if !content.include?(keywords[5])
            csv << line
          end
        }
      end
    }
  end
  
  #主要针对去重
  filename = "最红筛选.csv"
  CSV.open filename,"wb" do |csv|
    uids = open "uids"
    uids = uids.read
    uids = uids.strip.split("\n")
    uids = uniq
    uids.each do |uid|
      csv << [uid]
    end
  end
  
  #以多匹配少的
  
  filename = "a.csv"
  CSV.open filename,"wb" do |csv|
    status = {}
    csv << %w{URL 数量}
    num = 0
    urls = open 'names'
    urls = urls.read
    urls = urls.strip.split("\n")
      urls.each do |url|
        status[url] = 0
      end
      urls.each do |url|
        next if url.nil?
          if status[url].blank?
            status[url] = 0
          end
            status[url] += 1
      end
     status.each do |line|
        csv << line
     end
  end
  
  hash = {}
  filename = "核心粉丝每月发帖数-5.csv"
  CSV.open filename,"wb" do |csv|
  
    old_csv = CSV.open 'a.csv'
    
    old_csv.each{|line|
      uid = line[0]
      hash[uid] = line
    }
    
    uids = open "354-name"
    uids = uids.read
    uids = uids.strip.split("\n")

    uids.each do |uid|
      line = hash[uid]
      if !line.blank?
        csv << line
      else
        csv << [uid,0]
      end
    end
  end
  
  #匹配判断
  
  filename = "354用户信息.csv"
  CSV.open filename,"wb" do |csv|
      uids = open "354-uid"
      uids = uids.read
      uids = uids.strip.split("\n")
      uids = uids.uniq
      task = GetUserTagsTask.new
      csv << WeiboAccount.to_row_title(:full)+["近1条微博时间"]
        uids.each do |uid|
           begin #解决异常
               res = task.stable{task.api.users.show(uid:uid)}
               if !res.blank?
                  account = task.save_weibo_user(res)
               else
                  csv << [uid,"此用户已屏蔽"]
                  next
               end
            rescue Exception=>e
                  csv << [uid,"信息有异常"]
                  next
            end
            if res.status.nil?
              csv << account.to_row(:full) + ["此用户没有发过微博"]
              next
            end
           csv << account.to_row(:full) + [DateTime.parse(res.status.created_at).strftime("%Y-%m-%d %H:%S")]
        end
      rescue Exception=>e
          if e.message =~ /User does not exists!/
            csv << [uid,"此用户不存在"]
            elsif e.message =~ /requests out of/
              debugger
              sleep 2700
            end
        end
  end
  
  #找出监控帐号所有粉丝(可以以关注时间为条件进行筛选)
  
  filename = "粉丝.csv"
  CSV.open filename,"wb" do |csv|
    csv << %w{UID}
    wurs = WeiboUserRelation.where("uid = ?",2295615873)
    wurs.each do |wur|
      uid = wur.by_uid
      csv << [uid]
    end
  end
  
   
   #指定用户的近100条微薄
   filename = "354-uid-200条微薄.csv"
   CSV.open filename,"wb" do |csv|
   task = GetUserTagsTask.new
    csv << %w{UID 互动数 URL 内容 是否原创}
    uids = open "354-uid"
    uids = uids.read
    uids = uids.strip.split("\n")
    uids = uids.uniq
    uids.each do |uid|
      uid = uid.strip
        res = task.stable{task.api.statuses.user_timeline(uid:uid,count:200)}
        res['statuses'].each{|w|
          url = "http://weibo.com/#{uid}/#{WeiboMidUtil.mid_to_str(w.id.to_s)}"
          post_at = Time.parse(w.created_at).strftime("%Y-%m-%d %H:%M")
          scount = w.reposts_count + w.comments_count
          origin = !w.retweeted_status
          csv << [w.user.screen_name,scount,url,w.text,origin]
        }
    end
  end
  #前200微薄的互动内容
  #找到非原创微薄的原创用户
  filename = "原创用户.csv"
  CSV.open filename,"wb" do |csv|
    csv << %w{URL uid}
    task = GetUserTagsTask.new
    urls = open "urls"
    urls = urls.read
    urls = urls.strip.split("\n")
    urls = urls.uniq
    urls.each do |url|
      weibo_id = WeiboMidUtil.str_to_mid url.split("/").last
      res = task.stable{task.api.statuses.repost_timeline(weibo_id,count:200,page:page)}
      debugger
    end
  end
  
  filename = "微薄的互动内容加多宝.csv"
  CSV.open filename,"wb" do |csv|
     #接口提取 api 通过url 转发 评论的内容 查出这些人说了些什么
    task = GetUserTagsTask.new
    csv << %w{原创人UID uid 内容 无效内容 互动时间 互动微博连接 动作}
      urls = open "urls"
      urls = urls.read
      urls = urls.strip.split("\n")
      urls = urls.uniq
      urls.each do|line|
      url = line.strip
      weibo_id = WeiboMidUtil.str_to_mid URI.parse(url).path.split("/").last# http://weibo.com/1795839430/AhbvtnvrV http://weibo.com/1795839430/AhmhfkBY5
      puts url 
      page = 1
      processing = true
        begin
          begin
            res = task.stable{task.api.statuses.repost_timeline(weibo_id.to_s,count:200,page:page)}#根据weibo_id查转发人信息count  
                           
              if !res.blank?        
                 res.reposts.each do |line| 
                  if line.nil?
                     processing = false
                     break
                  end
                 url = "http://weibo.com/#{line.retweeted_status.user.id}/#{WeiboMidUtil.mid_to_str(line.retweeted_status.id.to_s)}"     
                 fake_content = line.text == "转发微博" || line.text.gsub(/\[[^\]]+\]/,"").blank?
                 csv << [line.user.id,line.text,fake_content, DateTime.parse(line.created_at).strftime("%Y-%m-%d %H:%S"),url,'转发']
                 end
               else
                processing = false
                break
               end         
          rescue SystemExit, Interrupt,IRB::Abort
            raise

          rescue SystemExit, Interrupt,IRB::Abort
            raise

          rescue Exception=>e
            puts e.message
          end
          page+=1
        end while processing == true
       processing == true
       page = 1
        begin
          begin     
            res = task.stable{task.api.comments.show(weibo_id,count:200,page:page)}#根据weibo_id查评论人信息                    
              if !res.comments.blank?  
                 res.comments.each do |line| 
                  
                  if line.nil?
                     processing = false
                     break
                  end
                   url = "http://weibo.com/#{line.status.user.id}/#{WeiboMidUtil.mid_to_str(line.status.id.to_s)}"     
                 fake_content = line.text == "转发微博" || line.text.gsub(/\[[^\]]+\]/,"").blank?
                 csv << [line.user.id,line.text,fake_content, DateTime.parse(line.created_at).strftime("%Y-%m-%d %H:%S"),url,'评论']
                 end
               else
                processing = false
                break
               end                
          rescue SystemExit, Interrupt,IRB::Abort
            raise

           rescue Exception=>e
            puts e.message
           end
           page+=1
        end while processing == true
    end
   end
  
  #用户活跃度
  
  name = "hdq-用户行为.csv" #这些都是基于库里边儿的用户信息的
  filename = "#{name}.csv"
  CSV.open filename,"wb" do |csv|
    task = GetUserTagsTask.new
    csv << %w{昵称 平均转发率 平均评论率 平均转发 平均评论 活跃度 原创占比 日均发帖量 近七天发贴量}
    uids = open "hdq-500"
    uids = uids.read
    uids = uids.strip.split("\n")
    uids.each do |uid|
       begin
       wa = WeiboAccount.find_by_uid(uid)
       if wa != nil
         row = []
         uid = wa.uid
         weiboEvaluates = WeiboUserEvaluate.where("uid = ?",uid).first
         if weiboEvaluates.nil? || weiboEvaluates.origin_rate == -1
            weiboEvaluates= WeiboAccount.find_by_uid(uid).update_evaluates #更新一下用户的活跃度信息
         end
         evaluates =   weiboEvaluates.forward_average + weiboEvaluates.comment_average
         row << name
         row << weiboEvaluates.forward_rate/100.0
         row << weiboEvaluates.forward_rate/100.0
         row << weiboEvaluates.forward_average/100.0
         row << weiboEvaluates.comment_average/100.0
         row << evaluates/100.0
         row << weiboEvaluates.origin_rate
         row << weiboEvaluates.day_posts
         row << weiboEvaluates.day_posts_in_week
         csv << row
         else
         end
          rescue Exception=>e
            if e.message =~ /User does not exists!/ #=~ 用于正则表达式匹配
             csv << [uid,"取不出信息"]
          end
        end
      end
    end
  end
  
  #接口导出用户信息
  
  
  #测试方法的返回值:ruby方法的返回值是表达式计算的最后一个结果
  
  def string_message(str = '')
    return "It's an empty string!" if str.empty?
    return "The string is nonempty."
  end
  
  
  filename = "cb-uid"
  CSV.open filename,"wb" do |csv|
    uids = open "cb-2000"
    uids = uids.read
    uids = uids.strip.split("\n")
    uids = uids.uniq
    index = 0
    uids.each{|uid|
      index += 1
      if index % 4 == 0
        csv << [uid]
      end
    }
  end
  
  #UID	昵称	位置	性别	粉丝	关注	微博	注册时间	认证信息	认证原因	备注	标签	平均转发率	平均评论率	平均转发	平均评论	活跃度	原创占比	日均发帖量	近七天发贴量	关注时间	最后一条微薄时间
  #转换最后一条微薄时间
  filename = "转换日期2.csv"
  CSV.open filename,"wb" do |csv|
    csv << %w{UID 昵称	 位置 性别 粉丝 关注 微博	 注册时间 认证信息 认证原因 备注 标签 平均转发率 平均评论率 平均转发 平均评论 活跃度	原创占比 日均发帖量 近七天发贴量 关注时间 最后一条微薄时间 距离现在天数}
    old_csv = CSV.open "商用频道粉丝信息.csv"
    old_csv.each{|line|
      row = []
      if line[21] == "此用户没有发过微博" |  | line[21] == "此用户已被屏蔽"
        csv << line
        else
          if line[1] == "此用户不存在"
            csv << [line[0],"此用户已屏蔽"]
            else
              follow_time = line[20]
              follow_time =DateTime.strptime(follow_time,'%m/%d/%Y %H:%M %P').strftime('%Y-%m-%d %H:%M:%S').to_s
              a = follow_time.first.replace("2")
              follow_time = "2" + follow_time[1,follow_time.length]
              follow_time = Date.parse(follow_time)
              
              #转换最后一条微薄时间
              time = line[21]
              time =DateTime.strptime(time,'%m/%d/%Y %H:%M %P').strftime('%Y-%m-%d %H:%M:%S').to_s
              a = time.first.replace("2")
              time = "2" + time[1,time.length]
              time = Date.parse(time)
              now_time = Date.parse(Time.now.strftime("%Y-%m-%d %H:%S"))
              day = (now_time-time).to_i
              csv << [line[0],line[1],line[2],line[3],line[4],line[5],line[6],line[7],line[8],line[9],line[10],line[11],line[12],line[13],line[14],line[15],line[16],line[17],line[18],follow_time,time,day]
          end
      end
    }
  end
  
  #筛选张桢微薄关键词统计完之后再去重效果一样
  
  filename = "初次筛选.csv"
  CSV.open filename,"wb" do |csv|
    
    old_csv = CSV.open "何阳单个词1.csv"
    
    keywords = ['车','骑','开','维修','驾','辆']
    
    old_csv.each{|line|
      if line[0] != "UID"
        content = line[14]
        keywords.each{
          if !content.include?(keywords[5])
            csv << line
          end
        }
      end
    }
  end
  
  #主要针对去重
  filename = "最红筛选.csv"
  CSV.open filename,"wb" do |csv|
    uids = open "uids"
    uids = uids.read
    uids = uids.strip.split("\n")
    uids = uniq
    uids.each do |uid|
      csv << [uid]
    end
  end
  
  #匹配
  
  #互动人信息
    filename = "小美互动人信息.csv"
    CSV.open filename,"wb" do |csv|
      task = GetUserTagsTask.new
      csv << WeiboAccount.to_row_title(:full)
      uniq_uids = []
      @all_interactive = []
      urls = open "urls"
      urls = urls.read
      urls = urls.strip.split("\n")
      urls.each do|line|
          url = line
          weibo_id = WeiboMidUtil.str_to_mid url.split("/").last#http://weibo.com/1902520272/AdgAY5a54  http://weibo.com/2637370927/AdYvTsFCh
    #http://weibo.com/2803301701/AiivFxLc4
          puts url
          forward = []
          comment = []
          page = 1
          processing = true
            begin
              begin
                res = task.stable{task.api.statuses.repost_timeline(weibo_id,count:200,page:page)}#根据weibo_id查转发人信息count
                  if !res.blank?
                     res.reposts.each do |line|
                       row = []
                      if line.nil?
                         processing = false
                         break
                      end
                      forward << line.user.id

                      if !uniq_uids.include?(line.user.id)
                        uniq_uids << line.user.id 
                        row = WeiboAccount.to_row(line.user)
                        csv << row
                      end
                     end
                   else
                    processing = false
                    break
                   end
              rescue Exception=>e
                next
              end
              page+=1
            end while processing == true

            processing == true
            page = 1
            begin
              begin
                res = task.stable{task.api.comments.show(weibo_id,count:200,page:page)}#根据weibo_id查评论人信息
                  if !res.comments.blank?
                     res.comments.each do |line|

                      if line.nil?
                         processing = false
                         break
                      end
                      comment << line.user.id
                      if !uniq_uids.include?(line.user.id)
                        uniq_uids << line.user.id 
                        row = WeiboAccount.to_row(line.user)
                        csv << row
                      end
                     end
                   else
                    processing = false
                    break
                   end
               rescue Exception=>e
                next
               end
               page+=1
            end while processing == true
          interactive = forward+comment
          @all_interactive += interactive
      end
  end
  
  #修改文件
  
  filename = "aaa"
  CSV.open filename,"wb" do |csv|
    uids = open "uid"
    uids = uids.read
    uids = uids.strip.split("\n")
    uids = uids.uniq
    uids.each{|uid|
      csv<<[uid]
    }
  end
  
  filename = "互动人信息2.csv"
  CSV.open filename,"wb" do |csv|
    old_csv = CSV.open "温碧泉互动人信息.csv"
  end
  
  #某个时间段内新增粉丝数
  #新增粉丝列表2637370927,2637370247
  #取出所有粉丝uid
  filename = "xph-new-fans"
  CSV.open filename,"wb" do |csv|
    fans = WeiboUserRelation.where("uid = ? and follow_time between ? and ?",2637370247,"2015-06-08","2015-06-15").count
    fans.each{|nf|
      csv << [nf.by_uid]
    }
  end
  
  #两个帐号@数
  filename = "@xph.csv"
  CSV.open filename,"wb" do |csv|
    csv << %w{Time 发布数量}
    old_csv = CSV.open "xph.csv"
    old_csv.each{|line|
      content = line[0]
      if content.include?("@英特尔芯品汇")
        csv << [line]
      end
    }
  end
  
  #神级统计(张桢关键词统计)
  
  filename = "神级统计.csv"
  CSV.open filename,"wb" do |csv|
    status = {}
    csv << %w{日期 数量}
    num = 0
    urls = open 'names'
    urls = urls.read
    urls = urls.strip.split("\n")
    urls.each do |url|
      status[url] = 0
    end
     old_csv = CSV.open 'haha.csv'
    
      old_csv.each do |line|
        url = line[0]
        next if url.nil?
          if status[url].blank?
            status[url] = 0
          end
            status[url] += line[1].to_i
      end
     status.each do |line|
        csv << line
     end
  end
  
  #计算
  
  filename = "占比.csv"
  CSV.open filename,"wb" do |csv|
    csv << %w{昵称 平均数}
    old_csv = CSV.open "all-匹配.csv"
    num = 0
    old_csv.each{|line|
      if line[2].to_i == 0
        csv << [line[0],0]
      else
        num = (line[2].to_i/line[1].to_f).round(2)
        csv << [line[0],num]
      end
    }
  end
  
  filename = "3.csv"
  CSV.open filename,"wb" do |csv|
    status = {}
    csv << %w{日期 数量}
    num = 0
    keywords = open "keywords"
    keywords = keywords.read
    keywords = keywords.strip.split("\n")
    keywords = keywords.uniq
    
    urls = open '3-names'
    urls = urls.read
    urls = urls.strip.split("\n")
    urls = urls.uniq
    
    urls.each do |url|
      status[url] = 0
    end
     old_csv = CSV.open '1000微薄列表-3.csv'
    
      old_csv.each do |line|
        url = line[0]
        next if url.nil? 
          if status[url].blank?
            status[url] = 0
            end
          keywords.each do |word|
            if line[1].include?(word)
              status[url] += 1
            end
          end
      end
     status.each do |line|
        csv << line
     end
  end
  
  hash = {}
  filename = "intel-pipei-5.csv"
  CSV.open filename,"wb" do |csv|
    old_csv = CSV.open 'intel-互动-5.csv'
    
    old_csv.each{|line|
      uid = line[0]
      hash[uid] = line
    }
    
    uids = open "uids"
    uids = uids.read
    uids = uids.strip.split("\n")
    uids.each do |uid|  
      line = hash[uid]
      if !line.blank?
        csv << line
        else
          csv << [uid,0]
      end
    end
  end
  
  filename = "time2.csv"
  CSV.open filename,"wb" do |csv|
    old_csv = CSV.open "time.csv"
    old_csv.each do |line|
      time1 = line[0]
      time1 = time1[0,10]
      csv << [time1]
    end
  end
  
  filename = "time3.csv"
  CSV.open filename,"wb" do |csv|
    old_csv = CSV.open "time.csv"
    old_csv.each do |line|
      time1 = line[1]
      if time1.blank?
        csv << [nil]
        else
        time1 = time1[0,10]
        csv << [time1]
      end
    end
  end
  
  def get_num
    
    num = 0
    uids_all = open "all-uids"
    uids_all = uids_all.read
    uids_all = uids_all.strip.split("\n")
    #uids_all = uids_all.uniq
    
    uids = open "351-uid"
    uids = uids.read
    uids = uids.strip.split("\n")

    uids_all.each do |uid|
      if uids.include?(uid)
        num += 1
      end
    end
    puts num
  end
  
  #过滤掉粉丝数小于1000的用户
  name = "INTEL"
  filename = "#{name}信息2.csv"
  CSV.open filename,"wb" do |csv| 
    old_csv = CSV.open "INTEL信息.csv"
    old_csv.each do |line|
      if line[5].to_i > 500
        csv << line
      end
    end
  end
  
  api  = WeixinApi.new :zhongzhi
 => #<WeixinApi:0x000000097a87b8 @site=:zhongzhi, @config={:account=>"ciicbj", :appid=>"wxbe03db7ddbe92f67", :secret=>"d31fe502f6478e1575f13687440f77f2"}>
1.9.3p448 :012 > token = api.get_token
Weixin Token reloading...
 => "c7Exvsxbid43Dpq7GJAG4I9PGUecfrsl383GYY9lyL8O3bNQeyvRVwPYjLuWs3Wy2fDzXoe6siBljLoxbHwrzycn_QRbehYX2nSsbr6AmmQ"
 
 
  #操作大文件 把含关键词的微薄找到
  filename = "关键词微薄统计true.csv"
  CSV.open filename,"wb" do |csv|
    old_csv = CSV.open "微薄列表最后补充.csv"
    
    keywords = open "keywords"
    keywords = keywords.read
    keywords = keywords.strip.split("\n")
    
    old_csv.each do |line|
      if line[7] == "true"
        csv << line
      end
    end
  end
  
  #计算时长
  filename = "天数.csv"
  CSV.open filename,"wb" do |csv|
    csv << %w{UID 天数}
    day = 0
    old_csv = CSV.open "236帐号.csv"
    old_csv = old_csv.read
    old_csv.each do |line|
      now_time = Date.parse(Time.now.strftime("%Y-%m-%d %H:%S"))
      if !line[3].blank?
        time = line[3].to_date
        day = (now_time-time).to_i
        csv << [line[0],day]
      else
        csv << [line[0],nil]
      end
    end
  end
