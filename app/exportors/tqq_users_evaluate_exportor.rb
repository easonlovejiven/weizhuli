# -*- encoding : utf-8 -*-
class TqqUsersEvaluateExportor < ExportorBase
description <<EOF
  腾讯根据 openids 查看 互动量
  数据列包括:
    openid 日均发帖量 活跃度  原创占比 转发率 评论率
EOF
  title "腾讯用户互动量(根据：openid)"   



  before do |this,opts|
    #TODO:
    @openids = case 
            when opts[:openids].is_a?(String)
              opts[:openids].split("\r\n").map{|line| line.blank? ? nil : line.strip}.compact
            when opts[:openids].is_a?(Array)
              opts[:openids]
            else
            end

  end

  export name:"腾讯互动量列表" do |ins,opts|
    ins.export_weibo_users_evaluate(@openids)
  end

  
  def export_weibo_users_evaluate(openids)
    #根据openid名字查看 活跃度 日均发帖量 原创占比(王娟)
      rows << %w{openid 日均发帖量 活跃度  原创占比 转发率 评论率}
      openids.each do|openid|
         #penid = TqqUtils.names_to_openids([name],true)
         # evaluate = TqqAccount.find_by_openid(openid).update_evaluates
         evaluate = TqqUserEvaluate.find_by_openid(openid)
         if evaluate.nil? || evaluate.origin_rate == 0 
             evaluate = TqqAccount.find_by_openid(openid).update_evaluates
         end 
         rows << [openid,evaluate.day_posts,(evaluate.forward_average+evaluate.comment_average)/100.0,evaluate.origin_rate/100.0,evaluate.forward_rate,evaluate.comment_rate]
        end

    
  end

 
 
   

end
