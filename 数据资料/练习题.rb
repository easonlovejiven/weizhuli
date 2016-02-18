    #1,用ROR查询uid=2637370927，WeiboAccount里面这些属性，(UID 昵称 位置 性别 粉丝 关注 微博 注册时间 认证信息 认证原因 )(用csv文件的格式给显示出来)
  #(1)
  def self.getProperty(uid)
  @uid = uid
  records = %w{UID 昵称 位置 性别 粉丝 关注 微博 注册时间 认证信息 认证原因 }
    records = WeiboAccount.by_id <<-EOF 
      select * from weibo_accounts where uid = #{@uid}
    EOF
    end
  end

  #封装一个方法用于求出1加到n的和
  a = [1,2,3,4,5,6,7,8,9,10]
  a.each do |num|
    if (num.to_f/3).to_s.length == 3
      puts num
    end
  end

  class SUM
    def self.getSum(n)
      (1..n).inject do |sum,i|
        1*sum+i
      end
    end
  end
  
  上联:为系统而生,为框架而死,为debug奋斗一辈子。下联:吃符号的亏,上大小写的当,最后死在需求上!
  
  #判断一个数组当中是否包含另一个数组的元素(匹配一些帐号是否在另外的一些帐号当中)
  #path是否有元素在path1里边儿
  filename = "数组元素是否存在是否存在.csv"
  CSV.open filename,"wb" do |csv|
  array1 = ["a","b","c"]
  array2 = ["a","b","c","d","e"]
    keywords = []
    csv << %w{元素 新老}
    array1.each do |line|
      keywords << line.strip
    end 
    array2.each do |line|
      isinclude = keywords.include?(line.strip) ? '有' : '没有'
      csv << [line,isinclude]
    end
  end
  

  #查询中国的最近50条微博的转发数和评论数(并得到名称)(有问题:得到每条微博的转发数和评论数的各自的sum)

  filename = 'china.csv'
  CSV.open filename,"wb" do |csv|
  csv << %w{URL 转发 评论}
  f_sum = 0 #转发的总数
  c_sum = 0 #评论的总数
  uid = 2637370927
  weibos = WeiboDetail.where("uid = ?",uid).order("post_at desc").limit(50)
    weibos.each do |weibo|
      url = "http://weibo.com/"+uid.to_s+"/"+WeiboMidUtil.mid_to_str(weibo.weibo_id.to_s)
      f_num = WeiboForward.where("weibo_id = ?",weibo.weibo_id).count
      c_num = WeiboComment.where("weibo_id = ?",weibo.weibo_id).count
      csv << [url,f_num,f_num]
    end
  end
  #查询(8.9-8.12)这两天的听众人数各有多少(有问题)某个主号的粉丝数量

  #我想要一下上周（8.12-8.18）英特尔中国: 2637370927,、美丽说: 2183473425 的参与互动的总人数
  def get_interact_count(uid,begin_time,end_time)
    array = []
    forwards = WeiboForward.where("uid = ? and forward_at between ? and ?",uid,begin_time,end_time)
    comments = WeiboComment.where("uid = ? and comment_at between ? and ?",uid,begin_time,end_time)
    forwards.each do|forward|
      array << forward.forward_uid
    end
    comments.each do|comment|
      array << comment.comment_uid
    end
    puts array.uniq.size
  end
  
   #调取日期： 8月9日 & 8月10日 这个主号两天的听众数各是多少
   def get_follows_count
    follows = []
    follow_counts = WeiboAccount.where("updated_at between ? and ?",'2014-08-08','2014-08-09')
    follow_counts.each do |follow|
      follows << follow.bi_followers_count
    end
   end

  #每近50条微博的平均互动数（转发+评论） 指定主号的近50条微博的平均互动数
  def get_cr_avg_count(uid)
    comments = []
    reposts = []
    sum = 0
    avg = 0
    array = WeiboDetail.where("uid = ?",uid).order('updated_at desc').limit(50)
    array.each do |detail|
      sum += detail.comments_count+detail.reposts_count
    end
    avg = sum/50
  end
  #7月1号和7月31号的总粉丝数的总粉丝数
  def get_sum_follow(start_time,end_time)
    follows = WeiboAccount.where("updated_at between ? and ?",start_time,end_time)
    follows.each do |follow|
      sum += follow.followers_count
    end
      sum
  end
  #查询特定帐号的粉丝总数
  def get_follow_count_by_uid(uid)
    sum = 0
    arrays = WeiboAccount.where("uid = ?",uid)
    arrays.each do |array|
      sum = array.followers_count
    end
      sum
  end
  #调取日期： 8月9日(1522843) & 8月10日(62672) 两天的听众数(总粉丝数)各是多少(每次调用方法时传递两个日期参数然后得到总粉丝数量)beautiful
  def get_follows_by_date(start_time,end_time)
    sum = 0
    uids = []#用来存放WeiboUserRelation表当中的数据
    follows = []#用来存放WeiboRelation表当中的数据
    uids = WeiboUserRelation.where("follow_time between ? and ?",start_time,end_time)
    uids.each do |u|
      follows = WeiboAccount.where("uid = ?",u.uid)
    end    
    follows.each do |follow|
      sum += follow.followers_count
   end
    sum
  end
  #查询出没有关注数的uid(这个方法数据量太大不能运行)
  def get_not_friends_count
    #用来存放没有关注数的微博信息
    friends = []
    uids = []    
    friends = WeiboAccount.where("friends_count = ?",0).limit(100)
    friends.each do |f|
      uids << f.uid
    end
    uids
    uids.size
  end
  
  # (32014-08-23-----2014-08-24)俩个时间断内的新增粉丝数(22727410578)
  # 29757641079(2014-8-24,2014-08-25)
  def get_newFans_by_date(begindate,endate)
    sum = 0
    wurs = [] #存放这个时间断内的所有记录(这个是为了得到这些记录的uid)
    fans = [] #存放这个时间段内的每条记录
    wurs= WeiboUserRelation.where("created_at between ? and ?",begindate,endate)
    wurs.each do |wur|
      fans = WeiboAccount.where("uid = ?",wur.uid)
      fans.each do |f|
        sum += f.followers_count
      end
    end 
    puts sum
  end
  

  #得到腾讯微博的前20条openid
  def get_openid
    tqqs = TqqAccount.limit(20)
    openids = []
    tqqs.each do |tqq|
     openids = tqq.openid
    end
    puts openids 
  end 

  #提取腾讯微博列表(server/weibo-marketing/app/models/tqq_weibo_detail)

  filename = "ts.csv"
  CSV.open filename,"wb" do |csv|
  csv << %w{微博内容 文章 转发数量 评论数量 微博地址 来源 类型 起源}
  tqqweibos = TqqWeiboDetail.where("openid = '0B6A468C0642625453023BFB0D1B8570' and updated_at between ? and ?",'2014-08-01','2014-08-27')
  tqqweibos.each do |tw|
    #封装了一个to_row方法
    csv << tw.to_row
   end
  end

  #
  http://weibo.com/2637370927/Bb6n90bcq
  http://weibo.com/2637370927/BaWfrdYBi
  http://weibo.com/2637370927/BaOnVErrc
  http://weibo.com/2637370927/BaEN75b2S
  http://weibo.com/2637370927/BavV5vHtw

  http://weibo.com/2637370927/BiovQwp1V
  http://weibo.com/2637370927/BkdHV9ksh
  http://weibo.com/2637370927/Bk4buq2Hr
  http://weibo.com/2637370927/BjUNLfmjH
  http://weibo.com/2637370927/BjsRo1IYW

  http://weibo.com/2637370927/BjiP77uwE
  http://weibo.com/2637370927/Bj9KGF3jB
  http://weibo.com/2637370927/Bj09V3R6R
  http://weibo.com/2637370927/BiQT87jc8
  http://weibo.com/2637370927/Bif1pl6pC

  http://weibo.com/2637370927/Bi5znBXqy
  http://weibo.com/2637370927/BhW4X0AWQ
  http://weibo.com/2637370927/BhMLncOZG
  http://weibo.com/2637370927/BhkqFbJPf
  http://weibo.com/2637370927/BhbHSiDLO

  http://weibo.com/2637370927/Bh1Grmd5R
  http://weibo.com/2637370927/BgTs2x6ka
  http://weibo.com/2637370927/BaOnVErrc
  http://weibo.com/2637370927/B8w2QolVs
  http://weibo.com/2637370927/B8kijvBnw

  http://weibo.com/2637370927/B8CL0bVgl
  http://weibo.com/2637370927/B8Gunrc1J
  http://weibo.com/2637370927/B8Pkwg4G0
  http://weibo.com/2637370927/BbR92DXYm
  http://weibo.com/2637370927/BfmCEBHTW

  http://weibo.com/2637370927/BaWfrdYBi
  http://weibo.com/2637370927/B9Au48hW8
  http://weibo.com/2637370927/BbqaNjdtK
  http://weibo.com/2637370927/BbpGgomCb
  http://weibo.com/2637370927/Bd5gK0EeH

  http://weibo.com/2637370927/Bd2ZB1e2F
  http://weibo.com/2637370927/BgJxe5WwY
  http://weibo.com/2637370927/BgZtDyYbp

  #接口提取微博列表
  description << EOF
  接口导出 根据UID列表 导出微博详情列表
  数据列包括:微博详情信息

  #(1)平均粉丝数;(2)每种认证类型的人数;(3)注册时间小于一年的,一到两年的,两年以上的;(4)平均活跃度;(5)有多少人最近七天发了微博，两条以上的

  (1)def avg
    results = 0
    $fans.each do |fan|
      results += fan.to_i
    end
    puts results/$fans.size => 1764
  end
  (2)
  e.each{|a| hash[a.split(",")[0]]||=0; hash[a.split(",")[0]]+=1}
  {"认证类型"=>1, "达人"=>2190, "未认证"=>6817, "未审核达人"=>704, "名人"=>869, "企业"=>16, "微博女郎"=>8, "网站"=>4, "媒体"=>2, "校园"=>2}
  (3)
   def get_date
    $dates.each do |d,i|
      puts i
     end
    end
  (4)10.887
  (5)
   def get
    no = 0
    two = 0
    $ftl.each do |f|
        if(f.to_i == 0)
          no += 1
        end
        if(f.to_i > 2)
           two += 1
        end 
    end
    puts [no,two]
   end
  没有发的:1417
  两条以上的:5308
  有多少人发的:9140 

  #帖子列表，分为5各部分，分别是自7月1日以来的KOL帖子列表，微博精选推广帖子列表、粉丝头条帖子列表、品牌速度帖子列表，原创未推广帖子列表。请分别跑一下以下数据：
  1、上面5类的帖子列表，包含发布时间，互动次数
  2、5类帖子列表所产生的所有转发、评论的话术(内容)

  3、针对第2条所提取的所有转发、评论话术进行去重分析，分析有多少独立用户贡献；
  4、分别分析这些互动人的属性，地域，性别，认证，微博注册时间段、粉丝数、活跃度、7天内发布微博的次数、以及近2个月内，与英特尔微博互动的次数
  5、分别分析这5部分互动内容的情感分析，按照正面、中面

  负面划分，如果有正面、负面，请提供正面，负面互动内容列表，方便我做展示；
  6、分别分析这5部分互动内容中，有多少条是包含附件中所包含的关键词

   #导出筛选后的uid

   filename = "pinpai_uniq_uid.csv"
    CSV.open filename,"wb" do |csv|
      $pinpai.each do |uid|
    csv << [uid]
    end
   end

  #根据uid抛出评论数,转发数,评论+转发(互动数)

  filename = "jingxuan_comment_forward.csv"
   sum = 0
  CSV.open filename,"wb" do |csv|
   csv << %w{UID 评论数 转发数 互动数}
    $uids.each do |uid| 
    comment_num = WeiboComment.where("uid = ?",2637370927).where("comment_at > ?",'2014-06-01').where("comment_uid = ?",uid).count
    forward_num = WeiboForward.where("uid = ?",2637370927).where("forward_at > ?",'2014-06-01').where("forward_uid = ?",uid).count
    sum = comment_num + forward_num
    csv << [uid,comment_num,forward_num,sum]
    end
  end

  #这是通过name去得到从号的uid,和上边儿多了一个步骤
  filename = "互动次数-7.csv"  #3637213449765372
  CSV.open filename,"wb" do |csv|
  csv << %w{uid 转发 评论 互动数}
  intel = 1747360663#2637370927#2295615873   #2637370247
    path = File.join(Rails.root, "db/name")
    File.open(path,"r").each do |name|
    uid = ReportUtils.names_to_uids([name.strip],true).first
    forwards = WeiboForward.where("uid = ? and forward_uid = ? ",intel,uid ).count
    comments = WeiboComment.where("uid = ? and comment_uid = ? ",intel,uid ).count
    csv << [uid,forwards,comments,forwards+comments]
    end
  end

  require 'rseg'
  Rseg.load

  @bad_words = %w{} #负面评价，情感
  @good_words = %w{} #正面评价，情感
  #双帐号粉丝列表(intel)(路径解决问题)
  filename = "互动人转发评论的内容2.csv"
  CSV.open filename,"wb" do |csv|
    @bad_words = open '/home/rails/Desktop/fumian.rb'#文件的路径
      
    @bad_words = @bad_words.strip.split("\n")

    @good_words = open '/home/rails/Desktop/fumian.rb'#文件的路径
    @good_words = @good_words.read
    @good_words = @good_words.strip.split("\n")
    comment_date = "" #评论日期
    forward_date = "" #转发日期
    comment_text = "" #评论内容
    forward_text = "" #转发内容
    url = ""
    csv << %w{UID 内容 日期 url 类别 eva 是否是有效微博}
    comments = WeiboComment.where("uid = ? and weibo_id = ?",2637370927,3751391170082231)
    forwards = WeiboForward.where("uid = ? and weibo_id = ?",2637370927,3751391170082231)
      comments.each do |comment|
        comment_date = comment.comment_at
        comment_text = MComment.find(comment.comment_id).text
        url = "http://weibo.com/"+(comment.uid).to_s+"/"+WeiboMidUtil.mid_to_str(comment.weibo_id.to_s) #
        uid = comment.comment_uid
        words = Rseg.segment comment_text.to_s #关键词提取
      eva = 0
      @good_words.each{|w|
        good = w.strip
        if words.include?(good)
          eva = 1
          break;
        end
      }
      eva == 0 && @bad_words.each{|w|
        bad = w.strip
        if words.include?(bad)
          eva = -1
          break;
        end
      }
      fake_content = !comment_text == "转发微博" || !comment_text.gsub(/\[[^\]]+\]/,"").blank?
        comment_text.blank? ? csv << [uid,nil,comment_date,url,'评论',eva,fake_content] : csv << [uid,comment_text,comment_date,url,'评论',eva,fake_content]
      end
      forwards.each do |forward|
        forward_date = forward.forward_at
        forward_text = MForward.find(forward.forward_id).text
        url = "http://weibo.com/"+(forward.uid).to_s+"/"+WeiboMidUtil.mid_to_str(forward.weibo_id.to_s)
        uid = forward.forward_uid
         words = Rseg.segment forward_text.to_s #关键词提取
      eva = 0
      @good_words.each{|w|
        good = w.strip
        if words.include?(good)
          eva = 1
          break;
        end
      }
      eva == 0 && @bad_words.each{|w|
        bad = w.strip
        if words.include?(bad)
          eva = -1
          break;
        end
      }
      fake_content = !forward_text == "转发微博" || !forward_text.gsub(/\[[^\]]+\]/,"").blank?
        forward_text.blank? ? csv << [uid,nil,forward_date,url,'转发',eva,fake_content] : csv << [uid,forward_text,forward_date,url,'转发',eva,fake_content]
      end
  end

  #将一个csv文件写入另一个csv文件里边儿
  filename = "new_xph_fans_list.csv"
  CSV.open filename,"wb" do |csv|
    old_csv = CSV.open '/home/rails/Desktop/xph_fans_list.csv'
    old_csv.each do |old|
      csv << [old]
    end
  end  
  
  #eva(内容正负面影响)
  #fake_content(此微博是否是有效内容)

  require 'rseg'
  Rseg.load

  @bad_words = %w{} #负面评价，情感
  @good_words = %w{} #正面评价，情感

  filename = "new_zhongguo.csv"
  CSV.open filename,"wb" do |csv|
    csv << %w{UID 内容 日期 url 类别 eva 是否是有效微博}
    
    @bad_words = open '/home/rails/Desktop/fumian.rb'#文件的路径
    @bad_words = @bad_words.read
    @bad_words = @bad_words.strip.split("\n")

    @good_words = open '/home/rails/Desktop/fumian.rb'#文件的路径
    @good_words = @good_words.read
    @good_words = @good_words.strip.split("\n")

    old_csv = CSV.open '/home/rails/server/weibo-marketing/互动人转发评论的内容.csv'#(这个csv文件是没有对内容正负面影响进行统计的csv文件)
    lines = old_csv.read
    lines.each do |line|

      #重点可以这样提数据

      uid = line[0]
      text = line[1]
      date_time = line[2]
      url = line[3]
      type = line[4]

      words = Rseg.segment text.to_s #关键词提取
      eva = 0
      @good_words.each{|w|
        good = w.strip
        if words.include?(good)
          eva = 1
          break;
        end
      }
      eva == 0 && @bad_words.each{|w|
        bad = w.strip
        if words.include?(bad)
          eva = -1
          break;
        end
      }
      fake_content = !text == "转发微博" || !text.gsub(/\[[^\]]+\]/,"").blank?
      if(uid="UID" && text="内容" && date_time="日期" && url="url" && type="类别" && eva="eva" && fake_content="是否是有效微博")
        csv << [uid,text,date_time,url,type,eva,fake_content]
      end 
    end
  end

  #查看有( 回复@英特尔中国(芯品汇) )的内容（重点分页）
  filename = "xinpinhui.csv"
  CSV.open filename,"wb" do |csv|
    csv << %w{内容}
    page = 1
    while true
      comments = WeiboComment.where("uid = ?",2637370247).where("comment_at > ?",'2014-07-01').paginate(per_page:1000, page:page)
      break if comments.blank?
      comments.each do |comment|
        mc = MComment.find(comment.comment_id)
        if !mc.blank? #如果不等于空的话(这块儿做了个非空的判断)
          content = mc.text
          if content.include?("回复@英特尔芯品汇")
            csv << [content]
          end
        end
       end
      page+=1
     end
    end

  #(转发的微博用户的uid和转发这条微博的人的url,以及转发的日期)只要转发的数据  注意:这个url是转发人的uid

  filename = "new_intel_fans_list.csv"
  CSV.open filename,"wb" do |csv|
    forward_date = "" #转发日期
    url = ""
    csv << %w{UID url 日期}
    @uids.each do |uid|
    forwards = WeiboForward.where("uid = ?",2637370927).where("forward_at > ?",'2014-07-01').where("forward_uid = ?",uid).all
      forwards.each do |forward|
        forward_date = forward.forward_at
        url = "http://weibo.com/"+(forward.forward_uid).to_s+"/"+WeiboMidUtil.mid_to_str(forward.forward_id.to_s)
        csv << [uid,url,forward_date]
      end
    end
  end
  
  #重点从文件读一些uid,看看这些uid是否关注一个主号

  filename  = "是否关注主号.csv"
  CSV.open(filename,"wb") do|csv|
    csv << %w{uid 是否是英特尔商用频道粉丝 }
    #主号
    intel = '2637370927'
    path = File.join(Rails.root,"db/uid1") #这个意思是从db/uid这个文件当中拿到这些uid
     #这个路径默认是在server/weibo-marketing下的
    File.open(path,"r").each do|uid|
     uid << uid.strip
     fans = WeiboUserRelation.where("uid = ? and by_uid = ?",intel,uid)
     isfans = fans.blank? ? '不是' : '是'#follow_time关注这个主号的时间 判断这个uid是否是intel的fans
     csv << [uid,isfans]
    end
  end

  #根据name提取粉丝信息

  filename  = "根据name提取粉丝信息.csv"
  CSV.open(filename,"wb") do|csv|
        csv << %w{name uid 粉丝数 }
  path = File.join(Rails.root,"db/name3")
    File.open(path,"r").each do|name|
     name = name.strip
     fans = WeiboAccount.where("screen_name = ?",name).first
     csv << [name,fans.uid,fans.friends_count]
    end
  end
  
  #根据name读取与英特尔中国互动次数  互动微博地址 金融街购物中心微博:1924531943(小文)
  
  @intel = 1924531943 #金融街购物中心微博
  @url = []
  CSV.open "d根据name读取与英特尔中国互动次数  互动微博地址.csv", "wb" do |csv|
    csv << %w{UID 姓名  互动次数	 互动微博地址 }
    path = File.join(Rails.root,"db/name3")
    names = [] #用于存取读取的name
    File.open(path,"r").each do|name|
    name =  name.strip
    uid = ReportUtils.names_to_uids([name]) #根据name得到uids
    forwards = WeiboForward.where("uid = ? and forward_uid = ? ",@intel,uid[0]) #转发数
    comments = WeiboComment.where("uid = ? and comment_uid = ? ",@intel,uid[0]) #评论数
    if !forwards.nil? #如果转发数量不为空的话,循环遍历根据weibo_id取出一条微博记录,并得到这条微博的url
     forwards.each do |forward|
        weibo = WeiboDetail.where("weibo_id = ?",forward.weibo_id).first
        @url << weibo.url
     end
    end
    if !comments.nil?
     comments.each do|comment|
        weibo = WeiboDetail.where("weibo_id = ?",comment.weibo_id).first
        @url << weibo.url
     end
    end
   forward_count = WeiboForward.where("uid = ? and forward_uid = ? ",@intel,uid[0],).count
   comment_count = WeiboComment.where("uid = ? and comment_uid = ? ",@intel,uid[0]).count
   csv << [uid[0], name,forward_count+comment_count,@url.uniq*","]
   end
  end
  
  #从接口提取 一个人的粉丝（存库里）
  
  #在一些帐号中找出哪些帐号被屏蔽(注:只导出被屏蔽的帐号)
  
  task = GetUserTagsTask.new
  filename = "被屏蔽的帐号.csv"
  path = File.join(Rails.root, "db/uids")
  CSV.open filename,"wb" do |csv|
   csv << %w{uid}
   number = 1
   File.open(path,"r").each do|uid|
      uid = uid.strip
      begin
      #stable这个方法是当用户要去连接接口的时候，可能会出现各种状况的异常，其主要作用是对可能出现的异常进行处理
      res = task.stable{task.api.users.show(uid)}
      rescue Exception =>e
        if e.message =~ /User does not exists!/ #=~ 用于正则表达式匹配
           csv << [uid]
        end
      end
      number+=1
   end
  end
  

  #7,8月份分开抛(uid 内容 互动时间 原微博url 类别 有效性 正负面 每页1000条数据) 英特尔中国和芯品汇的
  #用于内容正负面判断的
  require 'rseg'
  Rseg.load

  @bad_words = %w{} #负面评价，情感
  @good_words = %w{} #正面评价，情感  

  filename = "intel.csv"
  CSV.open filename,"wb" do |csv|
    csv << %w{uid 内容 互动时间 原微博url 类别 有效性 正负面}
    @bad_words = open '/home/rails/Desktop/fumian.rb'#文件的路径
    @bad_words = @bad_words.read
    @bad_words = @bad_words.strip.split("\n")

    @good_words = open '/home/rails/Desktop/zhengmian.rb'#文件的路径
    @good_words = @good_words.read
    @good_words = @good_words.strip.split("\n")
    page = 1
    while true
      comments = WeiboComment.where("uid = ? and weibo_id = ?",2637370247,3751391170082231).paginate(per_page:1000, page:page)
      break if comments.blank?
      comments.each do |comment|
        uid = comment.comment_uid
        comment_date = comment.comment_at  
        url = "http://weibo.com/"+(comment.comment_uid).to_s+"/"+WeiboMidUtil.mid_to_str(comment.comment_id.to_s)
        mc = MComment.find(comment.comment_id)
        if !mc.blank? #如果不等于空的话(这块儿做了个非空的判断)
          content = mc.text #内容
          fake_content = !content == "转发微博" || content.gsub(/\[[^\]]+\]/,"").blank? #有效性
          words = Rseg.segment content.to_s #以下是正负面判断
          eva = 0   
          @good_words.each{|w|
            good = w.strip
            if words.include?(good)
              eva = 1
              break;
            end
          }
            eva == 0 && @bad_words.each{|w|
              bad = w.strip
              if words.include?(bad)
                eva = -1
                break;
              end
            }
            csv << [uid,content,comment_date,url,'评论',fake_content,eva]
        end
       end
      page+=1
     end
      page = 1
     while true
      forwards = WeiboForward.where("uid = ? and weibo_id = ?",2637370247,3751391170082231).paginate(per_page:1000, page:page)
      break if forwards.blank?
      forwards.each do |forward|
        uid = forward.forward_uid
        forward_date = forward.forward_at
        url = "http://weibo.com/"+(forward.forward_uid).to_s+"/"+WeiboMidUtil.mid_to_str(forward.forward_id.to_s)
        fc = MForward.find(forward.forward_id)
        if !fc.blank? #如果不等于空的话(这块儿做了个非空的判断)
          content = fc.text
          fake_content = !content == "转发微博" || content.gsub(/\[[^\]]+\]/,"").blank?
          words = Rseg.segment content.to_s #正负面
          eva = 0   
          @good_words.each{|w|
            good = w.strip
            if words.include?(good)
              eva = 1
              break;
            end
          }
            eva == 0 && @bad_words.each{|w|
              bad = w.strip
              if words.include?(bad)
                eva = -1
                break;
              end
            }
            csv << [uid,content,forward_date,url,'评论',fake_content,eva]
        end
       end
      page+=1
     end
    end

  #通过name导出uid
  filename = "names_to_uids.csv"
  CSV.open filename,"wb" do |csv|
  csv << %w{名称 uid}
  path = File.join(Rails.root, "db/name3")
   File.open(path,"r").each do|line|
      name = line.strip
      uid =  WeiboAccount.find_by_screen_name(name,true).uid
      csv << [name,uid]
    end
  end
  
  #根据uid查阅微博用户的活跃度(这个在WeiboUserEvaluate表当中的数据)
  
  filename = "用户活跃度.csv"
  CSV.open filename,"wb" do |csv|
   csv << %w{uid  活跃度}
   path = File.join(Rails.root, "db/uuu.rb")
   File.open(path,"r").each do|line|
   uid = line.strip
   weiboEvaluates = WeiboUserEvaluate.where("uid = ?",uid)
   evaluates = (weiboEvaluates[0].forward_average/100.0 + weiboEvaluates[0].comment_average/100.0)
    csv << [uid,evaluates]   
    end
  end

  #通过uid 接口  查 这个人在一定时间内发 微薄 原创微博数 和转发微博数(注:通过接口读数据)
  filename = "wyz.csv"
    CSV.open(filename,"wb"){|csv|
    csv << %w{uid 原创微博数 转发微博数}
    path = File.join(Rails.root, "db/wuhan.rb")
    #实例化一个对象
    task = GetUserTagsTask.new
  
  #导出活跃度和关注的时间(这个字段在WeiboUserRelation)
  
  filename = "用户活跃度.csv"
  CSV.open filename,"wb" do |csv|
  @uids = open 'uids'#文件的路径
  @uids = @uids.read
  @uids = @uids.strip.split("\n")
   csv << %w{uid 活跃度 关注时间}
    @uids.each do |uid|
      uid = uid.strip
      wurs = WeiboUserRelation.where("uid = ? and by_uid = ?",'2637370927',uid)
      if wurs[0].blank?
        csv << [uid,nil]
      elsif
        @follow_time = wurs[0].follow_time.strftime("%Y-%m-%d %H:%M:%S")
        csv << [uid,@follow_time]
     end
   end
  end

  #关注时间  

  filename = "B粉丝新老判断.csv"
  CSV.open filename,"wb" do |csv|
  csv << %w{uid 关注时间 新老非粉丝}
  @start_time = '2015-01-15'
  @end_time = '2015-01-22'
  @uids = open 'b-uid'#文件的路径
  @uids = @uids.read
  @uids = @uids.strip.split("\n")
    @uids.each do |uid|
      wurs = WeiboUserRelation.where("uid = ? and by_uid = ?",'1687399850',uid)
      @start_time = @start_time.to_date.strftime("%Y-%m-%d %H:%M:%S") #这条微博的时间
      @end_time = @end_time.to_date.strftime("%Y-%m-%d %H:%M:%S") #这条微博的时间
      if wurs[0].blank?
        csv << [uid,nil,'老粉丝']
      else
        @follow_time = wurs[0].follow_time.strftime("%Y-%m-%d %H:%M:%S") #用户关注的时间
        @intel_type = case
        when @follow_time > @end_time && @follow_time < @start_time
          csv << [uid,@follow_time,'老粉丝']
        when @follow_time < @end_time && @follow_time > @start_time
          csv << [uid,@follow_time,'新粉丝']
        end
      end
    end
  end
  
  #根据uid查询关注主号的时间(主号被uids关注的时间:重点)

  name = "shangyong" #传不同的参数(主号的screen_name),去导出不同主号的信息
  folder = "#{name}-data" #这块儿是指不同帐号要放到不同的文件夹下,以避免不同的帐号时修改太多的变量
  Dir.mkdir folder if !Dir.exist? folder #判断文件夹是否存在,如果不存在就创建一个这样的文件夹
  @url = "db/uuu.rb" #读取文件时可以直接传这个参数
  filename = "根据uid查询关注#{folder}的时间.csv"
  @theno = 2295615873
  CSV.open filename,"wb" do |csv|
    csv << %w{uid time}
    path = File.join(Rails.root,@url)
     File.open(path,"r").each do|line|
     by_uid = line.strip
     weibotime = WeiboUserRelation.select('follow_time').where("uid = ? and by_uid = ?",@theno,by_uid)
     csv << [by_uid,weibotime[0].follow_time]
     end
  end
  
  #根据uid 查询 是不是 intel  的 粉丝 金融街：1924531943 商用频道：2295615873   中国： 2637370927 国际：3869439663   
  
  name = "xinpinhui" #传不同的参数(主号的screen_name),去导出不同主号的信息
  folder = "#{name}-data" #这块儿是指不同帐号要放到不同的文件夹下,以避免不同的帐号时修改太多的变量
  Dir.mkdir folder if !Dir.exist? folder #判断文件夹是否存在,如果不存在就创建一个这样的文件夹
  @url = "db/uuu.rb" #读取文件时可以直接传这个参数
  filename = "#{folder}是否是特定主号的粉丝.csv"
  @theno = '2637370247'  
  CSV.open filename,"wb" do |csv|
    csv << %w{uid 粉丝}
    path = File.join(Rails.root,"db/uuu.rb")
    File.open(path,"r").each do |line|
    uid = line.strip
    uids = WeiboUserRelation.select("by_uid").where("uid = ?",2637370927)
      uids.each do |f_uid|
        founs_on = uid==f_uid ? "是" : "否"
        csv << [uid,founs_on]
      end
    end
  end

  #根据uid 查询 是否关注的是主号的粉丝(这些uid是否关注这个主号)

  name = "xinpinhui" #传不同的参数(主号的screen_name),去导出不同主号的信息
  folder = "#{name}-data" #这块儿是指不同帐号要放到不同的文件夹下,以避免不同的帐号时修改太多的变量
  Dir.mkdir folder if !Dir.exist? folder #判断文件夹是否存在,如果不存在就创建一个这样的文件夹
  @url = "db/uuu.rb" #读取文件时可以直接传这个参数
  filename = "#{folder}数据B1部分非活动贴互动人信息3.csv"
  @theno = '2637370247'
  task = GetUserTagsTask.new
  CSV.open filename,"wb" do |csv|
    csv << %w{uid 是否关注主号}
  path = File.join(Rails.root,@url)
    File.open(path,"r").each do|line|
    uid = line.strip
    begin
    res = task.api.friendships.show(source_id:uid,target_id:@theno)
    rescue Exception=>e
     puts e.message
     csv << [uid]
     next
    end
    csv << [uid,res.source.following ? "是":"否"]
    end
  end

  #导出主号的粉丝(uid)列表  注意:要灵活运用begin .. end它主要用来扩大变量的范围的;如果要是导不同的主号的话,可以直接该文件名称

  name = "xinpinhui" #传不同的参数(主号的screen_name),去导出不同主号的信息
  folder = "#{name}-data" #这块儿是指不同帐号要放到不同的文件夹下,以避免不同的帐号时修改太多的变量
  Dir.mkdir folder if !Dir.exist? folder #判断文件夹是否存在,如果不存在就创建一个这样的文件夹
  filename = "#{folder}的粉丝(uid)列表.csv" #其参数可以根据screen_name/主号uid
  task = GetUserTagsTask.new
  @uid = 2637370247
  CSV.open filename,"wb" do |csv|
     csv <<  ['uid']#WeiboAccount.to_row_title(:full)
      begin
      friend_ids = task.api.friendships.followers_ids(:uid=>@uid, :count=>2000).ids
      friend_ids.each do|uid|
        csv << [uid]
      end
    end
  end

  #查看身份 
  filename = "uid-身份.csv"
    task = GetUserTagsTask.new
    CSV.open filename,"wb" do |csv|
      csv << %w{uid 身份}
      path = File.join(Rails.root,"db/wuhan-uid.rb")
      File.open(path,"r").each do|line|
        uid = line.strip
        #可以根据sql语法去返回所需要的记录(数组)
        records = WeiboUserAttribute.find_by_sql <<-EOF
           select keyword_id from weibo_user_attributes where uid = #{uid}
          EOF
          #存放的是身份关键词的id然后用id进行查询
         type = {85 => "核心KOL",86 => "降级核心KOL",88 => "全量KOL",90 => "全网KOL",}
         if records.size==0  #csv文件处理没有的数据可以直接不写
            csv << [uid]
            next
         end
         row = []
         records.each do |line|
            keyword = type[line.keyword_id] #如果查询的
            if !keyword.nil? 
               row << keyword
            end
         end
         csv << [uid,row*',']
      end
    end

  #匹配一个帐号是否在 一些帐号中（匹配）接口提取
  
  filename = "匹配2.csv"
  CSV.open filename,"wb" do |csv|
      csv << ['uid','新老']
      path = File.join(Rails.root,"db/uid1.rb")
      path1 = File.join(Rails.root,"db/wuhan-uid.rb")
      keywords = []
      File.open(path,"r").each do|line|
        keywords << line.strip
      end
      File.open(path1,"r").each do|line|
        isinclude = keywords.include?(line.strip) ? '有' : '没有'
        csv << [line,isinclude]
      end
  end
  
  filename = "匹配1.csv"
  CSV.open filename,"wb" do |csv|
    csv << %w{UID 新老}
    path = File.join(Rails.root,"db/uid1")
    path1 = File.join(Rails.root,"db/wuhan-uid.rb")
    keywords = []
    File.open(path,"r").each do |line|
      keywords << line.strip
    end 
    File.open(path1,"r").each do |line|
      isinclude = keywords.include?(line.strip) ? '有' : '没有'
      csv << [line.uid,isinclude]
    end
  end

  #根据uid查这个微博用户的注册时间和注册年份
  
  task = GetUserTagsTask.new
  filename = "created_at.csv"
  CSV.open filename,"wb" do |csv|
    csv << %w{UID 注册时间 注册年份}
    path = File.join(Rails.root,"db/wuhan-uid.rb")
      row = []
      File.open(path,"r").each do |line|
        uid = line.strip
        weibo = task.load_weibo_user(uid) #这里需要异常处理
      csv << [uid,weibo.created_at,weibo.created_at.year]
    end
  end

  #根据url查询这条微博的类型
  
   filename = "微博类型.csv"
   path = File.join(Rails.root,"db/wuhan-url.rb")
   CSV.open filename,"wb" do |csv|
      csv <<['url','类型']
      File.open(path,"r").each do |url|
        weibo_id = WeiboMidUtil.str_to_mid URI.parse(url.strip).path.split("/").last
        record=WeiboDetail.find_by_weibo_id(weibo_id.to_i)
        type = case
            when record.image? && record.video?
              "image + video"
            when record.image?
              "image"
            when record.video?
              "video"
            when record.music?
              "music"
            when record.vote?
              "vote"
            else
              "text"
          end
          csv << [url,type]
      end
  end

  #uid去重 互动

  filename = "uid去重1.csv"
  CSV.open filename,"wb" do |csv|
      csv << ['uid'] 
      path = File.join(Rails.root,"db/uid3") 
      @compare_uids = {}
      File.open(path,"r").each do|line|
         uid = line.strip
         @compare_uids[uid] ||=  1
         !@compare_uids[uid].nil? if @compare_uids[uid] +=1
      end
       @compare_uids.keys.each do |line|
         uid = line
         csv << [uid]
       end
  end
    
  #思路:关注http://weibo.com/2637370927/BlyUZ0loj这条微博的用户并取出uid,然后再根据日期判断是否是新老非粉丝
  #注:有些并不是粉丝,但是可以评论或者转发这条微博
  #在这些uid当中可能有些uid被新浪屏蔽了

  filename = "关注时间.csv"
  CSV.open filename,"wb" do |csv|
  csv << %w{uid 关注时间 新老非粉丝}
  @intel_time = '2014-09-05 10:40:00'
  @uids = open 'uids'#文件的路径
  @uids = @uids.read
  @uids = @uids.strip.split("\n")
    @uids.each do |uid|
      wurs = WeiboUserRelation.where("uid = ? and by_uid = ?",'2637370927',uid)
      @weibo_time = @intel_time.to_date.strftime("%Y-%m-%d %H:%M:%S") #这条微博的时间
      if wurs[0].blank?
        csv << [uid,nil,'非粉丝']
      else
        @follow_time = wurs[0].follow_time.strftime("%Y-%m-%d %H:%M:%S") #用户关注的时间
        @intel_type = case
        when @weibo_time > @follow_time
          csv << [uid,@follow_time,'老粉丝']
        when @weibo_time < @follow_time
          csv << [uid,@follow_time,'新粉丝']
        end
      end
    end
  end 

  #关注时间
  #(1)http://weibo.com/2637370927/BlyUZ0loj 通过这条微博的路径 先求出weibo_id = WeiboMidUtil.str_to_mid URI.parse(url.strip).path.split("/").last
  #(2)然后再通过weibo_id WeiboComment.where("uid = ? and weibo_id = >",2637370927,weibo_id)
  #///WeiboForward.where("uid = ? and weibo_id = >",2637370927,weibo_id) 找出转发和平陆的用户,再去重(有些用户可能即评论有转发) 
  #(3)然后可以根据去重后的uid进行各种操作
  filename = "关注时间2.csv"
  CSV.open filename,"wb" do |csv|
  csv << %w{uid 关注时间}
  @uids = open '/home/rails/Desktop/uniq'#文件的路径
  @uids = @uids.read
  @uids = @uids.strip.split("\n")
    @uids.each do |uid|
      wurs = WeiboUserRelation.where("uid = ? and by_uid = ?",'2637370927',uid)
      wurs.blank? ? csv << [uid,nil] : csv << [uid,wurs[0].follow_time]
    end
  end
  
  #转发 评论 主动AT 次数
  
  filename = "互动AT次数2014.csv"  
  CSV.open filename,"wb" do |csv|
    csv << %w{uid 转发 评论 主动@}
    start_time = '2014-07-01'
    end_time = '2014-09-01'
    intel = 2637370927 #2295615873   #2637370247 3869439663 2637370927,
    path = File.join(Rails.root, "db/uuu.rb")
    File.open(path,"r").each do |uid|
       uid = uid.strip
       comments = WeiboComment.where("uid = ? and comment_uid = ? and comment_at between ?   and ?",intel,uid,start_time,end_time).count
       forwards = WeiboForward.where("uid = ? and forward_uid = ? and forward_at between ?   and ?",intel,uid,start_time,end_time).count
       mention = WeiboMention.where("uid = ? and mention_uid = ? and mention_at between ?   and ?",intel,uid,start_time,end_time).count
       csv << [uid,forwards,comments,mention]
    end
  end

  #英特尔芯品汇 06-12至今的新增有效粉丝信息(:还能获取信息的粉丝信息),然后与附加已有的uid进行合并
  
  #根据name查询这个微博用户的基本信息

  task = GetUserTagsTask.new
  filename = "get_infor_by_name.csv"
  CSV.open filename,"wb" do |csv|
    csv << WeiboAccount.to_row_title(:quality) #如果导出的数据列太多的话可以通过:to_row_title(:quality)的这个方法直接生成这个微博用户的所有列
    path = File.join(Rails.root,"db/name")
    File.open(path,"r").each do |line|
      name = line.strip
      #根据name得到uid
      uids = ReportUtils.names_to_uids([name],true)
      if uids.size == 0
        csv << [name]
        next
      end
      weibo = task.load_weibo_user(uids[0])
      csv << weibo.to_row(:quality)
    end
  end

  #根据uid查询用户基本信息
  
  filename = "基本信息-现在是中国粉丝-2.csv"
  task = GetUserTagsTask.new
  CSV.open filename,"wb" do |csv|
  path = File.join(Rails.root, "db/uid1")
   title = WeiboAccount.to_row_title(:full) #作用同上
   csv << title #等价于 %w{sdf sdf sdf sdf sdf sdf}
  File.open(path,"r").each do|uid|
     uid = uid.strip
      begin
       account = task.load_weibo_user(uid)
       rescue Exception =>e
         if e.message =~
            csv << [uid]
            next
         end
       end
      if account.blank?
          csv << [uid]
          next
      end
      csv << account.to_row(:full) #给一列的数据转换成一行的数据(让它以行的形式显示)
      end
  end

  #这个用户关注这条微博的时间
  
  
  #某个主号的互动人信息(注意日期和时间) 可以动态的传递参数
  
  name = "two-q" #传不同的参数(主号的screen_name),去导出不同主号的信息(注:可以添加用户的筛选条件)
  filename = "#{name}-uid.csv"
  @begin_time = '2014-04-01'
  @end_time = '2014-07-01'
  #@loaction = '北京'
  @uid = 2295615873 #主号uid
  CSV.open filename,"wb" do |csv|
    csv << %w{uid}
      page = 1
      while true
      newfans = WeiboUserInteractionSnapDaily.where("uid = ? and created_at between ? and ?",@uid,@begin_time,@end_time).paginate(per_page:1000, page:page)
      break if newfans.blank?
        newfans.each do |fans|
          w_a = WeiboAccount.find_by_uid(fans.from_uid)
            if !w_a.blank?
             csv << [w_a.uid]
        end
      end
      page += 1 
    end
  end

  #将去重后的uid导成csv文件

    filename = "gaotong-uniq.csv"
    CSV.open filename,"wb" do |csv|
      csv << %w{UID}
      $uids.each do |uid|
        csv << [uid]
      end
    end
  
    #先得到主号的互动人,并且去除重复的uid
    filename = "主号互动人信息.csv" 
    task = GetUserTagsTask.new
    CSV.open(filename,"wb"){|csv|
      csv << %w{ UID 昵称 位置 性别 粉丝 关注 微博 注册时间 认证类型 认证原因 标签}
        #找到中国2014-02-01 到 2014-02-25之间的粉丝信息
        @uids = open '/home/rails/Desktop/chaojiben-uniq'#文件的路径
        @uids = @uids.read
        @uids = @uids.strip.split("\n")
        @uids.each{|uid|
          begin
            a  = task.load_weibo_user(uid)
            rescue Exception=>e
            if e.message =~
              csv << [uid] #得到uid
               next
            end
          end
          #判断如果这条用户记录为空的时候
          next if a.nil? 
          row = a.to_row(:full)
          csv << row
        }
  }
  
  #粉丝(上一个是关注)找出所有uid
  name = "intel中国" #传不同的参数(主号的screen_name),去导出不同主号的信息(注:可以添加用户的筛选条件)
  filename = "#{name}-uid.csv"
  @begin_time = '2014-09-01'
  @end_time = '2014-09-15'
  #@loaction = '北京'
  @uid = 2637370927 #主号uid
  CSV.open filename,"wb" do |csv|
    csv << %w{uid}
      page = 1
      while true
      newfans = WeiboUserRelation.where("uid = ? and follow_time between ? and ?",@uid,@begin_time,@end_time).paginate(per_page:1000, page:page)
      break if newfans.blank?
        newfans.each do |fans|
          w_a = WeiboAccount.find_by_uid(fans.by_uid)
            if !w_a.blank?
             csv << [w_a.uid]
        end
      end
      page += 1 
    end
  end
  
  filename = "intel_comment_forward.csv"
  sum = 0
  CSV.open filename,"wb" do |csv|
   csv << %w{UID 评论数 转发数 互动数}
    @uids = open '/home/rails/Desktop/intel_uid'#文件的路径
    @uids = @uids.read
    @uids = @uids.strip.split("\n")
    @uids.each do |uid| 
      comment_num = WeiboComment.where("uid = ? and comment_at between ? and ?",2637370927,'2014-09-01','2014-09-15').where("comment_uid = ?",uid).count
      forward_num = WeiboForward.where("uid = ? and forward_at between ? and ?",2637370927,'2014-09-01','2014-09-15').where("forward_uid = ?",uid).count
      sum = comment_num + forward_num
      csv << [uid,comment_num,forward_num,sum]
    end
  end


  #单独找到一些用户的认证类型(所占比例)
  
     英特尔中国 2637370927  8609/38884     0.221(今年的) 未认证的:30275
     AMD中国 1883832215  119342/154864  0.77(全部的)  未认证的:35522; 今年的 834/21671 0.038(今年的) 未认证的:20837
Qualcomm中国 1738056157  60221/261895   0.229(今年的) 未认证的:201674
     戴尔中国 1687053504 12682/79670    0.159(今年的) 未认证的:66988
        联想 2183473425  24617/239775   0.102(今年的) 未认证的:215158


  #(1)
    select count(*) 数量 from weibo_user_relations inner join weibo_accounts on weibo_accounts.uid = weibo_user_relations.by_uid where weibo_user_relations.uid = 1883832215
      and weibo_accounts.verified_type = -1 and weibo_user_relations.follow_time between '2014-01-01' and '2014-09-15';
  #(2)
    select count(*) 数量 from weibo_user_relations where by_uid in(
    select uid from weibo_accounts where verified_type < 0
  ) and uid = 1883832215
  #(3)今年的粉丝比率
    select count(*) 数量 from weibo_user_relations inner join weibo_accounts on weibo_accounts.uid = weibo_user_relations.by_uid where weibo_user_relations.uid = 1883832215
    and weibo_user_relations.follow_time between '2014-01-01' and '2014-09-15'; 


   url = "http://weibo.com/"+(forward.uid).to_s+"/"+WeiboMidUtil.mid_to_str(forward.weibo_id.to_s)
   url = "http://weibo.com/"+uid.to+WeiboMidUtil.mid_to_str

  #导出这个微博主号的所有微博url

  filename = "shangyong-url.csv"
  CSV.open filename,"wb" do |csv|
    csv << %w{url}
    uid = 2637370927
    w_ds = []
      w_ds = WeiboDetail.where("uid = ? and post_at between ? and ?",2637370927,'2014-01-10','2014-07-01')
      w_ds.each do |w_d|  
        url = "http://weibo.com/"+uid.to_s+"/"+WeiboMidUtil.mid_to_str(w_d.weibo_id.to_s)
        csv << [url]
      end
  end

  #根据微博的路径导出这条微博的weibo_id

  filename = "url_by_mid.csv"
  CSV.open filename,"wb" do |csv|
    csv << %w{URL MID}
    @url = open '/home/rails/Desktop/url'#文件的路径
    @url = @url.read
    @url = @url.strip.split("\n")
    @url.each do |url|
      str = url.split("/").last
      weibo_id = WeiboMidUtil.str_to_mid(str)
      csv << [url,weibo_id]
    end
  end

  #有关intel中国的评论或者转发的内容当中有"intel中国"的
  filename = "xph.csv"
  CSV.open filename,"wb" do |csv|
    csv << %w{内容 是否 类别}
    comments = WeiboComment.where("uid = ? and comment_at between ? and ?",2637370247,'2014-09-01','2014-09-15')
    comments.each do |comment|
       mc = MComment.find(comment.comment_id)
       if !mc.blank?
        @content = mc.text #内容
        @content.include?("回复@英特尔芯品汇") ? csv << [@content,'包含','评论'] : csv << [@content,'不包含','评论']
       end
    end

    forwards = WeiboForward.where("uid = ? and forward_at between ? and ?",2637370247,'2014-09-01','2014-09-15')
    forwards.each do |forward|
       fc = MForward.find(forward.forward_id)
       if !fc.blank?
        @content = fc.text #内容
        @content.include?("回复@英特尔芯品汇") ? csv << [@content,'包含','转发'] : csv << [@content,'不包含','转发']
       end
    end
  end

  #主号的所有粉丝uid

  filename = "粉丝.csv"
  CSV.open filename,"wb" do |csv|
    csv << %w{UID}
    fans = WeiboUserRelation.where("uid = ?",2637370927)
    fans.each do |fan|
      csv << [fan.by_uid]
    end
  end
    #去除数组当中的重复元素
   filename = "haha2"
   CSV.open filename,"wb" do |csv|
    @uids = open 'tokens'#文件的路径
    @uids = @uids.read
    @uids = @uids.strip.split("\n")
    @uids = @uids.uniq
    @uids.each do |uid|
      csv << [uid]
    end
  end
  
  #根据每条微博的路径找出
  
  def get_person_num(url)
      comment_uids = []
      forward_uids = []
      hudong_uids = []
      @num = 0
      @weibo_id = WeiboMidUtil.str_to_mid(url.split("/").last)
      #评论的uid
      comments = WeiboComment.where("weibo_id = ?",@weibo_id.to_i)
      comments.each do |comment|
        comment_uids << comment.comment_uid
      end
      #转发的uid
      forwards = WeiboForward.where("weibo_id = ?",@weibo_id.to_i)
      forwards.each do |forward|
        forward_uids << forward.forward_uid
      end
      hudong_uids = comment_uids + forward_uids
      #每条微博的互动人数
      @num = hudong_uids.uniq.size
  end

  #搜索关键词统计(有问题) 

  #9.18需求分析(商用频道互动人信息+活跃度+互动次数)
  
  filename = "商用频道上半年.csv"
  CSV.open filename,"wb" do |csv|
    csv << %w{UID 昵称 位置 性别 粉丝 关注 微博 注册时间 认证类型 认证原因 备注 活跃度 互动次数}
    @sex = "" #性别
    @tpye_name = "" #认证类型
    @uids = open '/home/rails/Desktop/sbn-uid'#文件的路径
    @uids = @uids.read
    @uids = @uids.strip.split("\n")
    @uids.each do |uid|
    begin
      weibo_account = WeiboAccount.where("uid = ?",uid)
      we = WeiboUserEvaluate.find_by_uid(uid) #求活跃度
      muser = MUser.find_by_id(uid.to_i) #这块儿要注意了,必须要把uid转换成整形的(求用户备注信息的)

      screen_name = weibo_account[0].screen_name #昵称
      location = weibo_account[0].location #位置
      #weibo_account[0].gender == 0 ? @sex = "女" : @sex = "男"
      @sex = weibo_account[0].human_gender
      followers_count = weibo_account[0].followers_count #粉丝
      friends_count = weibo_account[0].friends_count #关注
      statuses_count = weibo_account[0].statuses_count #微博数量
      created_at = weibo_account[0].created_at.strftime("%Y-%m-%d %H:%M:%S") #用户创建(注册)时间
      verified_type = weibo_account[0].verified_type #认证类型
      #调用认证类型的方法
      @type_name = weibo_account[0].human_verified_type #这块儿怎样将数组转换成文字格式
        @name_str = "" #存放认证类型
        #将认证类型的这个数组循环遍历  
        @type_name.each do |name|
          @name_str += name+","
        end
         @name_str = @name_str[0,@name_str.length-1]
      comment_num = WeiboComment.where("uid = ? and comment_at between ? and ?",2295615873,'2014-01-01','2014-07-01').where("comment_uid = ?",uid).count
      forward_num = WeiboForward.where("uid = ? and forward_at between ? and ?",2295615873,'2014-01-01','2014-07-01').where("forward_uid = ?",uid).count
      sum = comment_num + forward_num #互动次数
      #用户的活跃度
      if !muser.blank?
        if we.blank?
          we = weibo_account[0].update_evaluates
        end
        avg_forward_average = we.forward_average/100.0 #平均转发数
        avg_comment_average = we.comment_average/100.0 #平均评论数
        evaluates = avg_forward_average+avg_comment_average #活跃度
        csv << [uid,screen_name,location,@sex,followers_count,friends_count,statuses_count,created_at,@name_str,nil,muser.description,evaluates,sum]
      end
    rescue Exception=>e
        if e.message =~ /User does not exists/
          csv << [uid]
         else
          raise e
        end
     end
   end
 end

  #kol--->uid
  
  select count(*) as 数量 from weibo_user_attributes inner join keywords on keywords.id = weibo_user_attributes.keyword_id where weibo_user_attributes.keyword_id = 85;

  #找到kol的uid(关键词里边儿的信息)  csv是纵向结构只能一个类别一个类别的抛,不能横向去生成数据格式
  filename = "核心kol_uid.csv"
  CSV.open filename,"wb" do |csv|
    csv << %w{UId}
      wuas = WeiboUserAttribute.where("keyword_id = ?",85)
      wuas.each do |wua|
        csv << [wua.uid,]
      end
  end

  #找到活跃度
  filename = "个别.csv"
  CSV.open filename,"wb" do |csv|
    csv << %w{UID 活跃度 互动次数}
    @uids = open '/home/rails/Desktop/uids'#文件的路径
    @uids = @uids.read
    @uids = @uids.strip.split("\n")
    @uids.each do |uid|
      we = WeiboUserEvaluate.find_by_uid(uid)
      comment_num = WeiboComment.where("uid = ? and comment_at between ? and ?",2295615873,'2014-01-01','2014-07-01').where("comment_uid = ?",uid).count
      forward_num = WeiboForward.where("uid = ? and forward_at between ? and ?",2295615873,'2014-01-01','2014-07-01').where("forward_uid = ?",uid).count
      sum = comment_num + forward_num #互动次数
      avg_forward_average = we.forward_average/100.0 #平均转发数
      avg_comment_average = we.comment_average/100.0 #平均评论数
      evaluates = avg_forward_average+avg_comment_average #活跃度
      csv << [uid,evaluates,sum]
    end
  end
  
  #用户基本信息(活跃度)
  #添加一个备注和标签 
  filename = "kol用户基本信息app8桌面.csv"
  CSV.open filename,"wb" do |csv|
    csv << %w{UID 昵称 位置 性别 粉丝 关注 微博 注册时间 认证类型 认证原因 备注 标签 平均转发率 平均评论率 平均转发 平均评论 平均互动量 活跃度 原创占比 日均发帖量 近七天发贴量}
    @sex = "" #性别
    @tpye_name = "" #认证类型
    @uids = open '/home/rails/Desktop/uids'#文件的路径
    @uids = @uids.read
    @uids = @uids.strip.split("\n")
    @uids.each do |uid|
  
      weibo_account = WeiboAccount.where("uid = ?",uid)
      we = WeiboUserEvaluate.find_by_uid(uid)
      muser = MUser.find_by_id(uid.to_i) #可以取出用户备注信息

      screen_name = weibo_account[0].screen_name #昵称
      location = weibo_account[0].location #位置
      #weibo_account[0].gender == 0 ? @sex = "女" : @sex = "男"
      @sex = weibo_account[0].human_gender
      followers_count = weibo_account[0].followers_count #粉丝
      friends_count = weibo_account[0].friends_count #关注
      statuses_count = weibo_account[0].statuses_count #微博数量
      created_at = weibo_account[0].created_at.strftime("%Y-%m-%d %H:%M:%S") #用户创建(注册)时间
      verified_type = weibo_account[0].verified_type #认证类型
      #调用认证类型的方法
      @type_name = weibo_account[0].human_verified_type #这块儿怎样将数组转换成文字格式
      @name_str = "" #存放认证类型
        #将认证类型的这个数组循环遍历  
        @type_name.each do |name|
          @name_str += name+","
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
              csv << [uid,screen_name,location,@sex,followers_count,friends_count,statuses_count,created_at,@name_str,nil,muser.description,nil,
avg_forward_rate,avg_comment_rate,avg_forward_average,avg_comment_average,avg_interactive,evaluates,origin_rate,day_posts,day_posts_in_weeks]
             elsif 
                length > 0
            tag_str = ""
            muser.tags.each do |t|
              tag_str += t + ","
            end
              tag_str = tag_str[0,tag_str.length-1]
            csv << [uid,screen_name,location,@sex,followers_count,friends_count,statuses_count,created_at,@name_str,nil,muser.description,tag_str,
avg_forward_rate,avg_comment_rate,avg_forward_average,avg_comment_average,avg_interactive,evaluates,origin_rate,day_posts,day_posts_in_weeks]      
          end
        end
      end
    end
  end

  #异常测试
  
  def opertion
    begin
      num = 0
        num = 5 / 0
      puts num
      rescue Exception=>e
        if e.message =~ /divided by 0/ #这是去匹配异常信息
          $@ #打印异常信息具体位置
          debugger
          num = 10
         else
          raise e #如果上面没有匹配到异常则将异常抛出
        end
    end
  end

  #芯品汇和中国的互动用户当中的内容包含关键词的统计出来
  require 'rseg'
  Rseg.load
  filename = "china4.csv"
  CSV.open filename,"wb" do |csv|
    @keyword = open '/home/rails/Desktop/keywords'#文件的路径
    @keyword = @keyword.read
    @keyword = @keyword.strip.split("\n")
    csv << %w{URL 微博内容 产品 互动次数}
    wds = WeiboDetail.where("uid = ?",2637370247)
    wds.each do |wd|
      if !wd.blank?
        url = "http://weibo.com/"+2637370247.to_s+"/"+WeiboMidUtil.mid_to_str(wd.weibo_id.to_s)
        mwc = MWeiboContent.find_by_id(wd.weibo_id)
        #互动量
        sum = wd.reposts_count+wd.comments_count
        if !mwc.blank?
          content = mwc.text
          @keyword.each{|w|
            @key = w.strip
            if content.include?(@key)
              csv << [url,content,@key,sum]
              break
            end
          }
        end
      end
    end
 end

  #每个关键词的互动总量(跑完以后要重新统计)
  
  require 'rseg'
  Rseg.load
  filename = "互动内容.csv"
  #全局变量统计关键词数量
    @keyword = open '/home/rails/Desktop/keywords'#文件的路径
    @keyword = @keyword.read
    @keyword = @keyword.strip.split("\n")
    words_stats = {}
    @keyword.each{|word|
      word = word.strip
      words_stats[word] = 0
  }
  CSV.open filename,"wb" do |csv|
    csv << %w{URL 互动内容 互动次数 类型 产品 出现次数}
    wds = WeiboDetail.where("uid = ?",2637370247)
    wds.each do |wd|
      if !wd.blank?
        url = "http://weibo.com/"+2637370247.to_s+"/"+WeiboMidUtil.mid_to_str(wd.weibo_id.to_s)
        forwards = WeiboForward.where("weibo_id = ?",wd.weibo_id)
        comments = WeiboComment.where("weibo_id = ?",wd.weibo_id)
        #互动量
        sum = wd.reposts_count+wd.comments_count
         # 转发
        if !forwards.blank?
          forwards.each do |forward|
            #得到一个用户信息对象
            forward_text = MForward.find_by_id(forward.forward_id)
            if !forward_text.blank?
              ftext = forward_text.text.strip
              @str = ""
                @keyword.each{|w|
                  @key = w.strip
                  if ftext.include?(@key)
                    @str += @key
                    @str = @str += ","
                    words_stats[@key] += 1
                  end
                }
              @str = @str[0,@str.length-1]
              csv << [url,ftext,sum,'转发',@str,words_stats]
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
                @keyword.each{|w|
                  @key = w.strip
                  if ctext.include?(@key)
                    @str += @key
                    @str = @str += ","
                    words_stats[@key] += 1 
                  end
                }
              @str = @str[0,@str.length-1]
              csv << [url,ctext,sum,'评论',@str,words_stats]
            end
          end
        end
      end
    end
  end

  def get

    words = %w{Dell Sumsung}
    words_stats = {}

    words.each{|word|
      words_stats[word] = 0
    }

    text = "asdf Dell Sumsung a"
    words.each{|word|
      words_stats[word] += 1 if text.include? word
      puts words_stats[word]
  }
  end



  def get
    e = ['a','b','a','c','b','d','e','d']
    e.each do |a| 
      hash = {a.split(",")[0]||=0 => a.split(",")[0]+=1}
    end
  end

  #每个用户最后一条微博的时间-app8
  filename = "intel-jiuyue.csv"
  uid_url = '/home/rails/Desktop/uids' #读取文件路径
  z_uid = 2637370927 #主号uid
  CSV.open filename,"wb" do |csv|
    task = GetUserTagsTask.new #最近一条微博时间要从接口当中提取
    csv << %w{UID 转发 评论 最后一条微博时间}
    @uids = open uid_url
    @uids = @uids.read
    @uids = @uids.strip.split("\n")
    @uids = @uids.uniq
    @uids.each do |uid| #注意:res == nil 的是可能没有这个用户(被新浪屏蔽了);res.status == nil 的是这个用户没有发过微博(其中包括转发),但是这个用户可能评论过其它微博
      begin
        uid = uid.strip
        comment_num = WeiboComment.where("uid = ? and comment_at between ? and ?",z_uid,'2014-09-01','2014-09-28').where("comment_uid = ?",uid).count
        forward_num = WeiboForward.where("uid = ? and forward_at between ? and ?",z_uid,'2014-09-01','2014-09-28').where("forward_uid = ?",uid).count
        if !res.blank? && !res.status.blank?
          time = DateTime.parse(res.status.created_at).strftime("%Y-%m-%d %H:%S") #近一条微博时间
          if !res.status.blank?
            csv << [uid,comment_num,forward_num,time]
          end
        else #因为有些用户可能有转发或者评论的信息但是他并没有发过微博
          csv << [uid,forward_num,comment_num,'此用户没有发过微博']
        end
      rescue Exception=>e
        if e.message =~ /User does not exists/
          csv << [uid,"此用户已被屏蔽"] #被屏蔽的用户还可以在库里查看到用户信息,但从接口当中就取不到这个用户的信息
         else
          raise e
        end
      end
    end
  end

  #把那些有互动的粉丝统计出来

  filename = "有互动(最后)intel-jiuyue.csv"
  uid_url = '/home/rails/Desktop/zuihou' #读取文件路径
  z_uid = 2637370927 #主号uid
  CSV.open filename,"wb" do |csv|
    task = GetUserTagsTask.new #最近一条微博时间要从接口当中提取
    csv << %w{UID 转发 评论 最后一条微博时间}
    @uids = open uid_url
    @uids = @uids.read
    @uids = @uids.strip.split("\n")
    @uids = @uids.uniq
    @uids.each do |uid| #注意:res == nil 的是可能没有这个用户(被新浪屏蔽了);res.status == nil 的是这个用户没有发过微博(其中包括转发),但是这个用户可能评论过其它微博
      begin
        uid = uid.strip
        res = task.stable{task.api.users.show(uid:uid)}
        comment_num = WeiboComment.where("uid = ? and comment_at between ? and ?",z_uid,'2014-09-01','2014-09-28').where("comment_uid = ?",uid).count
        forward_num = WeiboForward.where("uid = ? and forward_at between ? and ?",z_uid,'2014-09-01','2014-09-28').where("forward_uid = ?",uid).count
        if !res.blank? && !res.status.blank?
          time = DateTime.parse(res.status.created_at).strftime("%Y-%m-%d %H:%S") #近一条微博时间
          if !res.status.blank?
            if comment_num+forward_num > 0
              csv << [uid,forward_num,comment_num,time]
            end
          end
        else #因为有些用户可能有转发或者评论的信息但是他并没有发过微博
          csv << [uid,forward_num,comment_num,'此用户没有发过微博']
        end
      rescue Exception=>e
        if e.message =~ /User does not exists/
          csv << [uid,"此用户已被屏蔽"] #被屏蔽的用户还可以在库里查看到用户信息,但从接口当中就取不到这个用户的信息
         else
          raise e
        end
      end
    end
  end
  
  #英特尔芯品汇:2637370247
  #英特尔中国:2637370927
  #查看有( 回复@英特尔中国)的互动内容（重点分页）所有的
  #指定时间指定用户与监控帐号的互动内容和方式以及原微薄连接
  start_time = '2014-07-01'
  end_time = '2014-11-30'
  filename = '体育互动方式.csv'
  z_uid = 
  CSV.open filename,"wb" do |csv|
    csv << %w{UID URL 内容 动作 内容有效性} #参数
    uids = open 'play-uid'
    uids = uids.read
    uids = uids.strip.split("\n")
    uids = uids.uniq
    
    uids.each do |uid|
      uid = uid.strip
      
      comments = WeiboComment.where("uid = ? and comment_uid = ? and comment_at between ? and ?",z_uid,uid,start_time,end_time)
      if !comments.blank?
        comments.each do |comment|
          url = "http://weibo.com/"+2637370927.to_s+"/"+WeiboMidUtil.mid_to_str(comment.weibo_id.to_s)
          mc = MComment.find(comment.comment_id)
          if !mc.blank? #如果不等于空的话(这块儿做了个非空的判断)
            content = mc.text
            csv << [uid,url,content,'评论']
          end
        end
      end
      
      forwards = WeiboForward.where("uid = ? and forward_uid = ? and forward_at between ? and ?",z_uid,uid,start_time,end_time)
      if !forwards.blank?
        forwards.each do |forward|
          fc = MForward.find(forward.forward_id)
          url = "http://weibo.com/"+2637370927.to_s+"/"+WeiboMidUtil.mid_to_str(forward.weibo_id.to_s)
          if !fc.blank? #如果不等于空的话(这块儿做了个非空的判断)
            content = fc.text
            csv << [uid,url,content,'转发']
          end
        end
      end
  end
end

  #不是粉丝的

  filename = "xph-jiuyue-neirong.csv"
  CSV.open filename,"wb" do |csv|
    csv << %w{UID URL 内容 类别}
    @uids = open '/home/rails/Desktop/xph'
    @uids = @uids.read
    @uids = @uids.strip.split("\n")
    @uids = @uids.uniq
    page = 1
    while true
      comments = WeiboComment.where("uid = ?",2637370247).where("comment_at between ? and ?",'2014-10-01','2014-10-20').paginate(per_page:1000, page:page)
      break if comments.blank?
        comments.each do |comment|
        if @uids.include?(comment.comment_uid.to_s)
           break
          else
            mc = MComment.find(comment.comment_id)
            if !mc.blank? #如果不等于空的话(这块儿做了个非空的判断)
              content = mc.text
              if content.include?("回复@英特尔芯品汇")
                csv << [content,'评论']
              end
            end
         end
      page+=1
      end
    end
    page = 1
    while true
      forwards = WeiboForward.where("uid = ?",2637370247).where("forward_at between ? and ?",'2014-10-01','2014-10-20').paginate(per_page:1000, page:page)
      break if forwards.blank?
        forwards.each do |forward|
          if @uids.include?(forward.forward_uid.to_s)
            break 
          else
            fc = MForward.find(forward.forward_id)
            if !fc.blank? #如果不等于空的话(这块儿做了个非空的判断)
              content = fc.text
              if content.include?("回复@英特尔芯品汇")
                csv << [content,'转发']
              end
            end      
          end
         end
        page+=1
      end
    end

  #取出两个数组当中不重复的元素
  filename = "是否是核心粉丝.csv"
  CSV.open filename,"wb" do |csv|
    
      jike = open 'uids'
      jike = jike.read
      jike = jike.strip.split("\n")

      jike2 = open 'hx-fans'
      jike2 = jike2.read
      jike2 = jike2.strip.split("\n")

      jike.each do |uid|
        if jike2.include?(uid)
          csv << [uid,'Y']
        else
          csv << [uid,'N']
        end
      end
  end
  
  filename = "没有的"
  CSV.open filename,"wb" do |csv|
    
      jike = open 'hx-fans'
      jike = jike.read
      jike = jike.strip.split("\n")

      jike2 = open 'zuizhong-uid'
      jike2 = jike2.read
      jike2 = jike2.strip.split("\n")

      jike2.each do |uid|
        if !jike.include?(uid)
          csv << [uid]
        end
      end
  end
  
  filename = "ITDM2"
  CSV.open filename,"wb" do |csv|
    
      jike = open 'itdm2'
      jike = jike.read
      jike = jike.strip.split("\n")
      jike = jike.uniq

      jike.each do |uid|
        csv << [uid]
      end
  end

  #统计三个数组每个元素出现的次数

  filename = "统计.csv"
  CSV.open filename,"wb" do |csv|
    csv << %w{UID 次数 数量}

    hyzys = open open '/home/rails/Desktop/hyzy'
    hyzys = hyzys.read
    hyzys = hyzys.strip.split("\n")

    qtlqs = open open '/home/rails/Desktop/qtlq'
    qtlqs = qtlqs.read
    qtlqs = qtlqs.strip.split("\n")

    hhwqs = open open '/home/rails/Desktop/hhwq'
    hhwqs = hhwqs.read
    hhwqs = hhwqs.strip.split("\n")

    zongs = []
    zongs = hyzys+qtlqs+hhwqs
    zongs = zongs.uniq

    times = 0
    zongs.each do |a|
      if hyzys.include?(a.to_s) ||  qtlqs.include?(a.to_s) || hhwqs.include?(a.to_s)
        times = 1
        if hyzys.include?(a.to_s) && qtlqs.include?(a.to_s) || qtlqs.include?(a.to_s) && hhwqs.include?(a.to_s) || hhwqs.include?(a.to_s) && hyzys.include?(a.to_s)
          times = 2
          if hyzys.include?(a.to_s) && qtlqs.include?(a.to_s) && hhwqs.include?(a.to_s)
            times = 3
          end
        end
      end
    csv << [a,times,zongs.size]
    end 
  end

  #intel的这些核心粉丝哪些有二次转发
  
  filename = "CHC二次转发.csv"
  CSV.open filename,"wb" do |csv|
    target = 2011912170  #英特尔商用频道
    csv = %w{uid 二次转发}
    @uids = open "uids"
    @uids = @uids.read
    @uids = @uids.strip.split("\n")
    @uids = @uids.uniq
    @uids.each do |uid|
      wa = WeiboAccount.find_by_uid(uid) #可能有重复的用户
      next if wa.nil?
      row = wa.to_row
      WeiboForward.where(uid:target,forward_uid:uid).each{|f|
        mf = MForward.find(f.forward_id)
        if mf
          csv << [uid,mf.reposts_count]
        end
      }
    end
  end

  #导出intel中国每条微博的发布时间在1年以上，1-3年以上，3-5年以上,5年以上
  
  filename = "时间统计.csv"
  CSV.open filename,"wb" do |csv|
    csv << %w{1年以内 1-3年 3-5年 5年以上}
    uid = 2637370927
    one = 0
    two = 0
    three = 0
    four = 0
    w_ds = []
      w_ds = WeiboDetail.where("uid = ?",2637370927)
      w_ds.each do |w_d|  
        url = "http://weibo.com/"+uid.to_s+"/"+WeiboMidUtil.mid_to_str(w_d.weibo_id.to_s)
        time = w_d.post_at
        nowtime = time = Time.new
        if (time.year == nowtime.year)
          one += 1
        end
        if (nowtime.year - time.year > 1 && nowtime.year - time.year < 3)
          two += 1
        end
        if (nowtime.year - time.year > 3 && nowtime.year - time.year < 5)
          three += 1
        end
        if (nowtime.year - time.year > 5)
          four += 1
        end
      end
    csv << [one,two,three,four]
  end


  #导出intel中国每个微博用户注册时间在1年以上，1-3年以上，3-5年以上,5年以上
  
  filename = "时间统计2.csv"
  CSV.open filename,"wb" do |csv|
    csv << %w{1年以内 1-3年 3-5年 5年以上}
    uid = 2637370927
    one = 0
    two = 0
    three = 0
    four = 0
    w_ds = []
      w_ds = WeiboAccount.where("id < ? and id >",10000)
      w_ds.each do |w_d|  
        time = w_d.created_at
        nowtime = time = Time.new
        if (time.year == nowtime.year)
          one += 1
        end
        if (nowtime.year - time.year > 1 && nowtime.year - time.year < 3)
          two += 1
        end
        if (nowtime.year - time.year > 3 && nowtime.year - time.year < 5)
          three += 1
        end
        if (nowtime.year - time.year > 5)
          four += 1
        end
      end
    csv << [one,two,three,four]
  end
  
  #导出这些用户是否有二次转发
  19个用户
  
  filename = "二次转发CHC.csv"
  CSV.open filename,"wb" do |csv|
    csv << %w{uid 二次转发}
    uid_url = 'uids'
    task = GetUserTagsTask.new
    target_uid = 2011912170
    #start_time = '2014-10-01'
    #end_time = '2014-10-13'
    uids = open uid_url
    uids = uids.read
    uids = uids.strip.split("\n")
    uids = uids.uniq
    uids.each do |uid|
      begin
        forward_weibo = WeiboForward.where("uid = ? and forward_uid = ?",target_uid,uid)
        if !(forward_weibo.count == 0)
          forward_weibo.each do |forward|
            f = task.stable{task.api.statuses.show(id:forward.forward_id)}
            f.reposts_count != 0 ? csv << [uid,"有"] : csv << [uid,"没有"]
          end
        end
        rescue Exception =>e
        if e.message =~ /Permission Denied!/ #=~ 用于正则表达式匹配
           csv << [uid]
        end
      end
    end
  end

  #导出这些用户是否有二次评论
  
    filename = "二次评论.csv" 82966982 #这样是根据微博去检索的
    CSV.open filename,"wb" do |csv|
    uid_url = '/home/rails/Desktop/uids'
    task = GetUserTagsTask.new
    target_uid = 2637370927
    start_time = '2014-09-01'
    end_time = '2014-09-28'
    uids = open uid_url
    uids = uids.read
    uids = uids.strip.split("\n")
    uids = uids.uniq
    uids.each do |uid|
      comment_weibo = WeiboComment.where("uid = ? and comment_uid = ? and comment_at between ? and ?",target_uid,uid,start_time,end_time)
      if !(comment_weibo.count == 0)
        comment_weibo.each do |comment|
          f = task.stable{task.api.statuses.show(id:comment.comment_id)}
          if !(f.comments_count == 0)
            fcomment_count =f.comments_count
            csv << [uid,fcomment_count]
          end
        end
      end
    end
  end

  #主号在某个时间段内的所有微博
  
  filename = "监控帐号的微博.csv"
  CSV.open filename,"wb" do |csv|
    target_id = 2637370927
    start_time = '2014-09-01'
    end_time = '2014-09-29'
      csv << %w{URL 发布时间}
      weibos = WeiboDetail.where("uid = ? and post_at between ? and ?",target_id,start_time,end_time)
        if weibos.count != 0
          weibos.each do |weibo|
            url = "http://weibo.com/"+weibo.uid.to_s+"/"+WeiboMidUtil.mid_to_str(weibo.weibo_id.to_s)
            time = weibo.post_at.strftime("%Y-%m-%d %H:%S")
            csv << [url,time]
          end
        end
    end
  
  #互动内容

  #互动内容的有效性
  #用户地址
 
  filename = "用户微博地址连接.csv"
  CSV.open filename,"wb" do |csv|
  csv << %w{UID 地址}
  uids = open "/home/rails/Desktop/uids"
  uids = uids.read
  uids = uids.strip.split("\n")
  uids = uids.uniq
    uids.each do |uid|
      csv << [uid,"http://weibo.com/u/"+uid.to_s]
    end
  end

  #####＝＝＝＝＝＝＝＝＝＝＝＝＝＝＝＝＝＝＝＝＝＝＝＝＝＝?>>>>以下是月报所需要的数据
  
  #从内容当中提取短连接
  filename = ""
  
  #英特尔商用频道微波的点击量
  filename = "点击量统计.csv" #这个是针对微薄内容的短连接来说的
  CSV.open filename,"wb" do |csv|
    uids = open "urls"
    uids = uids.read
    uids = uids.strip.split("\n")
    uids = uids.uniq
    csv <<  %w{url 点击量}
     links = WeiboReport.analyse_links ['2295615873']
     links.each_with_index{|ar,index|
        uid, date,url,wurl = ar
        clicks = WeiboReport.get_click(url)
        if ar.size > 3
          ar[3] = clicks
        else
          ar << clicks
        end
       csv << [url,clicks]
   }
  end

  #这是指某个时间段内这个微博帐号的新增粉丝的数量
  filename = "两个帐号新增粉丝数粉丝男女比例.csv" 
  CSV.open(filename,"wb"){|csv|
  csv << %w{UID 昵称 新增粉丝 男 女}
  m_num = 0
  w_num = 0
  start_time = '2014-08-04'
  end_time = '2014-09-30'
  sum = 0
  target_uids = [2637370247,2637370927]
  target_uids.each do |id|
    fans = WeiboUserRelation.where("uid = ? and follow_time between ? and ?",id,'2004-08-04','2014-09-30')
    fans.each do |fan|
      wa = WeiboAccount.find_by_uid(fan.by_uid)
      if !wa.blank?
        sum += 1 #能查到的粉丝总数
        wa.gender == 1 ? m_num += 1 : w_num += 1 #男女粉丝比例
      end
    end
    wa = WeiboAccount.find_by_uid(id)
    csv << [id,wa.screen_name,sum,m_num,w_num]
  end
  }

  #新增粉丝

  filename = "芯品汇新增粉丝UID.csv" 
  CSV.open(filename,"wb"){|csv|
  csv << %w{UID}
  start_time = '2014-08-04'
  end_time = '2014-09-30'
  id = 2637370927
    fans = WeiboUserRelation.where("uid = ? and follow_time between ? and ?",id,start_time,end_time)
    fans.each do |fan|
      csv << [fan.by_uid]
    end
  }

  #新增粉丝地域分布

  filename  = "intel新增粉丝地域分布.csv"
  CSV.open(filename,"wb") do|csv|
        csv << %w{地域 总数 }
     records = WeiboUserRelation.find_by_sql <<-EOF
     select wa.location location, count(1) count from weibo_user_relations wur left join weibo_accounts wa on wur.by_uid = wa.uid where wur.uid  = '2637370927' and follow_time between '2014-09-01' and '2014-09-30' group by wa.location
  EOF
    records.each do |record|
      csv << [record.location,record.count]
   end
  end

  #＝＝＝＝＝＝＝＝＝＝＝＝＝＝＝＝＝＝＝＝＝＝＝＝＝＝＝＝＝＝＝＝＝＝＝>>>>以上是月报所需要的数据

  #英特尔中国和芯品汇9月份（9.1-9.31）月报的数据，望明天上午11点左右给我呦~
  
  #m = MonitWeiboAccount.find_by_uid(2637370927) 
  #m.send_monthly_report "2014-10-1"


  ##9.18需求分析(商用频道互动人信息+活跃度+互动次数+微博数量)
  
  filename = "intel中国.csv"
  CSV.open filename,"wb" do |csv|
    csv << %w{UID 活跃度 互动次数 转发微博数量}
    start_time = '2014-09-01'
    end_time = '2014-09-30'
    @uids = open '/home/rails/Desktop/uids'#文件的路径
    @uids = @uids.read
    @uids = @uids.strip.split("\n")
    @uids.each do |uid|
      begin
        weibo_account = WeiboAccount.where("uid = ?",uid)
        we = WeiboUserEvaluate.find_by_uid(uid) #求活跃度

        count = WeiboDetail.where("uid = ? and post_at between ? and ?",uid,start_time,end_time).count #微博数量
        #调用认证类型的方法
        comment_num = WeiboComment.where("uid = ? and comment_at between ? and ?",2637370927,start_time,end_time).where("comment_uid = ?",uid).count
        forward_num = WeiboForward.where("uid = ? and forward_at between ? and ?",2637370927,start_time,end_time).where("forward_uid = ?",uid).count
        sum = comment_num + forward_num #互动次数
        #用户的活跃度
        avg_forward_average = we.forward_average/100.0 #平均转发数       
        avg_comment_average = we.comment_average/100.0 #平均评论数
        evaluates = avg_forward_average+avg_comment_average #活跃度
        csv << [uid,evaluates,sum,count]
      rescue Exception=>e
        if e.message =~ /User does not exists/
          csv << [uid,'此用户不存在']
         else
          raise e
        end
     end
   end
 end

  #这些用户在这个时间段内发布了多少条微博
  
  filename = "微博数量.csv"
  task = GetUserTagsTask.new
  CSV.open filename,"wb" do |csv|
    csv << %w{UID 互动数量 数量}
    start_time = '2014-09-01'
    end_time = '2014-09-30'
    $uids.each do |uid|
      begin
        res = task.api.statuses.user_timeline(uid:uid)
          if !res.user.blank?
            csv << [uid,res.reposts_count+res.comments_count,res.user.statuses_count]
          end
      rescue Exception=>e
        if e.message =~ /User does not exists!/
          csv << [uid,'此用户不存在']
        end
      end
    end
  end

  
  filename = "intel回复.csv"
  CSV.open filename,"wb" do |csv|
    csv << %w{UID 内容 有效性 正负面 关键词}
    old_csv = CSV.open '/home/rails/server/weibo-marketing/intel.csv'#(这个csv文件是没有对内容正负面影响进行统计的csv文件)
    lines = old_csv.read
    lines.each do |line|
      uid = line[0]
      content = line[1]
      te = TextEvaluate.new 
      eva,eva_word = te.evaluate(content)
      #情感分析
      fake_content = !content == "转发微博" && !content.gsub(/\[[^\]]+\]/,"").blank? #有效性
      #fake_content = content.gsub(/\[[^\]]+\]/,"").blank? #有效性
      if content.include?("回复@英特尔中国")
        csv << [uid,content,fake_content,eva,eva_word]
      end
    end
  end

  #uid到589(有一部分用户没有发过微博)
    filename = '每个用户模个时间断内的微博数量.csv'
    CSV.open filename,"wb" do |csv|
    csv << %w{UID 数量}

    words = open '/home/rails/Desktop/names'#文件的路径
    words = words.read
    words = words.strip.split("\n")

      words_stats = {}

      words.each{|word|
        words_stats[word] = 0
      }

    text = words
    words.each{|word|
      words_stats[word] += 1 if text.include? word
      csv << [word,words_stats[word]]
  }
  end

  filename = '去重names.csv'
  CSV.open filename,"wb" do |csv|
    csv << %w{昵称}
    words = open '/home/rails/Desktop/names'#文件的路径
    words = words.read
    words = words.strip.split("\n")
    words = words.uniq
      words.each do |word|
        csv << [word]
      end
  end

  filename = 'names_by_uid.csv'
  CSV.open filename,"wb" do |csv|
    csv << %w{UID 昵称 数量}
    words = open '/home/rails/Desktop/names'#文件的路径
    words = words.read
    words = words.strip.split("\n")
    words.each do |word|
      w_a = WeiboAccount.find_by_screen_name(word)
        !w_a.blank? ? csv << [w_a.uid,word] : csv << [word]
      end
    end
  end

  def get
    e.each do |a| 
      e.each{|a| hash[a.split(",")[0]].to_i ||= 0; hash[a.split(",")[0]].to_i += 1}
      #hash = {a.split(",")[0]||=0;a.split(",")[0]+=1}
    end
  end

  filename = '数组统计.csv'
  CSV.open filename,"wb" do |csv|
  csv << %w{元素 数量}
  num = 0
  names = open '/home/rails/Desktop/names'#文件的路径
  names = names.read
  names = names.strip.split("\n")
    names.each do |a|
      if names.include?(a)
        num += 1
        csv << [a,num] 
      end
    end
  end

  def get
    num = 0
    uids = open '/home/rails/Desktop/IT经理世界杂志-uid'#文件的路径
    uids = uids.read
    uids = uids.strip.split("\n")
    uids = uids.uniq

    uidss = open '/home/rails/Desktop/kol-uid'#文件的路径
    uidss = uidss.read
    uidss = uidss.strip.split("\n")
    uidss = uidss.uniq

    uidss.each do |uid|
      if uids.include?(uid)
        num += 1
      end
    end
    puts num
  end

  #商用频道需要的数据需要你协助帮忙跑一下，需求数据如下：
    #2014'Q3	净互动人数	其中ITDM数量	其中KOL数量
    #英特尔商用频道			
    #思科数据中心			
    #中国云计算论坛			
    #CSDN云计算			
    #IT经理世界杂志			
    #阿里云

  filename = '第三个季度.csv'
  CSV.open filename,"wb" do |csv|
    csv << %w{UID 昵称 互动人数 ITDM KOL}
    start_time = '2014-07-01'
    end_time = '2014-10-01'
    @num = 0
    comment_uids = []
    forward_uids = []
    uids = open '/home/rails/Desktop/z-uid'#文件的路径
    uids = uids.read
    uids = uids.strip.split("\n")
    uids.each do |uid|
      wa = WeiboAccount.find_by_uid(uid)
      comments = WeiboComment.where("uid = ? and comment_at between ? and ?",uid,start_time,end_time)
      forwards = WeiboForward.where("uid = ? and forward_at between ? and ?",uid,start_time,end_time)
      #评论的uid
      comments.each do |comment|
        comment_uids << comment.comment_uid
      end
      #转发的uid
      forwards.each do |forward|
        forward_uids << forward.forward_uid
      end
      hudong_uids = comment_uids + forward_uids
      #每条微博的互动人数
      @num = hudong_uids.uniq.size
      csv << [uid,wa.screen_name,@num,0,0,]
    end
  end

  #每个帐号的每个月份的uid

  filename = 'IT经理世界杂志-uid'
  CSV.open filename,"wb" do |csv|
    uid = 1654815470
    start_time = '2014-07-01'
    end_time = '2014-10-01'
    comments = WeiboComment.where("uid = ? and comment_at between ? and ?",uid,start_time,end_time)
    forwards = WeiboForward.where("uid = ? and forward_at between ? and ?",uid,start_time,end_time)
    #评论的uid
    comments.each do |comment|
        csv << [comment.comment_uid]
    end
    #转发的uid
    forwards.each do |forward|
        csv << [forward.forward_uid]
    end
  end

  #kol-uid
  filename = 'kol-uid.csv'
  CSV.open filename,"wb" do |csv|
    csv << %w{KOL-UID}
    nums = [75,85,86,88,90,91,92]
    nums.each do |num|
      wuas = WeiboUserAttribute.where("keyword_id = ?",num)
      wuas.each do |wua|
        csv << [wua.uid]
      end
    end
  end

  #itdm-uid
  filename = 'itdm-uid.csv'
  CSV.open filename,"wb" do |csv|
    csv << %w{KOL-UID}
    nums = [77,78]
    nums.each do |num|
      wuas = WeiboUserAttribute.where("keyword_id = ?",num)
      wuas.each do |wua|
        csv << [wua.uid]
      end
    end
  end

    filename = "阿里云-uid"
    CSV.open filename,"wb" do |csv|
    csv << %w{UID}
    @uids = open '/home/rails/Desktop/阿里云-uid'
    @uids = @uids.read
    @uids = @uids.strip.split("\n")
    @uids = @uids.uniq
      @uids.each do |uid|
        csv << [uid]
      end
    end

  #select count(*) as 数量 from weibo_comments where comment_at between '2014-09-01' and '2014-09-30' and uid = 2637370927 and comment_uid = 1306484861

  #找出共同关注的所有用户再去重统计
  
  task = GetUserTagsTask.new
  path = File.join(Rails.root, "db/570-uid")
  uids = []
  CSV.open("data/1428共同关注_1113.csv","wb"){|csv|
  File.open(path,"r").each do|uid|
     uid = uid.strip
   uids << uid
   end
    uids.each{|uid|
      begin
        ids = task.api.friendships.friends_ids(uid:uid,count:5000).ids
        ids.each{|id|
          csv << [id]
        }
      rescue
      end
    }
  }

  filename = '连接3.csv'
  CSV.open filename,"wb" do |csv|
    csv << %w{URL}
    old_csv = CSV.open '/home/rails/server/weibo-marketing/连接.csv'#(这个csv文件是没有对内容正负面影响进行统计的csv文件)
    lines = old_csv.read
    lines.each do |line|
      content = line[0]
      if content.include?('#英眼看IT#') 
        url = content[0,content.length-7]
        csv << [url]
      elsif
        csv << [content]
      end
    end
  end

  #根据url算出点击量

  filename = "第一季度点击量统计.csv"
  CSV.open filename,"wb" do |csv|
    csv <<  %w{时间 url 点击量 微博内容}
     links = WeiboReport.analyse_links ['2637370927'],'2014-09-01','2014-09-30'
     links.each_with_index{|ar,index|
        puts ar
        uid, date,url,wurl = ar
        clicks = WeiboReport.get_click(url)
        if ar.size > 3
          ar[3] = clicks
        else
          ar << clicks
        end
       csv << [date,url,clicks,wurl]
   }
  end

  #互动重点
