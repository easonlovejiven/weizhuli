# -*- encoding : utf-8 -*-
class WeiboUsersUsersRelationExportor < ExportorBase

  description <<EOF
    根据 uid 列表判断是否关注一些微博用户
EOF
  title "判断一批人是否关注一些主号(根据uids)"


  before do |this,opts|
    #TODO:
    @uids = case 
            when opts[:uids].is_a?(String)
              opts[:uids].split("\r\n").map{|line| line.blank? ? nil : line.strip}.compact
            when opts[:uids].is_a?(Array)
              opts[:uids]
            else
            end
    @uid = case 
            when opts[:uid].is_a?(String)
              opts[:uid].split("\r\n").map{|line| line.blank? ? nil : line.strip}.compact
            when opts[:uid].is_a?(Array)
              opts[:uid]
            else
            end
  end

  export name:"用户列表" do |ins,opts|
    ins.check_relations(@uid,@uids)
  end


  def check_relations(target_uids,source_uids)
    task = GetUserTagsTask.new
    row = []
    row << "uid"
    target_uids.each do |id|
      begin
        name = task.load_weibo_user(id).screen_name
      rescue Exception=>e
        row << "" 
        next 
      end
      row << "现在是否是#{name}"
    end
    rows << row
    source_uids.each{|uid|
      uid = uid
      row2 = []
      row2 << uid
      begin
        ids = task.api.friendships.friends_ids(uid:uid,count:5000).ids
      rescue Exception=>e
          row2 << ""
          if e.message =~ / for this time/
            sleep(300)
          end
          next
     end
     target_uids.each do |id|
         #res = task.api.friendships.show(source_id:uid,target_id:id)
        istargetfans = ids.include?(id.to_i) ? "Y" : "N"
        row2 << istargetfans
     end

     rows << row2
    }

  end


end
