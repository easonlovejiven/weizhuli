# -*- encoding : utf-8 -*-
class WeiboInteractives < ExportorBase

  description <<EOF
  根据  uids 列表导出与主帐号互动数 (uid 转发 评论 互动数) 
  数据列包括:
   uid 转发 评论 互动数
    

EOF
  title "互动数(根据uids)"


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
    @with_interations = opts[:with_interations]
    @target_uid = opts[:target_uid]

  end

  export interactive:"互动数" do |ins,opts|
    ins.export_interactive(@start_time,@end_time,@uids,@target_uid)
  end

  def export_interactive(start_time,end_time,uids,target_uid)
   
    rows << %w{uid 转发 评论 互动数}
    intel = target_uid 
    uids.each do |uid|
      uid = uid.strip
      forwards = WeiboComment.where("uid = ? and comment_uid = ? and comment_at between ? and ?",intel,uid,start_time,end_time).count("distinct comment_id")
      comments = WeiboForward.where("uid = ? and forward_uid = ? and forward_at between ? and ?",intel,uid,start_time,end_time).count("distinct forward_id")
      rows << [uid,forwards,comments,forwards+comments]
    end
     
  end

end
