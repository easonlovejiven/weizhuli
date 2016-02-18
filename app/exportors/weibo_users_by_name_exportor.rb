# -*- encoding : utf-8 -*-
class WeiboUsersByNameExportor < ExportorBase
description <<EOF
  根据name OR uid 导出微博用户 详情列表
  数据列包括:
    user基本信息
EOF
  title "用户基本信息(根据name OR uid)"  #文件名字 ExportFansListExportor.new.export({uids:[],start_time:"",end_time:""})



  before do |this,opts|
    #TODO:
    @start_time = opts[:start_time]
    @end_time = opts[:end_time]
    @names = case 
            when opts[:names].is_a?(String)
              opts[:names].split("\r\n").map{|line| line.blank? ? nil : line.strip}.compact
            when opts[:names].is_a?(Array)
              opts[:names]
            else
            end
    @with_interations = opts[:with_interations]

  end

  export name:"用户列表" do |ins,opts|
    ins.export_weibo_users(@names)
  end

  
  def export_weibo_users(names)
    puts names*','
    task = GetUserTagsTask.new
    rows << %w{ UID 昵称 位置 性别 粉丝 关注 微博 注册时间 认证类型 认证原因 }
    if names[0].to_i > 1000
      names.each{ |uid|
         begin
         account = task.load_weibo_user(uid.to_i)
         rescue Exception =>e
           if e.message =~ / does not exist!/
              rows << [uid]
              next
           end
         end
        if account.blank?
            rows << [uid]
            next
        end
        rows << account.to_row
      }
    else
      uids = ReportUtils.names_to_uids(names,true)
      uids.each{|uid|
        a = WeiboAccount.find_by_uid uid
        if !a.nil?
          rows << a.to_row
        else
          rows << [uid]
        end
      }
    end
    
  end
 
   

end
