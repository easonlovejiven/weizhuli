# -*- encoding : utf-8 -*-
class TqqListApiCountentExportor < ExportorBase

  description <<EOF
  腾讯根据urls列表 导出微博互动列表 
  数据列包括:
    "openid", "name", "nick", "微博", "收听", "听众", "location", "创建时间", "性别", "经验", "等级", "是否实名认证", "vip", "认证类型", "标签", "互动时间", "内容", "互动微博URL", "动作", "原微博url"
EOF


  title "腾讯导出微博互动信息列表(根据urls)"


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

  export interactive:"腾讯互动信息列表" do |ins,opts|
    ins.export_interactive(@urls)
  end


 
  def export_interactive(urls)
      #根据微博id weibo_id url查互动人信息 互动信息（王娟）
      task = GetTqqBasicTask.new
      rows << TqqAccount::to_row_titles + ['互动时间','内容','互动微博URL','动作','原微博url']
        urls.each do|line|
              per_page = 100
              id = line.split('/').last
              begin
                reposts =  task.stable{task.api.t.re_list({pageflag:0,flag:0,rootid:id,:reqnum=>per_page,:pagetime=>0,:twitterid=>0})}
              rescue Exception=>e
                  next
              end
              if !reposts.data.nil?
                 (reposts.data.info || []).reverse.each{|repost|
                   row = []
                   account = task.load_weibo_user(openid:repost.openid)
                   next if account.nil?
                   row = account.to_row
                   row << Time.at(repost.timestamp)
                   row << repost.text
                   row << 'http://t.qq.com/p/t/'+repost.id.to_s
                   row << '转发'
                   row << 'http://t.qq.com/p/t/'+id.to_s
                   rows << row
                }         
                if reposts.data.info.size == 100
                  pagetime = reposts.data.info.last.timestamp
                  twitterid = reposts.data.info.last.id
                  while true
                    # get new reposts from server
                    begin
                      reposts_results = task.stable{task.api.t.re_list({pageflag:1,flag:0,rootid:id,:reqnum=>per_page,:pagetime=>pagetime,:twitterid=>twitterid})}
                      reposts_results_ok = reposts_results.try(:data).try(:info)
                    rescue Exception=>e
                      break
                    end
                    (reposts_results_ok || []).reverse.each{|repost|
                       row = []
                       account = task.load_weibo_user(openid:repost.openid)
                       next if account.nil?
                       row = account.to_row
                       row << Time.at(repost.timestamp)
                       row << repost.text
                       row << 'http://t.qq.com/p/t/'+repost.id.to_s
                       row << '转发'
                       row << 'http://t.qq.com/p/t/'+id.to_s
                       rows << row
                    }
                    break if  reposts_results.data.try(:hasnext) == 1
                    pagetime = reposts_results_ok.last.timestamp
                    twitterid = reposts_results_ok.last.id
                  end
                end 
              end
            begin
              comments =  task.stable{task.api.t.re_list({pageflag:0,flag:1,rootid:id,:reqnum=>per_page,:pagetime=>0,:twitterid=>0})}
            rescue Exception=>e
              next
            end
            if !comments.data.nil? 
              (comments.data.info || []).reverse.each{|comment|
                 row = []
                 account = task.load_weibo_user(openid:comment.openid)
                 next if account.nil?
                 row = account.to_row
                 row << Time.at(comment.timestamp)
                 row << comment.text
                 row << 'http://t.qq.com/p/t/'+comment.id.to_s
                 row << '评论'
                 row << 'http://t.qq.com/p/t/'+id.to_s
                 rows << row
              }
              if comments.data.info.size == 100
                pagetime = comments.data.info.last.timestamp
                twitterid = comments.data.info.last.id
                while true      
                    # get new comments from server
                   begin
                      comments_results = stable{task.api.t.re_list({pageflag:1, flag:1, rootid:id, :reqnum=>per_page, :pagetime=>last_comment  })}
                      comments_results_ok = comments_results.try(:data).try(:info)
                    rescue Exception=>e
                      break
                    end
                    (comments_results_ok || []).reverse.each{|comment|
                       row = []
                       account = task.load_weibo_user(openid:comment.openid)
                       next if account.nil?
                       row = account.to_row
                       row << Time.at(comment.timestamp)
                       row << comment.text
                       row << 'http://t.qq.com/p/t/'+comment.id.to_s
                       row << '评论'
                       row << 'http://t.qq.com/p/t/'+id.to_s
                       rows << row
                    }
                    break if  comments_results.data.try(:hasnext) == 1
                    pagetime = comments_results_ok.last.timestamp
                    twitterid = comments_results_ok.last.id
                end
              end
            end

        end

  end



end
