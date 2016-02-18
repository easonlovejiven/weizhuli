# -*- encoding : utf-8 -*-
class Client::ReportsController < Client::ApplicationController



  def index
    @uid = "2637370927"
    @related_uids = [2637370927, 1340241374, 2637370247, 2030206793, 2295615873]
    last_week = Date.parse("Monday")-7.day
    @last_week_date = last_week
  
  
    # 4
    @fans_summary_weekly = WeiboAccountSnapWeekly.where(["uid = ?",@uid]).order("date desc").limit(2)
    # 4
    @contents_summary_weekly = WeiboContentCountSnapWeekly.where(["uid = ?",@uid]).order("date desc").limit(2)
    
    # 14
    @weibo_contents_list = WeiboDetail.where(["weibo_details.uid=? and weibo_details.post_at >= ?", @uid, @last_week_date]).order("(reposts_count+comments_count) desc ")
    
    # 6
    @related_fans_summary_weekly = WeiboAccount.joins("left join weibo_account_snap_weeklies asw on asw.uid = weibo_accounts.uid left join weibo_content_count_snap_weeklies csw on csw.uid = weibo_accounts.uid").where(["csw.date = ? and asw.date = ? and weibo_accounts.uid in (?)",@last_week_date,@last_week_date, @related_uids])
    # 12
    @related_fans_increase_2_weekly = WeiboContentCountSnapWeekly.where(["uid in (?) and date >= ?",@related_uids, @last_week_date-2.week]).order("date desc").limit(2)
    # 7
    @related_fans_increase_daily = WeiboAccountSnapDaily.where(["date >= ? and date < ? and uid in (?)",@last_week_date,@last_week_date+7.day, @related_uids])
    # 8
    @fans_valid_types_last_week = WeiboAccount.joins("left join weibo_user_relations ur on ur.by_uid = weibo_accounts.uid").where(["ur.uid = ? and ur.created_at >= ?", @uid, @last_week_date]).group("verified_type").select("verified_type, count(1) counts")
    
    # 9
    @fans_locations_last_week = WeiboAccount.joins("left join weibo_user_relations ur on ur.by_uid = weibo_accounts.uid").where(["ur.uid = ? and ur.created_at >= ?", @uid, @last_week_date]).group("province").select("province, count(1) counts")
    # 9
    @fans_of_fans_last_week = WeiboAccount.joins("left join weibo_user_relations ur on ur.by_uid = weibo_accounts.uid").where(["ur.uid = ? and ur.created_at >= ?", @uid, @last_week_date]).group("fans_level").select("case when weibo_accounts.followers_count < 20 then 1 when followers_count >= 20 and followers_count < 50  then 2 when followers_count >= 50 and followers_count < 100  then 3 when followers_count >= 100 and followers_count < 500  then 4 when followers_count >= 500 and followers_count < 2000  then 5 when followers_count >= 2000 and followers_count < 10000  then 6 when followers_count >= 10000  then 7 end as fans_level, count(1) counts")
    
    # 10
    @top_kols = WeiboAccount.joins("left join weibo_user_relations ur on ur.by_uid = weibo_accounts.uid").where(["ur.uid = ? and ur.created_at >= ?", @uid, @last_week_date]).order("weibo_accounts.followers_count desc").limit(15)
    
    # 13
    @interactive_hourly = WeiboUserInteractionSnapHourly.where(["uid  = ? and date >= ?", @uid, @last_week_date]).group("hour").select("hour, count(1) counts")
    
    # 17
    @interactive_per_account = WeiboUserInteractionSnapWeekly.where(["uid = ? and date >= ?", @uid, @last_week_date]).group("uid").select("uid, sum(interacted_count) interacted")
    
    #18
    @interaction_daily = WeiboUserInteractionSnapDaily.where(["uid = ? and date >= ?",@uid, @last_week_date]).group("date").select("date, sum(interacted_count) interacted")
  end

end
