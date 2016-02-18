# -*- encoding : utf-8 -*-
class TqqUserRelationExportor < ExportorBase

  description <<EOF
   腾讯 根据 openids 列表判断是否关注另一个微博用户
EOF
  title "腾讯判断一批人是否关注主号(根据openids)"


  before do |this,opts|
    #TODO:
    @openids = case 
            when opts[:openids].is_a?(String)
              opts[:openids].split("\r\n").map{|line| line.blank? ? nil : line.strip}.compact
            when opts[:openids].is_a?(Array)
              opts[:openids]
            else
            end
    @openid = opts[:openid]
  end

  export name:"腾讯判断是否粉丝" do |ins,opts|
    ins.check_relations(@openid,@openids)
  end


  def check_relations(target_uid,source_uids)
        
        rows << %w{openid  是否关注@主号 关注日期 创建时间}
        source_uids.each do|line|
          intel = target_uid 
          openid = line#.strip#TqqUtils.names_to_openids([name],true)[0]
          relation = TqqUserRelation.where("openid = ? and by_openid = ?",intel,openid)
          if relation.size == 0
            rows << [openid, relation.count > 0 ? "是" : "否",'']
            next
          end
          if relation.first.follow_time.nil?
            rows << [openid, relation.count > 0 ? "是" : "否",'',relation.first.created_at]
            next
          end
          rows << [openid,relation.count > 0 ? "是" : "否",relation.first.follow_time,relation.first.created_at]
        end
  end


end
