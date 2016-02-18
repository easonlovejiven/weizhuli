   filename = "上周微薄列表.csv"
   CSV.open filename,"wb" do |csv|
   task = GetUserTagsTask.new
    csv << %w{name 微博内容 发布时间 转发数 评论数 互动总数 URL 原创 发布来源 Tag1 Tag2 Tag3 Tag4 Tag5 Tag6 GEO}
      top_id = nil
      uid = 2637370927
      @start_time = "2015-04-13"
      @end_time = "2015-04-20"
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
          if w.id == top_id
            srouce = ActionView::Base.full_sanitizer.sanitize(w.source) #去出所有的标签
            url = "http://weibo.com/#{uid}/#{WeiboMidUtil.mid_to_str(w.id.to_s)}"
            weibo_id = WeiboMidUtil.str_to_mid URI.parse(url.strip).path.split("/").last #用来获取标签
            post = Post.find_by_weibo_id(weibo_id)
            post_at = Time.parse(w.created_at).strftime("%Y-%m-%d %H:%M")
            scount = w.reposts_count + w.comments_count
            origin = !w.retweeted_status
            row1 = [w.user.screen_name, w.text,post_at, w.reposts_count, w.comments_count,scount,url,origin,srouce]
            if !post.blank?
              row2 << [post.tag1,post.tag2,post.tag3,post.tag4,post.tag5,post.tag6,post.geo]
              rows << row1 + row2
            else
              csv << row1
            end
            next
          end
          puts w.created_at
          next if @end_time && Time.parse(w.created_at) > @end_time
          if Time.parse(w.created_at) > @start_time
            srouce = ActionView::Base.full_sanitizer.sanitize(w.source) #去出所有的标签
            url = "http://weibo.com/#{uid}/#{WeiboMidUtil.mid_to_str(w.id.to_s)}"
            weibo_id = WeiboMidUtil.str_to_mid URI.parse(url.strip).path.split("/").last #用来获取标签
            post = Post.find_by_weibo_id(weibo_id)
            post_at = Time.parse(w.created_at).strftime("%Y-%m-%d %H:%M")
            scount = w.reposts_count + w.comments_count
            origin = !w.retweeted_status
            text = w.text
            text += "\n----------------------------\n"+w.retweeted_status['text'] if !origin
            row1 = [w.user.screen_name, text, post_at, w.reposts_count, w.comments_count,scount, url,origin, srouce]
            if !post.blank?
              row2 << [post.tag1,post.tag2,post.tag3,post.tag4,post.tag5,post.tag6,post.geo]
              rows << row1 + row2
            else
              csv << row1
            end
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
  end
