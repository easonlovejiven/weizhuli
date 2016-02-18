# -*- encoding : utf-8 -*-
class WeiboUserInteractiveExportor < ExportorBase

  description <<EOF
    根据 uids 列表与监控人互动次数
EOF
  title "查看一些人与监控帐号互动(根据uids，uid)"

  before do |this,opts|
    #TODO:
    @uids = case 
            when opts[:uids].is_a?(String)
              opts[:uids].split("\r\n").map{|line| line.blank? ? nil : line.strip}.compact
            when opts[:uids].is_a?(Array)
              opts[:uids]
            else
            end
    @uid = opts[:uid]
  end

  export name:"互动" do |ins,opts|
    ins.check_interactive(@uid,@uids)
  end


  def check_interactive(target_uid,source_uids)
    rows << %w{uid 转发主号次数 评论主号次数 互动}
    target_uid = target_uid.strip
    source_uids.each do |line|
    uid = line.strip
    comment_count = WeiboComment.where("uid = ? and comment_uid = ?",z_uid,uid).count("distinct comment_id")
    forward_count = WeiboForward.where("uid = ? and forward_uid = ?",z_uid,uid).count("distinct forward_id")      
    rows << [uid,forward_count,comment_count,forward_count+comment_count]
   end
  end


end
