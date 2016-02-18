# -*- encoding : utf-8 -*-
class WeiboListInteractiveContentExportor < ExportorBase

  description <<EOF
   接口根据 指定 的微博 URL 列表导出微博互动信息 (uid，说的内容，互动时间，互动的微博连接) 
  数据列包括:
    uid，说的内容，互动时间，互动的微博连接
    

EOF
  title "接口提取微博互动内容列表(根据urls)"


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

  export interactive:"互动内容表" do |ins,opts|
    ins.export_interactive(@urls)
  end

  def export_interactive(urls)
     
     #接口提取 api 通过url 转发 评论的内容 查出这些人说了些什么
  task = GetUserTagsTask.new
    rows << %w{uid 内容 无效内容 互动时间 互动微博连接 动作}
       
      urls.each do|line|
      
      url = line.strip
      weibo_id = WeiboMidUtil.str_to_mid URI.parse(url).path.split("/").last# http://weibo.com/1795839430/AhbvtnvrV http://weibo.com/1795839430/AhmhfkBY5
      puts url 
      page = 1
      processing = true
        begin
          begin
            res = task.stable{task.api.statuses.repost_timeline(weibo_id.to_s,count:200,page:page)}#根据weibo_id查转发人信息count  
                           
              if !res.blank?        
                 res.reposts.each do |line| 
                  if line.nil?
                     processing = false
                     break
                  end
                 url = "http://weibo.com/#{line.retweeted_status.user.id}/#{WeiboMidUtil.mid_to_str(line.retweeted_status.id.to_s)}"     
                 fake_content = line.text == "转发微博" || line.text.gsub(/\[[^\]]+\]/,"").blank?
                 rows << [line.user.id,line.text,fake_content, DateTime.parse(line.created_at).strftime("%Y-%m-%d %H:%S"),url,'转发']
                 end
               else
                processing = false
                break
               end         
          rescue SystemExit, Interrupt,IRB::Abort
            raise

          rescue SystemExit, Interrupt,IRB::Abort
            raise

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
                   url = "http://weibo.com/#{line.status.user.id}/#{WeiboMidUtil.mid_to_str(line.status.id.to_s)}"     
                 fake_content = line.text == "转发微博" || line.text.gsub(/\[[^\]]+\]/,"").blank?
                 rows << [line.user.id,line.text,fake_content, DateTime.parse(line.created_at).strftime("%Y-%m-%d %H:%S"),url,'评论']
                 end
               else
                processing = false
                break
               end                
          rescue SystemExit, Interrupt,IRB::Abort
            raise

           rescue Exception=>e
            puts e.message
           end
           page+=1
        end while processing == true
       
    end    

   end


end