WeiboForward.where(uid:target,forward_uid:uid).where("forward_at between ? and ?","2014-9-1","2014-10-1").count("distinct forward_id")
WeiboComment.where(uid:target,comment_uid:uid).where("comment_at between ? and ?","2014-9-1","2014-10-1").count("distinct comment_id")
#提出那30W人里边， 今年与中国有互动量，并且 近7天微博数大于 1 的人的 列表
#统计每一个人与中国的互动量，转发＋评论 大于 1的人，再更新他的活跃度，并计算7天发贴量大于1 的人，把用户信息导出到另一个CSV里

  z_uid = 2637370927
  start_time = '2014-09-01'
  end_time = '2014-10-01'
  sum = 0 #互动数
  row = []
  30w_uids = []
  filename = '30W粉丝信息最新最新-九月份.csv'
  CSV.open filename,"wb" do |csv|

    old_csv = CSV.open '2637370927_fans.csv'
    lines = old_csv.read

    uids = open '30w-uids'#文件的路径
    uids = uids.read
    uids = uids.strip.split("\n")

    uids.each do |hd_uid|
      begin
        lines.each do |line|
          if hd_uid == line[0]
            comment_num = WeiboComment.where("uid = ? and comment_at between ? and ?",z_uid,start_time,end_time).where("comment_uid = ?",hd_uid).count("distinct comment_id")
            forward_num = WeiboForward.where("uid = ? and forward_at between ? and ?",z_uid,start_time,end_time).where("forward_uid = ?",hd_uid).count("distinct forward_id")
            sum = comment_num + forward_num
            row << comment_num
            row << forward_num
            csv << row
          end
        end
        rescue Exception =>e
        puts e.message  #打印出异常信息
        if e.message =~ /User does not exists!/ #=~ 用于正则表达式匹配
           csv << [uid,'此用户不存在']
        end
      end
    end
  end
    
  #接口提取微博内容  
  
  task = GetUserTagsTask.new
  filename = '根据url跑出内容.csv'
  CSV.open filename,"wb" do |csv|
    csv << %w{URL 微博ID 内容}
    urls = open '/home/rails/Desktop/urls'
    urls = urls.read
    urls = urls.strip.split("\n")
    urls = urls.uniq
    urls.each do |url|
      weibo_id = WeiboMidUtil.str_to_mid URI.parse(url.strip).path.split("/").last
      weibo = task.api.statuses.show(id:weibo_id)
      csv << [url,weibo_id,weibo.text]   
    end
  end

  #深夜发美食、晒美食、丰盛晚餐、拍美食、平板美食、吃货
  
  task = GetUserTagsTask.new
  filename = '关键词.csv'
  CSV.open filename,"wb" do |csv|
    
  end

  #张祯

  filename = "search_平板词.csv"
  CSV.open filename,"wb" do |csv|
    row = []
    csv << row
    fans_num = 0
    source = ""
    old_csv = CSV.open '/home/rails/Desktop/search_平板词.csv'#(这个csv文件是没有对内容正负面影响进行统计的csv文件)
    lines = old_csv.read
    lines.each do |line|
      row = line
      fans_num = line[4]
      source = line[15]
      if fans_num.to_i > 100
        if !source.include?('皮皮时光机') || !source.include?('微活动') || !source.include?('微博活动') || !source.include?('好保姆') || !source.include?('分享按钮')
          csv << row
        end
      end
    end
  end

  #微博话题互动数统计

  filename = "话题微博.csv"
  CSV.open filename,"wb" do |csv|
    start_time = '2014-04-01'
    end_time = '2014-07-01'
    z_uid = 2637370927
    
  end

  filename = "的微博.csv"
  CSV.open filename,"wb" do |csv|
    target_id = 2637370927
    start_time = '2014-09-01'
    end_time = '2014-09-29'
      csv << %w{URL 发布时间}
      weibos = WeiboDetail.where("uid = ? and post_at between ? and ?",target_id,start_time,end_time)
        if weibos.count != 0
          weibos.each do |weibo|
            url = "http://weibo.com/"+weibo.uid.to_s+"/"+WeiboMidUtil.mid_to_str(weibo.weibo_id.to_s)
            time = weibo.post_at.strftime("%Y-%m-%d %H:%S")
            csv << [url,time]
          end
        end
    end

  #所有粉丝在九月份的互动
  #今年与中国的互动数,二次转发数,互动人信息

  z_uid = 2637370927
  start_time = '2014-09-01'
  end_time = '2014-10-01'
  sum = 0 #互动数
  row = []
  filename = '30W粉丝信息最新-九月份-二次转发最新.csv'
  CSV.open filename,"wb" do |csv|
    csv << %w{UID 二次转发数}
    old_csv = CSV.open '2637370927_fans.csv'
    lines = old_csv.read
    lines.each do |line|
      begin
        row = line
        uid = line[0]
        uid = uid.strip
        comment_num = WeiboComment.where("uid = ? and comment_at between ? and ?",z_uid,start_time,end_time).where("comment_uid = ?",uid).count("distinct comment_id")
        forward_num = WeiboForward.where("uid = ? and forward_at between ? and ?",z_uid,start_time,end_time).where("forward_uid = ?",uid).count("distinct forward_id")
        sum = comment_num + forward_num
        if sum > 0
           row = wa.to_row
            WeiboForward.where(uid:target,forward_uid:uid).where("forward_at between ? and ?",start_time, end_time).each{|f|
              mf = MForward.find(f.forward_id)
              if mf
                csv << [uid,mf.reposts_count]
              end
            }
        end
        rescue Exception =>e
        puts e.message  #打印出异常信息
        if e.message =~ /User does not exists!/ #=~ 用于正则表达式匹配
           csv << [uid,'此用户不存在']
        end
      end
    end
  end
  
  #今年中国和芯汇的互动用户粉丝大于5000的数量
  #中国

  #30
  filename = 'hehe.csv'
  CSV.open filename,"wb" do |csv|
    csv << %w{UID}
    z_uid = 2637370927#与某个主号的
    uids = open '/home/rails/Desktop/ceshi'#文件的路径
    uids = uids.read
    uids = uids.strip.split("\n")
    uids = uids.uniq
    uids.each do |uid|
      wur = WeiboUserRelation.where('uid = ? and by_uid = ?',z_uid,uid)
      if !wur.blank?
        csv << [wur[0].by_uid]
      end
    end
  end


  中国:2743
  芯品汇:2536

  #今年的与中国/芯品汇有互动的粉丝
  #找到(中国/芯品汇)这些的UID及信息
  #这些用户的粉丝大于5000的
  z_uid = '2637370247'
  filename = '今年与芯品汇有互动的粉丝2-粉丝大于5000'
  CSV.open filename, "wb" do |csv|
    csv << %w{UID}
    uids = open '今年与芯品汇有互动的UID补充最新'#文件的路径
    uids = uids.read
    uids = uids.strip.split("\n")
    uids = uids.uniq
    uids.each do |uid|
      wur = WeiboUserRelation.where('uid = ? and by_uid = ?',z_uid,uid)
      if !wur.blank?
        count = WeiboAccount.find_by_uid(uid).followers_count
        if count > 5000
          csv << [uid]
        end
      end
    end
  end

  select count(distinct weibo_user_interaction_snap_dailies.from_uid) as 数量 from weibo_user_interaction_snap_dailies inner join weibo_user_relations on weibo_user_relations.by_uid = weibo_user_interaction_snap_dailies.from_uid and weibo_user_interaction_snap_dailies.uid = weibo_user_relations.uid inner join weibo_accounts on weibo_accounts.uid = weibo_user_relations.by_uid where weibo_accounts.followers_count > 5000 and weibo_user_interaction_snap_dailies.uid = 2637370247 and weibo_user_interaction_snap_dailies.date between '2014-01-01' and '2014-10-15';


  hash = {}
  filename = '30W粉丝信息最新最新-九月份最新13.csv'
  CSV.open filename,"wb" do |csv|
    old_csv = CSV.open '2637370927_fans.csv'
    old_csv.each{|line|
      uid = line[0]
      hash[uid] = line
    }
    uids = open "九月份有互动的中国的粉丝的uid最新"
    uids = uids.read
    uids = uids.strip.split("\n")
    uids.each do |uid|
      line = hash[uid]
      if !line.blank?
        csv << line
      end
    end
  end

  hash = {}
  filename = '30W粉丝信息最新最新-九月份最新13.csv'
  CSV.open filename,"wb" do |csv|
    old_csv = CSV.open '2637370927_fans.csv'
    old_csv.each{|line|
      uid = line[0]
      hash[uid] = line
    }
    uids = open "九月份有互动的中国的粉丝的uid最新"
    uids = uids.read
    uids = uids.strip.split("\n")
    uids.each do |uid|
      line = hash[uid]
      if !line.blank?
        csv << line
      end
    end
  end
    
  filename = "认证类型4.csv"
  CSV.open filename,"wb" do |csv|
    csv << %w{UID 认证类型}
    @uids = open '/home/rails/Desktop/intel-uids-zuixin'#文件的路径
    @uids = @uids.read
    @uids = @uids.strip.split("\n")
    @uids = @uids.uniq
    @uids.each do |uid|
      begin
        weibo_account = WeiboAccount.where("uid = ?",uid)
        if !weibo_account.blank?
          verified_type = weibo_account[0].verified_type #认证类型
          #调用认证类型的方法
          type_name = weibo_account[0].human_verified_type #这块儿怎样将数组转换成文字格式
          name_str = "" #存放认证类型
          #将认证类型的这个数组循环遍历  
          type_name.each do |name|
            if !name.blank?
              name_str += name+","
            end
          end
           name_str = name_str[0,name_str.length-1]
           csv << [uid,name_str]
        end
        rescue Exception =>e
        if e.message =~ /User does not exists/ #=~ 用于正则表达式匹配
           csv << [uid,"此用户已被屏蔽"]
        end
      end
    end
  end

  filename = "认证类型补充.csv"
  CSV.open filename,"wb" do |csv|
    csv << %w{UID 认证类型}
    uids = open 'xin-uids'#文件的路径
    uids = uids.read
    uids = uids.strip.split("\n")
    uids = uids.uniq
    uids.each do |uid|
    begin
      wa = WeiboAccount.find_by_id(uid)
      if !wa.blank?
        verified_type = wa.verified_type #认证类型
        #调用认证类型的方法
        type_name = wa.human_verified_type #这块儿怎样将数组转换成文字格式
          name_str = "" #存放认证类型
          #将认证类型的这个数组循环遍历  
          type_name.each do |name|
            if !name.blank?
              name_str += name+","
            end
          end
          name_str = name_str[0,name_str.length-1]
          csv << [uid,name_str]
        end
      rescue Exception => e
        if e.message =~ /User dose not exists!/
          csv << [uid,"此用户已被屏蔽"]
        end
      end
    end
  end

  #将三个csv合并成一个(必须是有顺序的)用于操作大的csv文件 

  filename = '中国.csv'
  CSV.open filename,"wb" do |csv|
  one_csv = CSV.open '中国粉丝判断.csv'#(这个csv文件是没有对内容正负面影响进行统计的csv文件)
  lines1 = one_csv.read
    lines1.each do |line|
      csv << line
    end 
  two_csv = CSV.open '中国粉丝判断3.csv'#(这个csv文件是没有对内容正负面影响进行统计的csv文件)
  lines2 = two_csv.read
    lines2.each do |line|
      csv << line
    end
  end

  weibo_id = WeiboMidUtil.str_to_mid URI.parse(url.strip).path.split("/").last

  #两千个粉丝当中分别与这url的互动数(难点重点)

  filename = "八月份.csv"
  CSV.open filename,"wb" do |csv|
    
    start_time = '2014-08-01'
    end_time = '2014-09-01'

    csv << %w{UID 转发 评论 互动数}

    uids = open '/home/rails/Desktop/uids'#文件的路径
    uids = uids.read
    uids = uids.strip.split("\n")
    uids = uids.uniq

    urls = open '/home/rails/Desktop/urls'#文件的路径
    urls = urls.read
    urls = urls.strip.split("\n")
    urls = urls.uniq

    uids.each do |uid|
      fs=0
      cs=0
      urls.each do |url|
      weibo_id = WeiboMidUtil.str_to_mid URI.parse(url.strip).path.split("/").last
        comment_num = WeiboComment.where("weibo_id = ? and comment_at between ? and ?",weibo_id,start_time,end_time).where("comment_uid = ?",uid).count("distinct comment_id")
        cs += comment_num
        forward_num = WeiboForward.where("weibo_id = ? and forward_at between ? and ?",weibo_id,start_time,end_time).where("forward_uid = ?",uid).count("distinct forward_id")
        fs += forward_num
        debugger
      end
      csv << [uid,fs,cs, fs+cs]
    end
  end

  ##娜娜急用需求分析
  #中国+芯品汇30w+7w粉丝信息+最后一条微博时间+距离现在天数

  filename = 'EMC.csv'
  CSV.open filename,"wb" do |csv|
  csv << %w{UID 时间 距离现在的天数}
    task = GetUserTagsTask.new
    rows = []
    day = 0
    uids = open "EMC-uid"
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
            last_time = Date.parse(last_time)

            now_time = Date.parse(Time.now.strftime("%Y-%m-%d %H:%S"))

            day = (now_time-last_time).to_i

            rows << last_time
            rows << day
            csv << rows
          end
        end
      rescue Exception=>e
        if e.message =~ /User does not exists!/
          csv << [uid,"此用户已被屏蔽"]
        end
      end
    end
  end

  #俩个帐号分析月份分布

  filename = 'xph7W粉丝月份分布.csv'
  CSV.open filename,"wb" do |csv|
    csv << %w{UID 关注时间}
    task = GetUserTagsTask.new
    old_csv = CSV.open '/home/rails/Desktop/2637370247_fans.csv'
    old_csv.each do |line|
      begin
        uid = line[0]
        uid = uid.strip
        uid = uid.to_i
        rel = WeiboUserRelation.where("uid = ? and by_uid = ?",2637370247,uid)
        if !rel.blank?
          follow_time = rel[0].follow_time ? rel[0].follow_time.strftime("%Y-%m-%d %H:%M") : nil
          csv << [uid,follow_time]
        end
      rescue Exception=>e
        if e.message =~ /User does not exists!/
          csv << [uid,"此用户已被屏蔽"]
        end
      end
    end 
  end

  def f
    ft = ""
    num = 0
    old_csv = CSV.open '/home/rails/Desktop/xph7W粉丝月份分布.csv'
    old_csv.each do |line|
      ft = line[1]
      if !ft.blank?
        if ft > "2013-10-01 00:00" && ft < "2014-10-01 00:00"
          if ft[5,1].to_i == 0
            if ft[6,1].to_i == 2
              num += 1
              puts num
            end
          end
        end
      end
    end
  end

  #30天内没发过微博的粉丝数
  
  filename = "xph近七天发布微博的粉丝信息.csv"
  CSV.open filename,"wb" do |csv|
  csv << %w{UID 粉丝数 关注数 性别 地域 认证类型 微博注册时间 发布微博数量 转发占比 原创占比 自身平均互动量(近50条微博平均互动量) 天数}
  days = 0
  old_csv = CSV.open '/home/rails/Desktop/xph7W-天数最新1.csv'
    old_csv.each do |line|
      days = line[19]
      if !days.blank?
        if days.to_i < 7
          uid = line[0]
          uid = uid.strip
          weibo_account = WeiboAccount.where("uid = ?",uid)
          if !weibo_account.blank?
            if line[6] != 0
              location = weibo_account[0].location #位置
              #weibo_account[0].gender == 0 ? @sex = "女" : @sex = "男"
              sex = weibo_account[0].human_gender
              followers_count = weibo_account[0].followers_count #粉丝
              friends_count = weibo_account[0].friends_count #关注
              statuses_count = weibo_account[0].statuses_count #微博数量
              created_at = weibo_account[0].created_at.strftime("%Y-%m-%d %H:%M:%S") #用户创建(注册)时间
              verified_type = line[8] #认证类型
              zfb = statuses_count == 0 ? 0 :  100-weibo_account[0].origin_rate  #转发占比
              ycb = weibo_account[0].origin_rate #原创占比
              zs = line[16]#自身平均互动量
              csv << [uid,followers_count,friends_count,sex,location,verified_type,created_at,statuses_count,zfb,ycb,zs,days]
            end
          end
        end
      end
    end  
  end

  #近七天发布微博总量

  filename = "intel近七天发布微博总量.csv"
  CSV.open filename,"wb" do |csv|
    csv << %w{UID 近七天发帖量}
    num = 0
    uids = open '/home/rails/Desktop/intel-uids'#文件的路径
    uids = uids.read
    uids = uids.strip.split("\n")
    uids.each do |uid|
      wue = WeiboUserEvaluate.find_by_uid(uid)
      num = wue.day_posts_in_week*7
      csv << [uid,num.to_i]
    end
  end

  #去除发帖量为0的
  
  filename = "intel近七天发布微博的粉丝信息最新.csv"
  CSV.open filename,"wb" do |csv|
    rows = []
    old_csv = CSV.open 'intel近七天发布微博的粉丝信息.csv'
    old_csv.each do |line|
      if line[7].to_i != 0
        rows = line
        csv << rows
      end
    end
  end
  
  #
  filename = "intel近一个月微博-互动-粉丝2.csv"
  CSV.open filename,"wb" do |csv|
  csv << %w{UID 粉丝数 关注数 性别 地域 认证类型 微博注册时间 发布微博数量 转发占比 原创占比 互动次数}
            #uid,followers_count,friends_count,sex,location,verified_type,created_at,statuses_count,zfb,ycb,days,rj
