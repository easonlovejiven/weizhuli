# -*- encoding : utf-8 -*-
class WeiboUsersApiByUid < ExportorBase
description <<EOF
  接口 根据uid 导出微博用户 详情列表
  数据列包括:
    "UID", "昵称", "位置", "性别", "粉丝", "关注", "微博","互粉数","注册时间", "认证信息", "认证原因", "备注", "标签","近1条微博时间"
EOF
  title "接口导出用户基本信息(根据uid)"

  before do |this,opts|
    #TODO:
    @uids = case 
            when opts[:uids].is_a?(String)
              opts[:uids].split("\r\n").map{|line| line.blank? ? nil : line.strip}.compact
            when opts[:uids].is_a?(Array)
              opts[:uids]
            else
            end
    @with_interations = opts[:with_interations]
  end

  export name:"用户列表" do |ins,opts|
    ins.export_weibo_users_by_api(@uids)
  end

  
  def export_weibo_users_by_api(uids)
    task = GetUserTagsTask.new
    rows << WeiboAccount.to_row_title(:full)+["近1条微博时间"] 
    uids.each do|line|
       uid = line
       begin #解决异常
         res = task.stable{task.api.users.show(uid:uid)}
         if !res.blank?
            account = task.save_weibo_user(res)
          else
            rows << [uid]
            next
         end
        rescue Exception=>e
          rows << [uid]
          next
        end
        if res.status.nil?
          rows << account.to_row(:full)
          next
        end
       rows << account.to_row(:full) + [DateTime.parse(res.status.created_at).strftime("%Y-%m-%d %H:%S")]
    end
  end
  
end
