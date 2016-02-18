# -*- encoding : utf-8 -*-
class NamesToUidsExportor < ExportorBase

 description <<EOF
  根据名字列表 导出uid列表
  数据列包括:
    UID
EOF
  title "导出uids(根据微博名)"


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

  export names_to_uids:"用户列表" do |ins,opts|
    ins.names_to_uids(@names)
  end

  def names_to_uids(names)
#debugger
     rows << %w{name uid}
     names.each{|name| 
     uid = ReportUtils.names_to_uids([name],true)#wechengdu
     rows << [name,uid[0]]
     }
  end
end
