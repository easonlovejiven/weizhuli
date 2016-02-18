# -*- encoding : utf-8 -*-
class WeiboUserApiKeywordsRankExportor < ExportorBase

  description <<EOF
    接口根据uid列表 导出用户关键词排行
    数据包括:
      "关键词" "关键词排行"
EOF

  title '用户关键词排行(根据uids)'

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

  export name:"关键词列表" do |ins,opts|
    ins.export_weibo_user_keywords_rank_api(@uids)
  end

  #导出关键词列表
  
  def export_weibo_user_keywords_rank_api(uids)
    rows << %w{关键词 关键词数量}
    all_keywords = {}
    url = "http://www.tfengyun.com/user.php?action=keywords&userid="
    task = GetUserTagsTask.new
    uids.each_with_index do |uid,index|
      begin
        res = task.stable{Net::HTTP.get URI.parse(url+uid.to_s)}
        keywords = JSON.parse(res)
        puts "#{index} : #{keywords['keywords']}"
        keywords['keywords'].each do |kw|
          all_keywords[kw] ||= 0 #当没有关键词时(all_keywords == nill)时 将0赋给这个变量 all_keywords[kw]
          all_keywords[kw] += 1
        end
        rescue Timeout::Error,JSON::ParserError
          puts "#{uid} Timeout Error"
          puts "A JSON text must at least contain two octets!"
        end
      end
      all_keywords.sort{|a,b| b[1]<=>a[1]}.each{|line|
      rows << line
    }
  end  
end
