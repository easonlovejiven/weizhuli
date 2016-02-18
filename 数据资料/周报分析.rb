#周报代码分析

#调用周报这个方法的参数为
  m = MonitWeiboAccount.find_by_uid(1687399850)
  m.send_weekly_report '2015-02-03'
#(1)微薄，粉丝概况
  filename = "本周微薄,粉丝概况"
  CSV.open filename,"wb" do |csv|
    
    #上上周的日期安排@last_week_start_date,@last_week_end_date
    #上周的日期安排
    #两周时间安排
    @end_date = "2015-02-03".to-date
    @start_date = "2015-01-28".to_date
    
    @last_week_end_date = "2015-01-28".to_date
    @last_week_start_date = "2015-01-21".to_date
    rows = []
    
    @compares_uids = [1687399850,2789871777,3231479672,1990514482,5236823068,1653196740] #存放竞品和主帐号的uid
    
    last_week = @end_date-1.day
    last_2_week = @last_week_end_date-1.day
    
    # init objects
    @compare_uids.each{|uid|
      @compares[uid.to_s][:last_week_account] = WeiboAccountSnapDaily.new
      @compares[uid.to_s][:last_2_week_account] = WeiboAccountSnapDaily.new
      @compares[uid.to_s][:last_week_content] = WeiboContentCountSnapDaily.new #每个帐号的微薄内容信息,每天都会更新一次
      @compares[uid.to_s][:last_2_week_content] = WeiboContentCountSnapDaily.new
    }

    records = WeiboAccountSnapDaily.where(["uid in (?) and date in (?)", @compare_uids, [last_week,last_2_week]]).all

    records.each{|snap|
      @compares[snap.uid.to_s][:last_week_account] = snap if snap.date == last_week
      @compares[snap.uid.to_s][:last_2_week_account] = snap if snap.date == last_2_week
    }

    WeiboAccountSnapDaily.
      where(["uid in (?) and date >= ? and date < ?", @compare_uids, @start_date,@end_date]).
      group("uid").
      select("uid, sum(new_fans_count) new_fans_count").
      all.each{|record|
        @compares[record.uid.to_s][:last_week_account].try(:new_fans_count=, record.new_fans_count)
      }
    
    WeiboAccountSnapDaily.
      where(["uid in (?) and date >= ? and date < ?", @compare_uids, @last_week_start_date,@last_week_end_date]).
      group("uid").
      select("uid, sum(new_fans_count) new_fans_count").
      all.each{|record|
        @compares[record.uid.to_s][:last_2_week_account].try(:new_fans_count=, record.new_fans_count)
      }
    
    records = WeiboContentCountSnapDaily.where(["uid in (?) and date in (?)", @compare_uids, [last_week,last_2_week]]).all
    
    records.each{|snap|
      @compares[snap.uid.to_s][:last_week_content] = snap if snap.date == last_week
      @compares[snap.uid.to_s][:last_2_week_content] = snap if snap.date == last_2_week
    }

    WeiboContentCountSnapDaily.
      where(["uid in (?) and date >= ? and date < ?", @compare_uids, @start_date,@end_date]).
      group("uid").
      select("uid, sum(new_statuses_count) new_statuses_count,sum(forward_count) forward_count, sum(origin_count) origin_count").
      all.each{|record|
        @compares[record.uid.to_s][:last_week_content].try(:new_statuses_count=, record.new_statuses_count)
        @compares[record.uid.to_s][:last_week_content].try(:forward_count=, record.forward_count)
        @compares[record.uid.to_s][:last_week_content].try(:origin_count=, record.origin_count)
      }
    
    WeiboContentCountSnapDaily.
      where(["uid in (?) and date >= ? and date < ?", @compare_uids, @last_week_start_date,@last_week_end_date]).
      group("uid").
      select("uid, sum(new_statuses_count) new_statuses_count,sum(forward_count) forward_count, sum(origin_count) origin_count").
      all.each{|record|
        @compares[record.uid.to_s][:last_2_week_content].try(:new_statuses_count=, record.new_statuses_count)
        @compares[record.uid.to_s][:last_2_week_content].try(:forward_count=, record.forward_count)
        @compares[record.uid.to_s][:last_2_week_content].try(:origin_count=, record.origin_count)
      }
    
    
    WeiboForward.
      joins("left join weibo_details d on d.weibo_id = weibo_forwards.weibo_id").
      where("d.uid in (?) and d.post_at between ? and ?", @compare_uids, @start_date,@end_date).
      group("d.uid").
      select("d.uid,count(1) new_weibo_forwards").
      all.each{|record|
        @compares[record.uid.to_s][:last_week_content].try(:new_weibo_forwards=, record.new_weibo_forwards)
      }

    WeiboForward.
      joins("left join weibo_details d on d.weibo_id = weibo_forwards.weibo_id").
      where("d.uid in (?) and d.post_at between ? and ?", @compare_uids, @last_week_start_date,@last_week_end_date).
      group("d.uid").
      select("d.uid,count(1) new_weibo_forwards").
      all.each{|record|
        @compares[record.uid.to_s][:last_2_week_content].try(:new_weibo_forwards=, record.new_weibo_forwards)
      }
   #本周转发/评论
    WeiboForward.where("uid in (?) and forward_at between ? and ?", @compare_uids, @start_date,@end_date).group("uid").
