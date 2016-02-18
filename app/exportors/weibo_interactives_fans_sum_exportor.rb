# -*- encoding : utf-8 -*-
class WeiboInteractivesFansSumExportor < ExportorBase
  description <<EOF
  根据  urls 跑出互动人粉丝和（曝光量） (urls) 
  数据列包括:
   urls 曝光量
    

EOF
  title "互动人粉丝和(根据urls)"


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

  export interactive:"互动人粉丝和" do |ins,opts|
    ins.export_interactive_fans_sum(@urls)
  end
  def export_interactive_fans_sum(urls)
    task = GetUserTagsTask.new
      rows<< %w{url 曝光量}
      urls.each do |line|
        url = line
        @compare_uids = {}
        number  = 0
        weibo_id = WeiboMidUtil.str_to_mid URI.parse(url).path.split("/").last# http://weibo.com/1795839430/AhbvtnvrV http://weibo.com/1795839430/AhmhfkBY5
        puts url 
        page = 1
        processing = true
          begin
            begin
              res = task.stable{task.api.statuses.repost_timeline(weibo_id.to_s,count:200,page:page)}#根据weibo_id查转发人信息count  
                             
                if !res.blank?        
                   res.reposts.each do |line| 
                     row = [] 
                    if line.nil?
                       processing = false
                       break
                    end
                    @compare_uids[line.user.id.to_s] ||= [1,{'uid' =>line.user.id,'followers_count' =>line.user.followers_count}]
                   !@compare_uids[line.user.id.to_s].nil? if @compare_uids[line.user.id.to_s][0] +=1
                   end
                 else
                  processing = false
                  break
                 end         
            rescue Exception=>e
              puts e.message
            end
            page+=1
          end while processing == true
         processing == true
         page = 1
          begin
            begin     
              res = task.stable{task.api.comments.show(weibo_id,count:200,page:page)}#根据weibo_id查评论人信息                    
                if !res.comments.blank?  
                   res.comments.each do |line| 
                    
                    if line.nil?
                       processing = false
                       break
                    end
                   @compare_uids[line.user.id.to_s] ||= [1,{'uid' =>line.user.id,'followers_count' =>line.user.followers_count}]
                   !@compare_uids[line.user.id.to_s].nil? if @compare_uids[line.user.id.to_s][0] +=1
                   end
                 else
                  processing = false
                  break
                 end                
             rescue Exception=>e
              puts e.message
             end
             page+=1
          end while processing == true
         @compare_uids.keys.each do |uid|
            puts uid
            number += @compare_uids[uid][1]['followers_count']
         end  
        rows << [url,number]  
       end 
  end
end
