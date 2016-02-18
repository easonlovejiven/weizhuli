
  #方法调用 第一次 14.8
    start_time = "2015-01-01"
    end_time = "2015-07-16"
    
    sources = open "sources"
    sources = sources.read
    sources = sources.strip.split("\n")
    sources = sources.uniq
    
    keywords = open "xph-words"
    keywords = keywords.read
    keywords = keywords.strip.split("\n")
    keywords = keywords.uniq
    
    filter_max_status = 20000
    filter_max_fans = 30000
    filter_min_fans = 50
    sum = 100000
    aaa(keywords,"xph-15-补投-3.csv",{start_time:start_time,end_time:end_time,filter_max_status:filter_max_status,filter_max_fans:filter_max_fans,filter_min_fans:filter_min_fans,sum:sum,sources:sources}){|status|
      true
    }
  
  
  #我要报名#IDF15#
  #三星筛选
  #1补充,4补充2
  3.02-3.9,3.9-3.16,3.16-3.23
  sources = open "sources"
  sources = sources.read
  sources = sources.strip.split("\n")
  sources = sources.uniq
  
  start_time = "2015-03-16"
  end_time = "2015-03-23"
  
  keywords = open "keywords"
  keywords = keywords.read
  keywords = keywords.strip.split("\n")
  keywords = keywords.uniq
  
  aaa(keywords,"全网关键词微薄-3.csv",{start_time:start_time,end_time:end_time}){|status|
    true
  }
  
  #过滤小美到家
  filename = "筛选-母亲节-2.csv"
  CSV.open filename,"wb" do |csv|
    old_csv = CSV.open "母亲节-最终2.csv"
    old_csv.each do |line|
      if line[2].include?("北京") && line[3].include?("女")
        csv << line
      end
    end
  end
  
  #对自己的微薄精选内容进行筛选 开头是【
  filename = "intel微薄精选关键词-1.csv"
  CSV.open filename,"wb" do |csv|
    old_csv = CSV.open "intel微薄精选关键词.csv"
    countent = ""
    element = ""
    old_csv.each{|line|
      if line[0] != "UID"
        countent = line[14]
        if !countent.nil?
          element = countent.first
          if element != "【"
            csv << line
          end
        end
      end
    }
  end
  
  #判断内容开头是否是数字
  filename = "intel微薄精选关键词-2.csv"
  CSV.open filename,"wb" do |csv|
    old_csv = CSV.open "intel微薄精选关键词-1.csv"
    countent = ""
    element = ""
    num = ""
    old_csv.each{|line|
      if line[0] != "UID"
        countent = line[14]
        element = countent.first
        num = element =~ /\d/ #正则表达式
        if num != 0
          csv << line
        end
      end
    }
  end
  
  #昵称是以什么开头的
  filename = "intel微薄精选关键词-4.csv"
  CSV.open filename,"wb" do |csv|
    old_csv = CSV.open "intel微薄精选关键词-3.csv"
    name = ""
    element = ""
    old_csv.each{|line|
      if line[0] != "UID"
        name = line[1]
        if !name.nil?
          element = name.first
          if element != "#"
            csv << line
          end
        end
      end
    }
  end
  
  #筛选昵称是否包括用户,18岁,19,20,30,淘,店,网,代购,买,卖,团
  filename = "intel微薄精选关键词-16.csv"
  CSV.open filename,"wb" do |csv|
    old_csv = CSV.open "intel微薄精选关键词-15.csv"
    name = ""
    old_csv.each{|line|
      if line[0] != "UID"
        name = line[1]
        if !name.include?("团")
          csv << line
        end
      end
    }
  end
  
  #筛选筛选部分来源
  filename = "intel微薄精选关键词-18.csv"
  CSV.open filename,"wb" do |csv|
    old_csv = CSV.open "intel微薄精选关键词-17.csv"
    name = ""
    old_csv.each{|line|
      if line[0] != "UID"
        name = line[15]
        if !name.nil? #对来源是nil的进行过滤
          if !name.include?("类")
            csv << line
          end
        end
      end
    }
  end
  
  #过滤来源，粉丝数，微薄数，和日期，和部分内容
  filename = "蜜月游-1.csv"
  CSV.open filename,"wb" do |csv|
    old_csv = CSV.open "蜜月游.csv"
    sources = open "sources"
    sources = sources.read
    sources = sources.strip.split("\n")
    sources = sources.uniq
    num = "" #判断内容开头是否是数字
    old_csv.each{|line|
      if line[0] != "UID"
        source = line[15] #判断来源
        fans = line[4].to_i #判断粉丝数
        weibo = line[6].to_i #判断微薄数量
        date = line[13] #判断日期
        countent = line[14] #判断内容开头
        if !sources.include?(ActionView::Base.full_sanitizer.sanitize(source))
          if fans > 50 && fans < 30000 && weibo < 20000
            if date > "2014-06-01" && date < "2015-03-06"
              if !countent.nil?
                element = countent.first
                num = element =~ /\d/
                if element != "【" && num != 0
                  csv << line
                end
              end
            end
          end
        end
      end
    }
  end
  
  #合并两个csv文件
  
  filename = "芯品汇-13.csv"
  CSV.open filename,"wb" do |csv|
    old_csv1 = CSV.open "芯品汇2-13.csv"
    old_csv1.each{|line|
      csv << line
    }
    old_csv2 = CSV.open "芯品汇补充-13.csv"
    old_csv2.each{|line|
      csv << line
    }
  end
  
  #筛日期
    start_time = "2014-11-01"
    end_time = "2015-02-12"
    
    keywords = open "匹配词7"
    keywords = keywords.read
    keywords = keywords.strip.split("\n")
    keywords = keywords.uniq
    #["手机丢了","手机坏了","手机被偷了","手机废了","手机进水了","手机没了","手机不能用了","手机摔了"]
    aaa(keywords,"购买+更换家电人群.csv",{start_time:start_time,end_time:end_time}){|status|
      true
    }
    
    def update_params(params)
      params[:foo] = 'bar'
      params #它只起到了打印的作用
    end
    
    #获取token
    
  key = "2751696217"
  secret = "3dbddd005fc1af2600f795806cc372bc"
  WeiboOAuth2::Config.api_key = key
  WeiboOAuth2::Config.api_secret = secret

  @client = WeiboOAuth2::Client.new
  u = "18813015535"
  p = "159357"
  t = @client.auth_password.get_token(u,p)
  
  token = t.token# "2.005wKAMBDtpNADc71e3fbde2T8XNWB"
  
  start_time = "2014-11-01"
  end_time = "2015-01-06"
  sum = 1000
   
  aaa(['想去欧洲看看'],"想去欧洲看看.csv",{start_time:start_time,end_time:end_time,sum:sum}){|status|
    true
  }
  #简单测试(测试调用hash)
  def bbb(opts)
    end_time = opts[:end_time]
    start_time = opts[:start_time]
    puts "开始时间:#{start_time}====>结束时间:#{end_time}"
  end
  
  #过滤关键词
  filename = "测试2.csv"
  CSV.open filename,"wb" do |csv|
    old_csv = CSV.open "测试.csv"
    no_sources = ['皮皮时光机','vivo_Xplay','么么哒4G','一加手机','OPPO_N1mini','云中小鸟','孔明社交管理','Beauty小微','定时showone','粉丝大本营','搞笑达人','我的微播炉','简网','时光机','好保姆','活力兔','语录类','创意类','时尚类','红人类','搞笑类','职场类','星座类','漫画类','风景类','娱乐类','亲子类','美食类','女性类','汽车类','淘宝网','悄悄喜欢你']
    old_csv.each do |line|
      source = line[15]
      if source != "来源"
        if !no_sources.include?(source)
          csv << line
        end
      end
    end
  end
  
  #调用这个方法可以转换用户认证类型
  def self.human_verified_type(verified_type)
    verified_types = {
      -1 => "未认证",
      0 =>"名人",
      1 =>"政府",
      2 =>"企业",
      3 =>"媒体",
      4 =>"校园",
      5 =>"网站",
      6 =>"应用",
      7 =>"团体（机构）",
      10 => "微博女郎",
      200 =>"未审核达人",
      220 =>"达人",
    }

    verified_type_goups = {
      -1 => "草根",
      0 =>"橙V",
      1 =>"蓝V",
      2 =>"蓝V",
      3 =>"蓝V",
      4 =>"蓝V",
      5 =>"蓝V",
      6 =>"蓝V",
      7 =>"蓝V",
      200 =>"达人",
      220 =>"达人",
    }

    type = verified_types[verified_type]
    group = verified_type_goups[verified_type]

    [type,group]

  end
  
  filename = "猜猜看1.csv"
  CSV.open filename,"wb" do |csv|
    csv << %w{面值 数量}
    num = 0
    money = 0
    40000.times{
      num = [*1..4000].sample 1
      money = [*1..4000].sample 1
      if num.first * money.first == 4000
        csv << [money.first,num.first]
      end
    }
  end
  
  filename = "猜猜看2.csv"
  CSV.open filename,"wb" do |csv|
    csv << %w{面值 数量}
    x < 4000
    y < 4000
    x*y = 4000
    40000.times{
      num = [*1..4000].sample 1
      money = [*1..4000].sample 1
      if x.first * y.first == 4000
        csv << [x.first,y.first]
      end
    }
  end
  
  filename = "二次转发.csv"
  CSV.open filename,"wb" do |csv|
    csv << %w{uid 二次转发}
    uid_url = 'uids'
    uids = open uid_url
    uids = uids.read
    uids = uids.strip.split("\n")
    uids = uids.uniq
    uids.each do |uid|
      csv << [uid]
    end
  end
  #2105542225
  
  
  【小学生日记】：刚考完妈妈就让我学习，学习。爸爸也治不了妈妈，整天稀罕她很很，不舍得熊她一句。瑶瑶的爸爸就不这样，就揍她妈妈，她的妈妈就很老实。女人这东西，稀罕后患多，一揍就老实。
