# -*- encoding : utf-8 -*-
class ExportWeiboUsersByNameExportor < ExportorBase

  description <<EOF
  根据names列表 导出微博用户 详情列表
  数据列包括:
    user基本信息

EOF
  title "user基本信息"


  before do |this,opts|
    #TODO:
    @start_time = opts[:start_time]
    @end_time = opts[:end_time]
    @uid = case 
            when opts[:uids].is_a?(String)
              opts[:uids].split("\n").map{|line| line.blank? ? nil : line.strip}.compact
            when opts[:uids].is_a?(Array)
              opts[:uids]
            else
            end
    @with_interations = opts[:with_interations]
    @names = opts[:names]

  end

  export users:"用户列表" do |ins,opts|
    ins.export_weibo_users(@names)
  end

 

  def export_weibo_users(names)

    uids = ReportUtils.names_to_uids(names,true)
    
    rows = WeiboAccount.to_row_title
    uids.each{|uid|
      a = WeiboAccount.find_by_uid uid

      if !a.nil?
        ar = a.to_row
      else
        ar = [uid]
      end
      rows << ar
    }
  end




end
