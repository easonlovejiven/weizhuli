# -*- encoding : utf-8 -*-
class TqqThreeForwardsExportor < ExportorBase

  description <<EOF
  腾讯根据urls列表 导出二次转评 ,是否三次转发 
  数据列包括:
   url 内容 转发 评论 是否三次转发 
EOF


  title "腾讯导出二次转评,是否三次转发(根据urls)"


  before do |this,opts|
    #TODO:
    @urls = case 
            when opts[:urls].is_a?(String)
              opts[:urls].split("\r\n").map{|line| line.blank? ? nil : line.strip}.compact
            when opts[:urls].is_a?(Array)
              opts[:urls]
            else
            end

  end

  export interactive:"腾讯导出二次转评/是否三次转发" do |ins,opts|
    ins.export_three_forwards(@urls)
  end


 #根据url查微博 信息（王娟） 二次转发 是否三次转发 
  def export_three_forwards(urls)
  debugger
      task = MonitTqqAccount.first.get_weibo_task
      rows << %w{url 内容 转发 评论 是否三次转发 }
      urls.each do|url|
      weibo_id = url.split('/').last
         puts weibo_id
         #a = TqqWeiboDetail.find_by_weibo_id(weibo_id)  #264237057346107
         #a = MTqqForward.find(weibo_id) 
         res = task.stable{task.api.t.show(weibo_id.to_s)}#320849031175070 
         if res.data.nil?
           rows << [url]
           next
         end
          content = res.data.text
          content.to_s.split('||').size > 1 ? isforward = '是' : isforward = '否'
        rows << ['http://t.qq.com/p/t/'+weibo_id.to_s,res.data.text,res.data[:count],res.data.mcount,isforward]
      end

  end



end
