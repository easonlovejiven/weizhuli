# -*- encoding : utf-8 -*-
class InteractUsersForLastWeek
  
  def self.interact_users_for_last_week_to_xlsx()
          
            title << ["帐号", "用户ID", "昵称", "性别", "粉丝数", "认证类型", "认证原因", "是否我的粉丝", "转发次数", "评论次数", "互动次数", "intel员工", "\"", "\""]
            @list = []
            @list << title
            @uid = 2637370927
            @start_date = Time.now.strftime("%Y-%m-%d ")
            @end_date = (Time.now+7.day).strftime("%Y-%m-%d")
            @filename = "中国微博的互动用户排行#{@start_date}-#{@end_date}.csv"
            employee_keyword = Keyword.where(user_id:1,name:"INTERNAL").first
            key_id = employee_keyword.try(:id)
            records = WeiboUserInteractionSnapDaily.find_by_sql <<-EOF
              select snap.uid, snap.from_uid, rel.uid following,attrs.id is_employee, users.screen_name, users.gender, users.followers_count, users.verified_type,
              forwarded_count, commented_count,interacted_count
              from (
                select uid,from_uid, sum(snap.forwarded_count)  forwarded_count, sum(snap.commented_count) commented_count, sum(snap.forwarded_count)+sum(snap.commented_count) interacted_count
                from weibo_user_interaction_snap_dailies snap
                where snap.date >= '#{@start_date}' and snap.date < '#{@end_date}'
                and snap.uid = #{@uid}
                group by snap.uid, snap.from_uid
                order by snap.uid , sum(snap.forwarded_count)+sum(snap.commented_count) desc
              ) as snap
              left join weibo_accounts users on users.uid = snap.from_uid
              left join weibo_user_relations rel on rel.by_uid = snap.from_uid and rel.uid = #{@uid}
              left join weibo_user_attributes attrs on attrs.uid = snap.from_uid and attrs.keyword_id = #{key_id}
EOF
             records.each{|record|
                uid = record.uid.to_s
                a = MUser.find(record.from_uid)
                @list << [
                                record.screen_name,
                                record.from_uid,
                                record.screen_name,
                                record.gender,
                                record.followers_count,
                                record.verified_type,
                                a.try(:verified_reason),
                                record.following ? "Yes" : "",
                                record.forwarded_count,
                                record.commented_count,
                                record.interacted_count,
                                record.is_employee ? "Yes" : "" #员工
	                                ]

              }
              ReportUtils.list_export(@filename,@list,mail_to:"yafei.fan@weizhuli.com,xiaowen.li@weizhuli.com,yawei.zhang@weizhuli.com")

  end
end