我爸爸就是太小胆。
【老师评语】：这篇小学生日记，短短几十个字，内容繁而不杂，情感细腻多变，笔法嫩中显辣，批判含蓄，我老人家读书许多年，早就已经审美疲劳，但这篇日记还是让我耳目一新，大吃一惊。
开篇“刚考完就让我学习，”用白描的手法，道出了中国千千万万孩子的生存现实，稚嫩的肩膀上承担了莫名焦虑的父母和急欲复兴的民族赋予的历史重望。底下两个字“学习”，看似简单的重复，却暗流涌动，情绪饱满，第一层意思，“学习，学习”是父母的口头禅、紧箍咒，一会儿不念就不舒服；第二层意思，表达出孩子内心的郁闷和难抑的愤怒：你除了讲学习，再也没有别的事可做了吗？
但作者没有沉溺于对妈妈的情绪之中，而是笔锋一转：“爸爸也治不了妈妈”，另一个强大的男人都对妈妈没办法，我一个小孩子又能做什么呢？绝望中弥散着一股淡淡的忧伤，可谓神来之笔，韵味悠长。
接下来，作者对爸爸妈妈粘粘乎乎的关系进行了抨击：“整天稀罕她很很，不舍得熊她一句”，乡土味十足的“稀罕”一词，和创意十足的叠词“很很”，十分传神地描写出一位“老婆迷”爸爸，在儿子陷于水深火热时的迟钝，和儿子无声的控诉：你老婆如此过分，你就不管管吗！
然而，作者再次奇迹般地跳出自己的情绪，把笔触伸向更加宽广的空间：“瑶瑶的爸爸就不这样，就揍她妈妈，她的妈妈就很老实。”，惩前毖后，治病救人，批判的目的是拯救，作者牢牢把握住批判现实主义文学观的立场，用身边的例子，给爸爸标出了方向，树立了榜样，并以革命的乐观主义精神循循善诱：女人这东西，稀罕后患多，一揍就老实。
最后，作者再次展现出超强的把握情绪的能力和直面现实的勇气，他太了解爸爸了，知道他永远不可能如己所愿，治治自己的老婆，永远摆脱不了“老婆迷”的命运，“我爸爸就是太小胆”，多少无奈，多少心疼，多少惋惜，多少石破天惊的情感，多少洋洋洒洒的感慨，尽在“太小胆”！


