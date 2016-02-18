# -*- encoding : utf-8 -*-
class WeiboUsersEvaluateExportor < ExportorBase
description <<EOF
  查看 互动量
  数据列包括:
   uid 平均转发率 平均评论率 平均转发 平均评论 活跃度 原创占比
EOF
  title "用户互动量(根据name OR uid)"   



  before do |this,opts|
    #TODO:
    @names = case 
            when opts[:names].is_a?(String)
              opts[:names].split("\r\n").map{|line| line.blank? ? nil : line.strip}.compact
            when opts[:names].is_a?(Array)
              opts[:names]
            else
            end

  end

  export name:"互动量列表" do |ins,opts|
    ins.export_weibo_users_evaluate(@names)
  end

  
  def export_weibo_users_evaluate(names)
    uids = names
    task = GetUserTagsTask.new
    rows << %w{uid 平均转发率 平均评论率 平均转发 平均评论 活跃度 原创占比 日均发帖量 近七天发贴量}
    if names[0].to_i == 0
      uids = ReportUtils.names_to_uids(names,true)
    end
    uids.each do|line|
       row = []
       uid = line
       puts uid
       weiboEvaluates = WeiboUserEvaluate.where("uid = ?",uid).first
       if weiboEvaluates.nil? || weiboEvaluates.origin_rate == -1
          begin
          weiboEvaluates= WeiboAccount.find_by_uid(uid).update_evaluates
          rescue IRB::Abort
                raise $!
              rescue Exception=>e
                puts e.message
                rows << [uid]
                next
          end
       end
       evaluates =   weiboEvaluates.forward_average + weiboEvaluates.comment_average
       puts evaluates
       row << uid
       row << weiboEvaluates.forward_rate/100.0
       row << weiboEvaluates.forward_rate/100.0
       row << weiboEvaluates.forward_average/100.0
       row << weiboEvaluates.comment_average/100.0
       row << evaluates/100.0
       row << weiboEvaluates.origin_rate
       row << weiboEvaluates.day_posts
       row << weiboEvaluates.day_posts_in_week
       rows << row
    end
    
  end

 
 
   

end