#UID	昵称	位置	性别	粉丝	关注	微博	注册时间	认证	认证原因	备注	标签	转发率	平均转发	评论率	平均评论	平均转发＋评论	微博原创率%	最后一条微博时间	距离现在天数
#isfans = fans.blank? ? '不是' : '是'
    z_uid = 2637370927
    uids = open "intel-uids-zuixin"
    uids = uids.read
    uids = uids.strip.split("\n")
    uids = uids.uniq
      uids.each do |uid|
        uid = uid.strip
        weibo_account = WeiboAccount.where("uid = ?",uid)
        if !weibo_account.blank?
          location = weibo_account[0].location #位置
          #weibo_account[0].gender == 0 ? @sex = "女" : @sex = "男"
          sex = weibo_account[0].human_gender
          followers_count = weibo_account[0].followers_count #粉丝
          friends_count = weibo_account[0].friends_count #关注
          statuses_count = weibo_account[0].statuses_count #微博数量
          created_at = weibo_account[0].created_at.strftime("%Y-%m-%d %H:%M:%S") #用户创建(注册)时间
          #verified_type = line[8] #认证类型
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
          zfb = statuses_count == 0 ? 0 :  100-weibo_account[0].origin_rate  #转发占比
          ycb = weibo_account[0].origin_rate #原创占比
          #rj = line[16]#日均发布微博数量占比
          comment_num = WeiboComment.where("uid = ?",z_uid).where("comment_uid = ?",uid).count("distinct comment_id")
          forward_num = WeiboForward.where("uid = ?",z_uid).where("forward_uid = ?",uid).count("distinct forward_id")
          csv << [uid,followers_count,friends_count,sex,location,@name_str,created_at,statuses_count,zfb,ycb,comment_num+forward_num]
      end
    end
  end

  #近50条微博的平均互动量(在原来的基础上)

  filename = "intel近七天发布微博的粉丝信息.csv"
  CSV.open filename,"wb" do |csv|
    csv << %w{UID 平均互动}
    old_csv = CSV.open '/home/rails/Desktop/intel30W-天数最新1.csv'

    uids = open "/home/rails/Desktop/intel-uids"
    uids = uids.read
    uids = uids.strip.split("\n")
    uids = uids.uniq

    uids.each do |uid|
      old_csv.each do |line|
        if uids.include?(line[0])
          lv = line[16]
          csv << [line[0],lv]
        end
      end   
    end
  end

  #全量粉丝关注时间
  filename = "intel-time.csv"
  CSV.open filename,"wb" do |csv|
    csv << %w{UID 关注时间}
    wurs = WeiboUserRelation.where("uid = 2637370247 and follow_time between ? and ?",'2013-11-01','2013-12-01').count
    wurs.each do |wur|
      csv << [wur[0].by_uid,wur[0].follow_time]
    end
  end

  WeiboAccountSnapDaily.where("uid = ? and date = ?",2637370247,'2013-11-01').follow_count

  #第二个需求(互动)
  #1,英特尔中国&英特尔芯品汇近1个月有发布微博用户与英特尔中国/英特尔芯品汇互动次数、有效互动和无效互动及两个账号该月总互动量(中国:;芯品汇:;)
  filename = "intel近一个月有发布微博的用户.csv"
  z_uid = 2637370927#与某个主号的
  #start_time = '2014-09-28'#开始时间
  #end_time = '2014-10-28'
  CSV.open filename,"wb" do |csv|
  csv << %w{UID 转发 评论 互动数 天数}
  days = 0
  old_csv = CSV.open 'intel30W-天数最新1.csv'
    old_csv.each do |line|
      days = days = line[19]
      if !days.blank? 
        if days.to_i < 30
          uid = line[0]
          comment_num = WeiboComment.where("uid = ?",z_uid).where("comment_uid = ?",uid).count("distinct comment_id")
          forward_num = WeiboForward.where("uid = ?",z_uid).where("forward_uid = ?",uid).count("distinct forward_id")
          csv << [uid,forward_num,comment_num,comment_num+forward_num,line[19]]
        end
      end
    end  
  end

  #这些用户与主号的互动内容的有效性

  require 'rseg'
  Rseg.load

  filename = "intel互动的有效性分析最新2.csv"
  CSV.open filename,"wb" do |csv|
  csv << %w{UID 互动内容 有效性 动作}
  #start_time = '2014-09-28'
  #end_time = '2014-10-28'
  old_csv = CSV.open 'intel近一个月有发布微博的用户.csv'
  old_csv.each do |line|
  uid = line[0]
  uid = uid.strip
  page = 1
  while true
    comments = WeiboComment.where("uid = ? and comment_uid = ?",2637370927,uid).paginate(per_page:1000, page:page)
    break if comments.blank?
    comments.each do |comment|
      comment_date = comment.comment_at  
      mc = MComment.find(comment.comment_id)
      if !mc.blank? #如果不等于空的话(这块儿做了个非空的判断)
        content = mc.text #内容
        #情感分析
       result = content != "转发微博" && !content.gsub(/\[[^\]]+\]/,"").blank?
          csv << [uid,content,result,'评论']
      end
     end
    page+=1
   end
    page = 1
   while true
    forwards = WeiboForward.where("uid = ? and forward_uid = ?",2637370927,uid).paginate(per_page:1000, page:page)
    break if forwards.blank?
    forwards.each do |forward|
      forward_date = forward.forward_at
      fc = MForward.find(forward.forward_id)
      if !fc.blank? #如果不等于空的话(这块儿做了个非空的判断)
        content = fc.text
        #情感分析
        result = content != "转发微博" && !content.gsub(/\[[^\]]+\]/,"").blank?
          csv << [uid,content,result,'转发']
      end
     end
    page+=1
   end
  end
  end

  #单独判断内容的有效性(最准确的)

  filename = "有效性.csv"
  CSV.open filename,"wb" do |csv|
  csv << %w{UID 有效性}
  old_csv = CSV.open '/home/rails/Desktop/xph互动的有效性分析最新2.csv'
    old_csv.each do |line|
      uid = line[0]
      content = line[1]
      result = content != "转发微博" && !content.gsub(/\[[^\]]+\]/,"").blank?
      csv << [uid,result]
    end
  end
  

  #指定帐号最近一个月总互动量

  def sum_hudong
    z_uid = 2637370247#与某个主号的
    start_time = '2014-09-28'#开始时间
    end_time = '2014-10-28'
    comment_num = WeiboComment.where("uid = ? and comment_at between ? and ?",z_uid,start_time,end_time).count("distinct comment_id")
    forward_num = WeiboForward.where("uid = ? and forward_at between ? and ?",z_uid,start_time,end_time).count("distinct forward_id")
    puts comment_num+forward_num
  end

  #在以上近1个月有发布微博的用户当中，近1个月与英特尔中国/英特尔芯品汇有互动用户的粉丝数、关注数、性别、年龄、地域、认证类型、微博注册时间、发布微博数量、转发占比、原创占比和互动次数、互动形式（转发、评论）转发的二次转发数量、互动微博列表及分类数据

  filename = "没有的.csv"
  CSV.open filename,"wb" do |csv|

    uids = open '/home/rails/Desktop/7W'#文件的路径
    uids = uids.read
    uids = uids.strip.split("\n")
    uids = uids.uniq
    
    uidss = open '/home/rails/Desktop/3W'#文件的路径
    uidss = uidss.read
    uidss = uidss.strip.split("\n")
    uidss = uidss.uniq

    uids.each do |uid|
      if !uidss.include?(uid)
        csv << [uid]
      end
    end
  end

  #取某个帐号的近1w个粉丝

  name = "三星电子" #传不同的参数(主号的screen_name),去导出不同主号的信息
  folder = "#{name}" #这块儿是指不同帐号要放到不同的文件夹下,以避免不同的帐号时修改太多的变量
  filename = "#{folder}10000粉丝"
  CSV.open filename,"wb" do |csv|
    csv << %w{粉丝 时间}

    records1 = WeiboUserRelation.find_by_sql <<-EOF
      select by_uid from weibo_user_relations where uid = 1660521332 order by by_uid asc limit 5000
    EOF

    records1.each do |line|
      uid = line.by_uid
      csv << [uid]
    end

    records2 = WeiboUserRelation.find_by_sql <<-EOF
      select by_uid from weibo_user_relations where uid = 1660521332 order by by_uid desc limit 5000
    EOF
    records2.each do |line|
      uid = line.by_uid
      csv << [uid]
    end
  end

  filename = "惠普电脑10000粉丝-最后一条时间.csv"
  CSV.open filename,"wb" do |csv|
    task = GetUserTagsTask.new #最近一条微博时间要从接口当中提取
    csv << %w{UID 最后一条微博时间}
    @uids = open "惠普电脑10000粉丝"
    @uids = @uids.read
    @uids = @uids.strip.split("\n")
    @uids = @uids.uniq
    @uids.each do |uid| #注意:res == nil 的是可能没有这个用户(被新浪屏蔽了);res.status == nil 的是这个用户没有发过微博(其中包括转发),但是这个用户可能评论过其它微博
      begin
        uid = uid.strip
        res = task.stable{task.api.users.show(uid:uid)}
        if !res.blank? || !res.status.blank?
          time = DateTime.parse(res.status.created_at).strftime("%Y-%m-%d %H:%S")
          csv << [uid,time]
          elsif
          csv << [uid,nil]
        end
      rescue Exception=>e
          puts "!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!"
          puts e.message
          if e.message =~ /User does not exists!/
            csv << [uid,"此用户已被屏蔽"]
          elsif e.message =~ /out of limitation/
            sleep 2700
          else
            csv << [uid,e.message]
        end
      end
    end
  end

  #微博类别

  filename = "intel微博类别.csv" #原微博连接
  CSV.open filename,"wb" do |csv|
    csv << %w{URL Tag1 Tag2 Tag3 Tag4 GEO}
    urls = open 'url'
    urls = urls.read
    urls = urls.strip.split("\n")
    urls = urls.uniq
    urls.each do |url|
    begin
      weibo_id = WeiboMidUtil.str_to_mid URI.parse(url.strip).path.split("/").last
      post = Post.find_by_weibo_id(weibo_id)
      if !post.blank?
        csv << [url,post.tag1,post.tag2,post.tag3,post.tag4,post.geo]
        elsif
          csv << [url]
        end
    rescue Exception=>e
        puts url
        debugger
            csv << [uid, e.message]
        end
    end
  end

  task = GetUserTagsTask.new
  name = "联想10000粉丝"
  filename = "#{name}信息.csv"
  CSV.open filename,"wb" do |csv|
    csv << WeiboAccount.to_row_title(:quality) #如果导出的数据列太多的话可以通过:to_row_title(:quality)的这个方法直接生成这个微博用户的所有列
      uids = open '/home/rails/Desktop/张桢/联想10000粉丝'
      uids = uids.read
      uids = uids.strip.split("\n")
      uids = uids.uniq
      weibo = task.load_weibo_user(uids[0])
      csv << weibo.to_row(:quality)
    end
  end

  filename = "uids"
  CSV.open filename,"wb" do |csv|
    uids = open "/home/rails/Desktop/intel-uids-zuixin"
    uids = uids.read
    uids = uids.strip.split("\n")
    uids = uids.uniq
    uids.each do |uid|
      csv << [uid]
    end
  end

  filename = "最终time.csv"
  CSV.open filename,"wb" do |csv|
    task = GetUserTagsTask.new #最近一条微博时间要从接口当中提取
    csv << %w{UID 最后一条微博时间}
    @uids = open "/home/rails/Desktop/xin-uids"
    @uids = @uids.read
    @uids = @uids.strip.split("\n")
    @uids = @uids.uniq
    @uids.each do |uid| #注意:res == nil 的是可能没有这个用户(被新浪屏蔽了);res.status == nil 的是这个用户没有发过微博(其中包括转发),但是这个用户可能评论过其它微博
      begin
        uid = uid.strip
        res = task.stable{task.api.users.show(uid:uid)}
        if !res.blank? || !res.status.blank?
          time = DateTime.parse(res.status.created_at).strftime("%Y-%m-%d %H:%S")
          csv << [uid,time]
          elsif
          csv << [uid,nil]
        end
      rescue Exception=>e
          puts "!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!"
          puts e.message
          if e.message =~ /User does not exists!/
            csv << [uid,"此用户已被屏蔽"]
          elsif e.message =~ /out of limitation/
            sleep 2700
          else
            csv << [uid, e.message]
        end
      end
    end
  end

  filename = "intel-11.02.csv"
  CSV.open filename,"wb" do |csv|
    csv << %w{URL Weibo_ID 发布时间}
    wds = WeiboDetail.where("uid = 2637370927 and post_at between ? and ?","2014-11-02","2014-11-03")
    wds.each do |wd|
      weibo_id = wd.weibo_id
      url = "http://weibo.com/"+2637370927.to_s+"/"+WeiboMidUtil.mid_to_str(wd.weibo_id.to_s)
      time = wd.post_at.strftime("%Y-%m-%d %H:%S")
      csv << [url,weibo_id,time]
    end
  end

  #begin
    英特尔芯品汇:2637370247
    英特尔中国:2637370927
    武汉万达汉秀:3318508000
    金融街购物中心微博:1924531943
    北京宠爱国际动物医院:3869439663
    英特尔商用频道:2295615873
    阿里云:1644971875
    IT经理世界杂志:1654815470
    CSDN云计算:1741045432
    中国云计算论坛:2841727664
    思科数据中心:1979838530
  #end

  #每条微博有效性统计占比

  #dddddddddddddddddd
  
  def get
    uids = open "ARM中国近一个月有互动的粉丝"
    uids = uids.read
    uids = uids.strip.split("\n")
    uids = uids.uniq
    puts uids.size
  end

  filename = "匹配14W信息时间3.csv"
  CSV.open filename,"wb" do |csv|
    csv << %w{UID 时间}

    uids = open "/home/rails/Desktop/xin-uids"
    uids = uids.read
    uids = uids.strip.split("\n")

    time_csv = CSV.open "/home/rails/Desktop/14W最后一条时间最新终极.csv"

    uids.each do |uid|
      time_csv.each do |line|
        if uids.include?(line[0])
          csv << [uid,line[1]]
        end
      end
    end
  end
    
  hash = {}
  filename = 'time.csv'
  CSV.open filename,"wb" do |csv|

    old_csv = CSV.open '/home/rails/Desktop/14W最后一条时间最新终极.csv'

    old_csv.each{|line|
      uid = line[0]
      hash[uid] = line
    }
    uids = open "/home/rails/Desktop/xin-uids"
    uids = uids.read
    uids = uids.strip.split("\n")

    uids.each do |uid|
      line = hash[uid]
      if !line.blank?
        csv << line
      end
    end
  end

  #娜娜近三个月有互动的
  
  start_time = '2014-07-28'#开始时间
  end_time = '2014-10-28'#终止时间
  filename = "xph近三个月有互动的人" #都是基于近一个月发过微博的用户
  CSV.open filename,"wb" do |csv|
   csv << %w{UID}
      
        rows = [] #存放有互动的id
        comments = WeiboComment.where("uid = ? and comment_at between ? and ?",2637370247,start_time,end_time)
        forwards = WeiboForward.where("uid = ? and forward_at between ? and ?",2637370247,start_time,end_time)

        comments.each do |comment|
            csv << [comment.comment_uid]
        end

        forwards.each do |forward|
            csv << [forward.forward_uid]
        end
        
    end
    
   Post.where(status:1).order(:post_at.desc).first
 => #<Post _id: BSON::ObjectId('54530618f92ea1017f000001'), appkey: 1075842038, content: "万圣节去哪鬼混？别忘了用英特尔芯平板拍下今天的鬼脸装扮，上传微博并@英特尔中国，够吓人就有自拍器相送哦~", created_at: Fri, 31 Oct 2014 13:40:22 CST +08:00, geo: "Original", image_id: "5369", post_at: Fri, 31 Oct 2014 13:40:22 CST +08:00, status: 1, tag1: "Awareness", tag2: "Tablet", tag3: "Trendy Mobile", tag4: "Others", updated_at: Fri, 31 Oct 2014 13:40:22 CST +08:00, user_id: 7, weibo_id: "3771731649077928", weibo_uid: 2637370927> 
