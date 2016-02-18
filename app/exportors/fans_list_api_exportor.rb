# -*- encoding : utf-8 -*-
class FansListApiExportor < ExportorBase

  description <<EOF
  接口根据UID列表 导出粉丝 详情列表
  数据列包括:
    粉丝基本信息
EOF
  title "接口提取粉丝列表(根据uids)"  #文件名字 ExportFansListExportor.new.export({uids:[],start_time:"",end_time:""})



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

  export name:"粉丝列表" do |ins,opts|
    ins.export_fans_list_api(@uids)
  end

  


# 接口导出 uids 的粉丝列表
  def export_fans_list_api(uids)   
     task = GetUserTagsTask.new
       titles = ['主号uid']+ WeiboAccount.to_row_title(:full)
       rows << titles
       uids.each do|id|
          target_id = id
          begin
          friend_ids = task.stable{task.api.friendships.followers_ids(:uid=>target_id, :count=>5000).ids} 
          rescue Exception=>e
            puts 'error:类'
            if e.message =~ / for this time/
              sleep(300)
            end
            rows << [target_id]
            next
          end
          friend_ids.each do|uid|
            begin
              account = task.load_weibo_user(uid)
            rescue Exception=>e
              if e.message =~ / for this time/
                sleep(300)
              end
              rows << [target_id,uid]
              next
            end
            next if account.blank?
            rows << [target_id]+ account.to_row(:full)
          end
       end 
  end
 
end