select("uid,count(1) new_forwards").all.each{|record|
        @compares[record.uid.to_s][:last_week_content].try(:new_forwards=, record.new_forwards)
      }
    WeiboComment.where("uid in (?) and comment_at between ? and ?", @compare_uids, @start_date,@end_date).group("uid").
select("uid,count(1) new_comments").all.each{|record|
        @compares[record.uid.to_s][:last_week_content].try(:new_comments=, record.new_comments)
      }
   #上周转发/评论
    WeiboForward.where("uid in (?) and forward_at between ? and ?", @compare_uids, @last_week_start_date,@last_week_end_date).group("uid").select("uid,count(1) new_forwards").all.each{|record|
      @compares[record.uid.to_s][:last_2_week_content].try(:new_forwards=, record.new_forwards)
      }
    WeiboComment.where("uid in (?) and comment_at between ? and ?", @compare_uids, @last_week_start_date,@last_week_end_date).group("uid").select("uid,count(1) new_comments").all.each{|record|
      @compares[record.uid.to_s][:last_2_week_content].try(:new_comments=, record.new_comments)
      }
    
  #新增代码

    WeiboComment.
      joins("left join weibo_details d on d.weibo_id = weibo_comments.weibo_id").
      where("d.uid in (?) and d.post_at between ? and ?", @compare_uids, @start_date,@end_date).
      group("d.uid").
      select("d.uid,count(1) new_weibo_comments").
      all.each{|record|
        @compares[record.uid.to_s][:last_week_content].try(:new_weibo_comments=, record.new_weibo_comments)
      }

    WeiboComment.
      joins("left join weibo_details d on d.weibo_id = weibo_comments.weibo_id").
      where("d.uid in (?) and d.post_at between ? and ?", @compare_uids, @last_week_start_date,@last_week_end_date).
      group("d.uid").
      select("d.uid,count(1) new_weibo_comments").
      all.each{|record|
        @compares[record.uid.to_s][:last_2_week_content].try(:new_weibo_comments=, record.new_weibo_comments)
      }

    # generate sheet 
    csv = %w{帐号 本周新增粉丝 上周新增粉丝 本周粉丝总数 上周粉丝总数 本周发布微博 本周发布微博被转发 本周发布微博被评论 本周转发数 本周评论数 本周原创微博数量 本周转发的微博 上周发布发博 上周发布发博被转发 上周转发数 上周原创微博数量  本周转发的微博 上周发布发博被评论 } #添加了“本周发布微博被评论 ”&“上周发布微博被评论 ”两项 本周发布微博总数  本周转发的微博
    row = 0
    week_fans = ['本周粉丝总数']
    week2_fans = ['上周粉丝总数']
    engagement = ['互动量（等于转发+评论）']
    original_number = ['发布微博数量']
    forward_number = ['转发微博数量']
    new_fans = ['新增粉丝数量']
    sheet_set sheet, row,0, title
    @compare_uids.each_with_index{|uid,idx|
      row += 1
      values = @compares[uid]
      week_fans << values[:last_week_account].try(:followers_count)
      week2_fans << values[:last_2_week_account].try(:followers_count)
       if values[:last_week_content].try(:new_weibo_forwards).nil? || values[:last_week_content].try(:new_weibo_comments)
          engagement << 0
       else
          engagement << values[:last_week_content].try(:new_weibo_forwards).to_i+values[:last_week_content].try(:new_weibo_comments).to_i 
       end
      original_number << values[:last_week_content].try(:origin_count)
      forward_number << values[:last_2_week_content].try(:new_statuses_count).to_i-values[:last_2_week_content].try(:origin_count).to_i
      new_fans << values[:last_week_account].try(:new_fans_count)
      rows = [
        values[:infos].try(:screen_name), 
        values[:last_week_account].try(:new_fans_count), 
        values[:last_2_week_account].try(:new_fans_count), 
        values[:last_week_account].try(:followers_count), 
        values[:last_2_week_account].try(:followers_count), 
        values[:last_week_content].try(:new_statuses_count), 
        values[:last_week_content].try(:new_weibo_forwards), 
        values[:last_week_content].try(:new_weibo_comments),#添加了“本周发布微博被评论
        values[:last_week_content].try(:new_forwards),   #本周转发  
        values[:last_week_content].try(:new_comments),   #本周转发  
        values[:last_week_content].try(:origin_count), 
        values[:last_week_content].try(:new_statuses_count).to_i - values[:last_week_content].try(:origin_count).to_i, #本周转发的微博
        values[:last_2_week_content].try(:new_statuses_count), 
        values[:last_2_week_content].try(:new_weibo_forwards), 
        values[:last_2_week_content].try(:new_forwards), #上周转发
        values[:last_2_week_content].try(:origin_count), 
        values[:last_2_week_content].try(:new_statuses_count).to_i - values[:last_2_week_content].try(:origin_count).to_i,#上周转发的微博
        values[:last_2_week_content].try(:new_weibo_comments),#添加了上周发布微博被评论
      ]
    }
     csv << %w{帐号 	英特尔中国	  英特尔中国天天事 	英特尔商用频道	 超极本 	高通中国	  Snapdragon骁龙	  联想	  ThinkPad	  东芝电脑	  戴尔中国	  ASUS华硕	  惠普电脑  杜蕾斯官方微博	  戴尔促销	  ARM中国	  AMD中国	  Acer宏碁	  英特尔新极客}
     csv << rows
    records
  end
