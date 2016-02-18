# -*- encoding : utf-8 -*-
class WeiboUserApiLabelRankExportor < ExportorBase

  description <<EOF
    接口根据uid列表 导出用户标签排行
    数据包括:
      "标签" "标签排行"
EOF

  title '用户标签排行(根据uids)'

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

  export name:"标签列表" do |ins,opts|
    ins.export_weibo_user_label_rank_api(@uids)
  end

  #导出关键词列表
  
    def export_weibo_user_label_rank_api(uids)
    rows << %w{标签 标签数量}
    all_tags = {}
    task = GetUserTagsTask.new
    uids.in_groups_of(20).each do |uid|
      res = task.stable{task.api.tags.tags_batch uid.compact*","}
      res.each{|tag|
          tags = tag.tags
          tags.each{|info|
            info.delete "weight"
            tag_name = info.to_a.first[1]
            all_tags[tag_name] ||= 0
            all_tags[tag_name] += 1
          }
        }
  end
  all_tags.sort{|a,b| b[1]<=>a[1]}.each{|line|
        rows << line
      }
  end  
end
