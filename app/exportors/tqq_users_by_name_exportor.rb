# -*- encoding : utf-8 -*-
class TqqUsersByNameExportor < ExportorBase
description <<EOF
  腾讯根据 openid 导出微博用户 详情列表
  数据列包括:
    "openid", "name", "nick", "微博", "收听", "听众", "location", "创建时间", "性别", "经验", "等级", "是否实名认证", "vip", "认证类型", "标签", "活跃度"
EOF
  title "腾讯用户基本信息(根据openid)"  


  before do |this,opts|
    #TODO:
    @openids = case 
            when opts[:openids].is_a?(String)
              opts[:openids].split("\r\n").map{|line| line.blank? ? nil : line.strip}.compact
            when opts[:openids].is_a?(Array)
              opts[:openids]
            else
            end
    @with_interations = opts[:with_interations]

  end

  export name:"用户列表" do |ins,opts|
    ins.export_tqq_users(@openids)
  end

  
  def export_tqq_users(openids)
    task = GetTqqBasicTask.new
    rows << TqqAccount.to_row_titles(:full)
    openids.each do|openid|
       row = []
       openid = openid.strip
       account = task.load_weibo_user(openid:openid)
       row = account.nil? ? [openid] : account.to_row(:full)
       user = MTqqUser.find(openid)
       row << user.nil? ? nil : user.verifyinfo
       rows << row 
    end
    
  end
 
   

end