1.9.3-p545 :016 > Post.find_by_weibo_id 'asdf'



  filename = "gw.csv"
  CSV.open filename,"wb" do |csv|
     #接口提取 api 通过url 转发 评论的内容 查出这些人说了些什么
  task = GetUserTagsTask.new
    te = TextEvaluate.new
    csv << WeiboAccount.to_row_title(:full)+%w{内容 互动时间 互动微博连接 动作 正负面 正负面匹配词 有效性}
      urls = open "gw-url"
      urls = urls.read
      urls = urls.strip.split("\n")
      urls.each do|line|
        url = line.strip
        weibo_id = ::WeiboMidUtil.str_to_mid url.split("/").last
        commentcount = 0
        forward_weibo = WeiboForward.where("weibo_id = ?",weibo_id)
        comment_weibo = WeiboComment.where("weibo_id = ?",weibo_id)
          if !comment_weibo.nil?
            comment_weibo.each do |comment|
               row = []
               account = task.load_weibo_user(comment.comment_uid.to_s)
               comment.blank? ? commentat = '' : commentat = comment.comment_at.strftime("%Y-%m-%d %H:%M:%S")
               url = "http://weibo.com/#{comment.uid}/#{WeiboMidUtil.mid_to_str(comment.comment_id.to_s)}"
               c  = MComment.find(comment.comment_id)
               next if c.nil?
               eva,eva_word = te.evaluate(c.text)
               valid = te.valid(c.text)
               row = account.to_row(:full) + [url,c.text,commentat,'评论',eva,eva_word,valid]
               csv << row
            end
          end
          if !forward_weibo.nil?
            forward_weibo.each do |forward|
              row = []
              account = task.load_weibo_user(forward.forward_uid.to_s)
              forward.blank? ? forwardat = '': forwardat = forward.forward_at.strftime("%Y-%m-%d %H:%M:%S")
              url = "http://weibo.com/#{forward.forward_uid}/#{WeiboMidUtil.mid_to_str(forward.forward_id.to_s)}"
              c =  MForward.find(forward.forward_id)
              next if c.nil?
               eva,eva_word = te.evaluate(c.text)
               valid = te.valid(c.text)
              row = account.to_row(:full) + [url,c.text,forwardat,'转发',eva,eva_word,valid]
               csv << row
            end
          end
      end
   end
