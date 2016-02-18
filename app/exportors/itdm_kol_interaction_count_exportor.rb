# -*- encoding : utf-8 -*-
class ItdmKolInteractionCountExportor < ExportorBase

  description <<EOF
  根据date 导出date之前kol,itdm互动次数，
  数据列包括:
     zero 1-5次 5-10次 10-20次 20以上
EOF


  title "time之前与商用频道互动次数 导出(根据date)张桢"


  before do |this,opts|
    #TODO:
    @time = opts[:time]
     
  end

  export name:"KOL" do |ins,opts|
    ins.kol_interaction_count(@time)
  end

  export name:"ITDM" do |ins,opts|
    ins.itdm_interaction_count(@time)
  end

  def kol_interaction_count(time)
  
      rows << %w{zero 1-5次 5-10次 10-20次 20以上}
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
      
      #itdm_kol << itdms
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
    rows << [zero,one,two,three,four]
  end



  def itdm_interaction_count(time)
      rows << %w{zero 1-5次 5-10次 10-20次 20以上}
      
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
      
      itdms = WeiboUserAttribute.find_by_sql <<-EOF
        select  uid uid  from weibo_user_attributes where  keyword_id = 77
      EOF
      
      #itdm_kol << itdms
      itdm_kol << itdms
      
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
    rows << [zero,one,two,three,four]
  end



end
