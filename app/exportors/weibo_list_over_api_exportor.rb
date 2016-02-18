# -*- encoding : utf-8 -*-
class WeiboListOverApiExportor < ExportorBase

  description <<EOF
  接口导出
  根据UID列表 导出微博 详情列表
  数据列包括:
    微博基本信息

EOF
  title "接口提取微博列表(根据uids)"


  before do |this,opts|
    #TODO:
    @start_time = opts[:start_time]
    @end_time = opts[:end_time]
    @uids = case 
            when opts[:uids].is_a?(String)
              opts[:uids].split("\r\n").map{|line| line.blank? ? nil : line.strip}.compact
            when opts[:uids].is_a?(Array)
              opts[:uids]
            else
            end
    @with_interations = opts[:with_interations]

  end

  export weibo:"微博列表" do |ins,opts|
    ins.export_weibo(@start_time,@end_time,@uids)
  end

 

  def export_weibo(start_time, end_time, uids)

   task = GetUserTagsTask.new
    
      rows << %w{name 微博内容 发布时间 转发数 评论数 互动总数 URL 原创 发布来源  }
      
      uids.each{|uid|
        puts "Processing uid : #{uid}"
        top_id = nil
        task.paginate(:per_page=>100) do |page|
         
          begin
            res = task.stable{task.api.statuses.user_timeline(uid:uid,count:100, page:page)}
            processing = true
            if page == 1
              if Time.parse(res['statuses'][0].created_at)< Time.parse(res['statuses'][1].created_at)
              top_id = res['statuses'][0].id
              end
             end
            res['statuses'].each{|w|
#debugger
              if w.id == top_id
                srouce = ActionView::Base.full_sanitizer.sanitize(w.source) #去出所有的标签
                url = "http://weibo.com/#{uid}/#{WeiboMidUtil.mid_to_str(w.id.to_s)}"
                post_at = Time.parse(w.created_at).strftime("%Y-%m-%d %H:%M")
                scount = w.reposts_count + w.comments_count
                origin = !w.retweeted_status
                rows << [w.user.screen_name, w.text,post_at, w.reposts_count, w.comments_count,scount, url,origin, srouce]
                next 
              end
              puts w.created_at
              next if end_time && Time.parse(w.created_at) > end_time
              if Time.parse(w.created_at) > start_time
                srouce = ActionView::Base.full_sanitizer.sanitize(w.source) #去出所有的标签
                url = "http://weibo.com/#{uid}/#{WeiboMidUtil.mid_to_str(w.id.to_s)}"
                post_at = Time.parse(w.created_at).strftime("%Y-%m-%d %H:%M")
                scount = w.reposts_count + w.comments_count
                origin = !w.retweeted_status
                text = w.text
                text += "\n----------------------------\n"+w.retweeted_status['text'] if !origin

                rows << [w.user.screen_name, text, post_at, w.reposts_count, w.comments_count,scount, url,origin, srouce]
              else
                processing = false
                break
              end
            }
            processing  &&  page<=20 ? res.total_number : 0
          rescue Exception=>e
            0
          end
        end
      }

   
  end




end
