filename = "娜娜.csv" #都是基于近一个月发过微博的用户
  CSV.open filename,"wb" do |csv|
  
    csv << %w{zero 1-5次 5-10次 10-20次 20以上}
    
      end_time = "2015-01-12" #结束时间
      hash = {}
      uids = []
      rows_all = []
      rows_use = []
      num = 0
      zero = 0
      one = 0
      two = 0
      three = 0
      four = 0
      
      #先得到所要匹配的uid
     
     keyword_ids = [75,77,85,86,88,90,91,92]
     uids = WeiboUserAttribute.find_by_sql("select  uid  from weibo_user_attributes where  keyword_id in (#{keyword_ids*","})").map(&:uid)
     debugger
      
        
    #商用频道互动
    fcs = WeiboForward.find_by_sql <<-EOF
    select uid,sum(count) num from (
      select 'c',comment_uid uid,count(distinct comment_id) as count from weibo_comments where uid = 2295615873 and comment_at between "2012-01-01" and "#{end_time}" group by comment_uid 
      union
      select 'f',forward_uid uid,count(distinct forward_id) as count from weibo_forwards where uid = 2295615873 and forward_at between "2014-01-01" and "#{end_time}" group by forward_uid
    ) as fc group by uid
    EOF
    
    
    fcs.each do |fc|
      rows_all << [fc.uid,fc.num]
    end
      
    
    fcs.map{|fc|
      hash[fc.uid] = fc
      [fc.uid,fc.num]
    }

    uids.each do |uid|
      line = hash[uid]
      if !line.blank?
        rows_use << line
        else
          rows_use << [uid,0]
      end
    end
    
    rows_use.each{|line|
      num = line[1]
      debugger
      if num == 0
        zero += 1
        elsif num > 0 && num <= 5
          one += 1
          elsif num > 5 && num <= 10
            two += 1
            elsif num > 10 && num <= 20
              three += 1
              elsif num >= 20
                four += 0
      end
    }
    csv << [zero,one,two,three,four]
  end
  
  
  configs = [[0],[0,5],[5,10],[10,20],[20,nil]]
    counts = [0,0,0,0,0]
    rows_use.each do |line|
      num = line[1].to_i
      i = null
      configs.each_with_index{|config,index|
        if config.size==1
          if num == config[0]
            i = index
            break
          end
        end
        
        if config.size == 2
          if config[0] == nil
            if num <= config[1]
              i = index
              break
            end
          elsif config[1] == nil
            if num > config[0]
              ...
            end
          else
            if num > config[0] && if num <= config[1]
              ...
            end
          end
          
        end
      }
      
      counts[i] += 1
    end
    
    filename = "shiyi.csv"
      CSV.open filename,"wb" do |csv|
      
      csv << %w{UID 互动次数}
      time = "2015-01-09" #结束时间
      hash = {}
      uids = []
      rows_all = []
      rows_use = []
      itdm_kol = []
      
      #先得到所要itdm匹配的uid
      
      itdms = WeiboUserAttribute.find_by_sql <<-EOF
        select  uid uid  from weibo_user_attributes where  keyword_id = 77
      EOF
      
      kols = WeiboUserAttribute.find_by_sql <<-EOF
        select  uid uid  from weibo_user_attributes where  keyword_id = 85 or keyword_id= 86 or keyword_id = 88 or keyword_id = 90  or keyword_id = 91  or keyword_id = 92
      EOF
      
      itdm_kol << itdms
      itdm_kol << kols
      
      itdm_kol.each do|lines|
        lines.each{|line|
          uids << line.uid
        }
      end
      
    #商用频道互动
    fcs = WeiboForward.find_by_sql <<-EOF
    select uid,sum(count) num from (
      select 'c',comment_uid uid,count(comment_id) as count from weibo_comments where uid = 2295615873 and comment_at between "2014-11-01" and "#{time}" group by comment_uid 
      union
      select 'f',forward_uid uid,count(forward_id) as count from weibo_forwards where uid = 2295615873 and forward_at between "2014-11-01" and "#{time}" group by forward_uid
    ) as fc group by uid
    EOF
    
    fcs.each do |fc|
      rows_all << [fc.uid,fc.num]
    end
      
    #匹配指定用户
    rows_all.each{|line|
      uid = line[0]
      hash[uid] = line
    }
    
    uids.each do |uid|
      line = hash[uid]
      if !line.blank?
        csv << line
        else
          csv << [uid,0]
      end
    end
  end
  
  #平台测试
  filename = "itdm测试.csv"
  CSV.open filename,"wb" do |csv|
  
    csv << %w{zero 1-5次 5-10次 10-20次 20以上}
      time = "2015-01-12"
      hash = {}
      uids = []
      rows_all = []
      rows_use = []
      itdm_kol = []
      num = 0
      zero = 0
      one = 0
      two = 0
      three = 0
      four = 0
      
      #先得到所要itdm匹配的uid
      
      kols = WeiboUserAttribute.find_by_sql <<-EOF
        select  uid uid  from weibo_user_attributes where  keyword_id = 85 or keyword_id= 86 or keyword_id = 88 or keyword_id = 90  or keyword_id = 91  or keyword_id = 92
      EOF
      
      itdm_kol << kols
      
      itdm_kol.each do|lines|
        lines.each{|line|
          uids << line.uid
        }
      end
      
    #商用频道互动
    fcs = WeiboForward.find_by_sql <<-EOF
    select uid,sum(count) num from (
      select 'c',comment_uid uid,count(comment_id) as count from weibo_comments where uid = 2295615873 and comment_at between "2012-01-01" and "#{time}" group by comment_uid 
      union
      select 'f',forward_uid uid,count(forward_id) as count from weibo_forwards where uid = 2295615873 and forward_at between "2012-01-01" and "#{time}" group by forward_uid
    ) as fc group by uid
    EOF
    
    fcs.each do |fc|
      rows_all << [fc.uid,fc.num]
    end
      
    #匹配指定用户
    rows_all.each{|line|
      uid = line[0]
      hash[uid] = line
    }
    
    uids.each do |uid|
      line = hash[uid]
      if !line.blank?
        rows_use << line
        else
          rows_use << [uid,0]
      end
    end
    
    #互动数统计
    rows_use.each do |line|
      num = line[1]
      num = num.to_i
      if num == 0
        zero += 1
      end
      if num >= 1 && num <= 5
        one += 1
      end
      if num > 5 && num <= 10
        two += 1
      end
      if num > 10 && num <= 20
        three += 1
      end
      if num > 20
        four += 1
      end
    end
    csv << [zero,one,two,three,four]
  end
  
  filename = "十一itdm互动数.csv"
  CSV.open filename,"wb" do |csv|
    csv << %w{UID 互动数}
    time = "2015-01-14"
    hash = {}
    uids = []
    rows_all = []
    rows_use = []
    itdm_kol = []
      itdms = WeiboUserAttribute.find_by_sql <<-EOF
        select  uid uid  from weibo_user_attributes where  keyword_id = 77
      EOF
      
      itdm_kol << itdms
      
      itdm_kol.each do|lines|
        lines.each{|line|
          uids << line.uid
        }
      end
      
      fcs = WeiboForward.find_by_sql <<-EOF
        select uid,sum(count) num from (
          select 'c',comment_uid uid,count(comment_id) as count from weibo_comments where uid = 2295615873 and comment_at between "2014-11-01" and "#{time}" group by comment_uid 
          union
          select 'f',forward_uid uid,count(forward_id) as count from weibo_forwards where uid = 2295615873 and forward_at between "2014-11-01" and "#{time}" group by forward_uid
        ) as fc group by uid
        EOF
        
        fcs.each do |fc|
          rows_all << [fc.uid,fc.num]
        end
      
    #匹配指定用户
      rows_all.each{|line|
        uid = line[0]
        hash[uid] = line
      }
    
    uids.each do |uid|
      line = hash[uid]
      if !line.blank?
        csv << line
        else
          csv << [uid,0]
      end
    end
  end
  
  filename = "库里itdm用户"
  CSV.open filename,"wb" do |csv|
    itdms = WeiboUserAttribute.find_by_sql <<-EOF
      select uid from weibo_user_attributes where  keyword_id = 77
    EOF
    itdms.each do |line|
      csv << [line.uid]
    end
  end
  
  #判断四个阶段的互动
  filename = "结果.csv"
  CSV.open filename,"wb" do |csv|
    one = 0
    two = 0
    three = 0
    
    old_csv = CSV.open "pd.csv"
    
    old_csv.each{|line|
      if line[0].to_i > line[1].to_i
        one = 1
        elsif line[0].to_i < line[1].to_i
          one = -1
      end
      
      if line[1].to_i > line[2].to_i
        two = 1
        elsif line[1].to_i < line[2].to_i
          two = -1
      end
      
      if line[2].to_i > line[3].to_i
        three = 1
        elsif line[2].to_i < line[3].to_i
          three = -1
      end
      csv << [line[0],one,two,three]
    }
  end
  #超出ITDM
  
  filename = "娜娜ITDM"
  CSV.open filename,"wb" do |csv|
    old_csv = CSV.open "sypd.csv"
    old_csv.each{|line|
      type = line[1]
      if type == "ITDM"
        csv << [line[0]]
      end
    }
  end
