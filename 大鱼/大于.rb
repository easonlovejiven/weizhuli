#1,09年到现在的每个月份数量的统计
#2,城市级别的统计一,二,三级别
#3,随机取出1000个用户
#(1)共同关注
#(2)标签
#(3)关键词



  #3
  
  filename = "家多宝随机取出1000个用户.csv"
  CSV.open filename,"wb" do |csv|
    csv << %w{UID}
    old_csv = CSV.open "search_加多宝1.csv"
    num = 0
    old_csv.each do |line|
      num += 1
      if num % 700 == 0
        csv << [line[0]]
      end
    end
  end
  
  #月份统计

  filename = "09年到现在的每个月份数量的统计2.csv"
  CSV.open filename,"wb" do |csv|
    csv << %w{时间段 数量}
    status = {}
    old_csv = CSV.open "search_王老吉.csv"
    old_csv.each do |line|
      time = line[13]
      if time != "发布时间"
        fb_time = DateTime.parse(time).strftime("%Y-%m-%d %H:%S")
        time = fb_time[2,5]
        if status[time].blank?
          status[time] = 0
          else
            status[time] += 1
        end
      end
    end
    status.each do |line|
        csv << line
     end
  end
  
  #单个月份的测试(测试每个月份的分布情况 )
  
  filename = "单个月份的测试.csv"
  CSV.open filename,"wb" do |csv|
    csv << %w{时间段 数量}
    status = {}
    num = 0
    old_csv = CSV.open "search_王老吉.csv"
    old_csv.each do |line|
      time = line[13]
      if time != "发布时间"
        fb_time = DateTime.parse(time).strftime("%Y-%m-%d %H:%S")
        time = fb_time[2,5]
        if time == "14-05"
          num += 1
        end
        puts num
      end
    end
  end
  
  #城市级别统计  
  
  filename = "city.csv"
  CSV.open filename,"wb" do |csv|
    csv << %w{级别 数量}
    status = {}
    old_csv = CSV.open "2637370927_fans.csv"
    
    old_csv.each do |line|
      location = line[2]
      level = city_level(location)
        if status[level].blank?
          status[level] = 0 
        end
          status[level] += 1
    end

     status.each do |line|
        csv << line
     end
  end
  
  #测试单个城市的级别
  
  def get_level
    old_csv = CSV.open "2637370927_fans.csv"
    num = 0
    old_csv.each do |line|
      location = line[2]
      level = city_level(location)
      if level == 4
        debugger
        uid = line[0]
      end
      puts num
    end
  end
  
  #取出级别4的随机500个用户uid->取出具体信息
  
  
  filename = "500-uid"
  CSV.open filename,"wb" do |csv|
    csv << %w{UID}
    old_csv = CSV.open "2637370927_fans.csv"
    num = 0
    old_csv.each do |line|
      location = line[2]
      level = city_level(location)
      if level == 4
        uid = line[0]
        if line[0] != "UID"
          num += 1
          if num % 500 == 0
            csv << [line[0]]
          end
        end
      end
    end
  end
  
  #这个方法是返回微博地址的城市级别的
  
  def city_level(location)

    cities = {
      1 => %w{北京 上海},
      2 => %w{合肥 兰州 东莞 佛山 广州 深圳 珠海 南宁 贵阳 石家庄 唐山 郑州 哈尔滨 武汉 长沙 长春 常州 南京 苏州 无锡 南昌 大连 沈阳 呼和浩特 济南 青岛 太原 西安 成都 天津 乌鲁木齐 昆明 杭州 宁波 温州 重庆},
      3 => %w{蚌埠 马鞍山 芜湖 福州 晋江 泉州 三明 厦门 漳州 惠州 江门 茂名 汕头 湛江 中山 柳州 海口 保定 邯郸 秦皇岛 安阳 洛阳 南阳 平顶山 新乡 大庆 绥芬河 十堰 株洲 吉林 连云港 南通 常熟 昆山 太仓 吴江 张家港 靖江 泰州 江阴 徐州 盐城 扬州 镇江 九江 鞍山 抚顺
      包头 鄂尔多斯 银川 西宁 德州 东营 济宁 莱芜 临沂 日照 泰安 潍坊 威海 烟台 淄博 长治 晋中 宝鸡 绵阳 攀枝花 曲靖 玉溪 富阳 湖州 海宁 嘉兴 金华 慈溪 余姚 衢州 绍兴 台州 瑞安 舟山},
      4 => %w{安庆 巢湖 池州 滁州 阜阳 淮北 淮南 黄山 六安 宿州 铜陵 宣城 福清 龙岩 南平 宁德 莆田 南安 石狮 白银 玉门 庆阳 天水 张掖 潮州 从化 增城 河源 台山 揭阳 普宁 高州 化州 梅州 清远 英德 汕尾 韶关 阳江 云浮 肇庆 百色 北海 贵港 桂林 来宾 钦州 梧州 玉林
      安顺 都匀 兴义 遵义 三亚 沧州 承德 武安 衡水 廊坊 三河 迁安 遵化 邢台 张家口 鹤壁 焦作 济源 开封 漯河 偃师 舞钢 濮阳 三门峡 商丘 信阳 许昌 巩义 荥阳 新密 新郑 周口 驻马店 佳木斯 鸡西 牡丹江 讷河 齐齐哈尔 肇东 恩施 鄂州 黄石 荆门 荆州 随州 襄樊 咸宁 仙桃 汉川
      孝感 应城 宜昌 常德 郴州 衡阳 怀化 邵阳 湘潭 益阳 永州 岳阳 张家界 白城 白山 榆树 公主岭 四平 松原 通化 延吉 金坛 溧阳 淮安 海门 启东 如皋 通州 宿迁 姜堰 泰兴 兴化 宜兴 邳州 东台 江都 仪征 丹阳 句容 扬中 赣州 吉安 景德镇 萍乡 新余 宜春 樟树 贵溪 海城 本溪
      朝阳 普兰店 瓦房店 庄河 丹东 东港 阜新 葫芦岛 锦州 辽阳 盘锦 新民 铁岭 大石桥 营口 巴彦淖尔 赤峰 呼伦贝尔 通辽 乌海 乌兰察布 乌兰浩特 吴忠 滨州 乐陵 菏泽 章丘 曲阜 兖州 邹城 聊城 临清 胶南 胶州 即墨 莱西 平度 肥城 新泰 安丘 高密 青州 寿光 诸城 荣成 乳山
       文登 海阳 莱阳 莱州 龙口 蓬莱 招远 滕州 枣庄 大同 高平 晋城 临汾 吕梁 孝义 朔州 忻州 阳泉 运城 汉中 铜川 咸阳 延安 达州 德阳 广汉 广元 乐山 西昌 泸州 眉山 南充 内江 遂宁 宜宾 自贡 资阳 拉萨 阿克苏 库尔勒 哈密 喀什 石河子 塔城 保山 丽江 临沧 宣威 思茅
       景洪 昭通 建德 临安 平湖 桐乡 东阳 兰溪 义乌 永康 丽水 奉化 江山 嵊州 上虞 诸暨 临海 温岭 乐清},
    }

    loc = location.split(" ")
    level = 4
    cities.each{|l,cities|
      if cities.include?(loc[0]) || cities.include?(loc[1])
        level = l
        break
      end
    }
   
    level

  end
  
  
