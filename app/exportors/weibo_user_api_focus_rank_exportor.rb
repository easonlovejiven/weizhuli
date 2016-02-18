# -*- encoding : utf-8 -*-
class WeiboUserApiFocusRankExportor < ExportorBase

  description <<EOF
    接口根据UID列表 导出用户共同关注排行
EOF

  title '用户共同关注排行(根据uids)'

  before do |this,opts|
    #TODO:
    @uids = case 
      when opts[:uids].is_a?(String)
        opts[:uids].split("\r\n").map{|line| line.blank? ? nil : line.strip}.compact
      when opts[:uids].is_a?(Array)
        opts[:uids]
      else
      end
  end

  export name:"共同关注列表" do |ins,opts|
    ins.exportor_user_focus_rank_api(@uids)
  end

  #导出关注列表

  def exportor_user_focus_rank_api(uids)
  keywords = {}
  rows << %w{UID 关注数}
  task = GetUserTagsTask.new
    uids.each{|uid|
      uid = uid.strip
      #返回uid关注的用户uids
      begin
        ids = task.api.friendships.friends_ids(uid:uid,count:5000).ids
        ids.each{|id|
          next if id.nil? 
            if keywords[id.to_s].blank?
              keywords[id.to_s] = 0 
            end
              keywords[id.to_s] += 1
        }
        rescue Exception =>e  
          next
      end
    }
      keywords.sort{|a,b| b[1]<=>a[1]}.each do |line|
        rows << line
      end
  end

end


