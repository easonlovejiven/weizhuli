# -*- encoding : utf-8 -*-
class ExportWeiboListExportor < ExportorBase

  description <<EOF
  接口导出
  根据UID列表 导出微博 详情列表
  数据列包括:
    微博基本信息

EOF
  title "微博列表导出"


  before do |this,opts|
    #TODO:
    @start_time = opts[:start_time]
    @end_time = opts[:end_time]
    @uids = case 
            when opts[:uids].is_a?(String)
              opts[:uids].split("\n").map{|line| line.blank? ? nil : line.strip}.compact
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
    
      self << %w{name 微博内容 发布时间 转发数 评论数 互动总数 URL 原创 发布来源  }
      
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
              next if w.id == top_id
              puts w.created_at
              next if end_time && Time.parse(w.created_at) > end_time
              if Time.parse(w.created_at) > start_time

                srouce = ActionView::Base.full_sanitizer.sanitize(w.source) #去出所有的标签

                url = "http://weibo.com/#{uid}/#{WeiboMidUtil.mid_to_str(w.id.to_s)}"

                post_at = Time.parse(w.created_at).strftime("%Y-%m-%d %H:%M")
                count = w.reposts_count + w.comments_count
                origin = !w.retweeted_status
                self << [w.user.screen_name, w.text,post_at, w.reposts_count, w.comments_count,count, url,origin, srouce]

              else
                processing = false
                break
              end
            }
            processing ? res.total_number : 0
          rescue Exception=>e
            puts e.message
          end
        end
      }

   
  end




end
