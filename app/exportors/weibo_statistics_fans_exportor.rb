# -*- encoding : utf-8 -*-
class WeiboStatisticsFansExportor < ExportorBase
description <<EOF
  查看 监控帐号  统计互动粉丝数
  数据列包括:
   UID 昵称 互动粉丝总数 互动新粉丝数
EOF
  title "统计互动粉丝数(uid)范范"   



  before do |this,opts|
    #TODO:
    @start_time = opts[:start_time]
    @end_time = opts[:end_time]
    @uids = case 
            when opts[:uids].is_a?(String)
              opts[:uids].split("\r\n").map{|line| line.blank? ? nil : line.strip}.compact
            when opts[:uids].is_a?(Array)
              opts[:uids]
            else
            end
  end

  export name:"统计互动粉丝数" do |ins,opts|
    ins.export_weibo_statistics_fans(@uids,@start_time,@end_time)
  end

  
  def export_weibo_statistics_fans(uids,start_time,end_time)
  uidsc = [2637370927,1340241374,2295615873,2637370247,1738056157,2619244577,2183473425,1617785922,1765189187,1687053504,1747360663,1847000261,1942473263,1785529887,2216786767,1883832215,1775695331,2030206793]

  #UID[2637370927,1340241374,2295615873,2637370247,1738056157,2619244577,2183473425,1617785922,1765189187,1687053504,1747360663,1847000261,1942473263,2216786767,1883832215,1775695331,2030206793]
  #昵称 英特尔中国 英特尔中国天天事 英特尔商用频道 超极本 Qualcomm中国 Snapdragon骁龙 联想 ThinkPad 东芝电脑 戴尔中国 ASUS华硕 惠普电脑 杜蕾斯官方微博  ARM中国 AMD中国 Acer宏碁 英特尔新极客
  
       !uids.blank?? uids=uids : uids = uidsc  
        start_time = start_time
        end_time = end_time
          rows << %w{UID 昵称 互动粉丝总数 互动新粉丝数}
          uids.each do |line|
            intel = line
            fans = []
            newfans = []
            forwards = WeiboForward.where("uid = ?  and forward_at between ? and ? ",intel,start_time,end_time)
            comments = WeiboComment.where("uid = ?  and comment_at between ? and ? ",intel,start_time,end_time)
            forwards.each{|forward|
              uid = forward.forward_uid
              rel = WeiboUserRelation.where(uid:intel,by_uid:uid).first
              rel = rel ? (
                      rel.follow_time ? (
                        rel.follow_time >= start_time.to_date ? "新" : "老"
                      ) : "老"
                    ) : ""
              if (rel == "老")||(rel == "新")
                 fans << uid
              end
              if (rel == "新")
                 newfans << uid
              end
            }
            comments.each{|comment|
              uid = comment.comment_uid
              rel = WeiboUserRelation.where(uid:intel,by_uid:uid).first
              rel = rel ? (
                      rel.follow_time ? (
                        rel.follow_time >= start_time.to_date ? "新" : "老"
                      ) : "老"
                    ) : ""
              if (rel == "老")||(rel == "新")
                 fans << uid
              end
              if (rel == "新")
                 newfans << uid
              end
            }
            account = WeiboAccount.find_by_uid(intel)
            rows << [intel,account.screen_name,fans.uniq.size,newfans.uniq.size]
          end
          
  end

 
 
   

end
