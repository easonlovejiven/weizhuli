# -*- encoding : utf-8 -*-
class WeiboInterBizPlatformExportor < ExportorBase

  description <<EOF
   接口根据 指定 的微博 URL  ,微博内容关键词分类
   数据列包括:
    keyword url content name detail fans post_time retweets comments   retweet_name retweet_fans 
    

EOF
  title "Intel Biz Platform(根据urls,keyword)娜娜"


  before do |this,opts|
    #TODO:
    @urls = case 
            when opts[:urls].is_a?(String)
              opts[:urls].split("\r\n").map{|line| line.blank? ? nil : line.strip}.compact
            when opts[:urls].is_a?(Array)
              opts[:urls]
            else
            end
    @keyword = opts[:keyword]

  end

  export inter_biz_platform:"Intel Biz Platform" do |ins,opts|
    ins.export_inter_biz_platform(@urls,@keyword)
  end

  def export_inter_biz_platform(urls,keyword)
      task = GetUserTagsTask.new 
      keyword.blank?? keyword = '' : keyword
      timenow = Time.now.strftime("%Y%m%d")
      
            rows << ["Intel Biz Platform Keywords monitoring(#{timenow})"]
            urls.each do |url|

              url = url
              weibo_id = WeiboMidUtil.str_to_mid URI.parse(url).path.split("/").last#http://weibo.com/1881422534/Bez9shEGS
              begin
                res = task.stable{task.api.statuses.show(id:weibo_id)}
              rescue Exception =>e
                 puts e.message
              end
              #title = %w{keyword url content name detail fans post_time retweets comments   retweet_name retweet_fans }
              content = res.text
              date = "#{DateTime.parse(res.created_at).year}年#{DateTime.parse(res.created_at).month}月#{DateTime.parse(res.created_at).day}日#{DateTime.parse(res.created_at).hour}:#{DateTime.parse(res.created_at).minute}"
              poster = "#{res.user.name}(Fans:#{res.user.followers_count}/Detail:#{res.user.verified_reason})"
              buzz_volume = "Retweets:#{res.reposts_count}/ Comments:#{res.comments_count}"
              rows << ["Keyword",keyword]
              rows << ["Content",content]
              rows << ["Link",url]
              rows << ["Poster",poster]
              rows << ["Date",date]
              rows << ["Buzz Volume",buzz_volume]
              page = 1
              processing = true
              begin
                begin
                   repost = task.stable{task.api.statuses.repost_timeline(weibo_id.to_s,count:200,page:page)}#根据weibo_id查转发人信息count  
                    if !repost.blank?        
                       repost.reposts.each do |line| 
                        if line.nil?
                            processing = false
                           break
                         end
                           #rows << [line.user.id,line.text,DateTime.parse(line.created_at).strftime("%Y-%m-%d %H:%S"),url,'转发']
                         rows << ["KOL","（Fans:#{line.user.followers_count}/ Retweet：#{line.reposts_count})#{line.user.verified_reason}"]
                        end
                     else
                       processing = false
                      break
                     end         
                rescue Exception=>e
                  rows << [e.message]
                  
                end
                 page+=1
               end while processing == true
             end
       

  end


end
