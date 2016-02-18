# -*- encoding : utf-8 -*-
class WeiboUserRelationExportor < ExportorBase

  description <<EOF
    根据 uid 列表判断是否关注另一个微博用户
EOF
  title "判断一批人是否关注主号(根据uids)"


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

  export name:"用户列表" do |ins,opts|
    ins.check_relations(@uid,@uids)
  end


  def check_relations(target_uid,source_uids)
    rows << %w{uid 之前粉主号时间 之前是否是粉丝（Y/N） 现在是否是主号粉丝（Y/N） 主号是否关注他（Y/N）}
    task = GetUserTagsTask.new
    source_uids.each{|uid|
      uid = uid.strip
    fans = WeiboUserRelation.where("uid = ? and by_uid = ?",target_uid,uid).first
    begin
      res = task.api.friendships.show(source_id:uid,target_id:target_uid)
      issourcefans = res.source.followed_by ? "Y" : "N"
      istargetfans = res.source.following ? "Y" : "N"
      if fans.blank?
       rows << [uid,'',"N",istargetfans, issourcefans ]
      else
       followedtime = fans.follow_time.to_s
       isfans = fans.nil?? "N" :"Y"
       rows << [uid,followedtime,isfans,istargetfans, issourcefans]
      end
      rescue Exception=>e
      puts e
      rows << [uid,'','','目标用户不存在','']
    end
    }
    rows
  end


end
