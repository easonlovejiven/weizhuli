# -*- encoding : utf-8 -*-
class ExportWeiboListInteractiveUserExportor < ExportorBase

  description <<EOF
  根据 指定 的微博 URL 列表导出微博互动信息 (用户信息，微博信息，互动量，互动人数等) 
  数据列包括:
    用户信息 微博信息 互动量 互动人数
    

EOF
  title "微博互动信息导出"


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
    @urls = opts[:urls]

  end

  export interactive:"互动信息列表" do |ins,opts|
    ins.export_interactive(@urls)
  end

  def export_interactive(urls)
     
    task = GetUserTagsTask.new
    rows << %w{url 评论数 转发数 互动量 参与互动人数 粉丝数} 
      @all_interactive = []
      urls.each do|line|
      
      url = line.strip
      weibo_id = WeiboMidUtil.str_to_mid url.split("/").last#http://weibo.com/1902520272/AdgAY5a54  http://weibo.com/2637370927/AdYvTsFCh
      puts url
      forward = []
      comment = []   
      page = 1
      processing = true
        begin
          begin
            res = task.stable{task.api.statuses.repost_timeline(weibo_id.to_s,count:200,page:page)}#根据weibo_id查转发人信息count  
                           debugger
              if !res.blank?&&!res.reposts.blank?        
                 res.reposts.each do |line|  
                  if line.nil?
                     processing = false
                     break
                  end      
                 forward << line.user.id
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
        begin
          begin     
            res = task.stable{task.api.comments.show(weibo_id,count:200,page:page)}#根据weibo_id查评论人信息   
debugger                 
              if !res.blank&&!res.comments.blank?  
                 res.comments.each do |line| 
                  if line.nil?
                     processing = false
                     break
                  end               
                 comment << line.user.id
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
#debugger
      interactive = forward+comment
      @all_interactive += interactive
      begin #解决异常      
       res = task.stable{task.api.statuses.show(id:weibo_id)}#http://weibo.com/2056744733/Ad6n2BxT4
       rows << [url,res.reposts_count,res.comments_count,res.reposts_count+res.comments_count,interactive.uniq.size,res.user.followers_count]
      rescue Exception=>e
        if e.message =~ / does not exist!/
          rows << [url]
        else
          raise e
        end
      end  
       
    end  
    rows << %w{上面微博总参与人数}
    rows << [@all_interactive.uniq.size]
    @all_interactive.uniq.size
   
  end

end
