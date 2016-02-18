# -*- encoding : utf-8 -*-
class WeiboCengjiExportor < ExportorBase

  description <<EOF
    接口根据url列表 导出微博传播层级
EOF

  title '微博传播层级(根据urls)'

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

  export name:"微博传播层级" do |ins,opts|
    ins.exportor_weibo_cengji_api(@urls)
  end

  #导出关注列表

  def exportor_weibo_cengji_api(urls)
  
    rows << %w{URL 平均传播层级}
    
    urls.each do |url|
      
      #先更新每条微薄
      weibo_id = WeiboMidUtil.str_to_mid URI.parse(url.strip).path.split("/").last
      WeiboForward.analyze_tree(weibo_id)
      
      weibo_id = WeiboMidUtil.str_to_mid URI.parse(url.strip).path.split("/").last
      records = WeiboForwardRelation.find_by_sql <<-EOF
        select depth,count(*) as num from weibo_forward_relations where weibo_id = #{weibo_id} group by depth 
      EOF
      a = 0
      b = 0
      records.each do |line|
        if line.depth != 0
          a = a + line.depth*line.num
          b = b + line.num
        end
      end
      if b != 0
        c = a.to_f/b.to_f
          rows << [url,c] 
        elsif
          rows << [url,0]
      end
    end
  end

end

