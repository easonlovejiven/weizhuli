# -*- encoding : utf-8 -*-
class WeiboUserApiTopicRankExportor < ExportorBase

  description <<EOF
    接口根据uid列表 导出用户话题排行
    数据包括:
    "话题" "话题排行"
EOF

  title '用户话题排行(根据uids)'

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

  export name:"话题列表" do |ins,opts|
    ins.export_weibo_user_topic_rank_api(@uids)
  end

  #导出关键词列表
  
  def export_weibo_user_topic_rank_api(uids)
    task = GetUserTagsTask.new
    rows << %w{话题 数量}
    uids = uids.uniq
    topics = []
    status = {}
    uids.each do |uid|
      begin
        res = task.stable{task.api.statuses.user_timeline(uid:uid,count:100)}
        res['statuses'].each{|w|
          #url = "http://weibo.com/#{uid}/#{WeiboMidUtil.mid_to_str(w.id.to_s)}"
          content = w.text
           if content.include?("#")
            content=~/.*#(.*)#.*/ 
            topic = $1 #匹配话题
            topics << topic         
          end
        }
        rescue Exception=>e
          puts e.message
          if e.message =~ /User does not exists!/
            rows << [uid,"此用户已被屏蔽"]
        end
      end
    end
  
    #给hash赋值
    topics.each do |topic|
      status[topic] = 0
    end
    
    #统计
    topics.each do |topic|
      next if topic.nil? 
        if status[topic].blank?
          status[topic] = 0 
        end
          status[topic] += 1
    end
    #打印排序
     status.sort{|a,b| b[1]<=>a[1]}.each do |line|
        rows << line
    end
  end  
end
