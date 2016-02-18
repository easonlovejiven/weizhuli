# -*- encoding : utf-8 -*-
class WeiboListInteractiveUserExportor < ExportorBase

  description <<EOF
  根据 指定 的微博 URL 列表导出微博互动信息 (用户信息，微博信息，互动量，互动人数等) 
  数据列包括:
    url 内容 转发数 评论数  互动量 参与互动人数  发布时间 是否原创 uid 发布账号昵称 粉丝数 类型 来源
    

EOF
  title "微博互动信息(根据urls)"


  before do |this,opts|
    #TODO:
    @start_time = opts[:start_time]
    @end_time = opts[:end_time]
    @urls = case 
            when opts[:urls].is_a?(String)
              opts[:urls].split("\r\n").map{|line| line.blank? ? nil : line.strip}.compact
            when opts[:urls].is_a?(Array)
              opts[:urls]
            else
            end
    @with_interations = opts[:with_interations]
  end

  export interactive:"互动人信息列表" do |ins,opts|
    ins.export_interactive(@urls)
  end

  def export_interactive(urls)
    task = GetUserTagsTask.new
    rows << %w{url 内容 转发数 评论数  互动量 参与互动人数  发布时间 是否原创 uid 发布账号昵称 粉丝数 类型 来源} 
      @all_interactive = []
      urls.each do|line|
      
      url = line.strip
      weibo_id = WeiboMidUtil.str_to_mid URI.parse(url).path.split("/").last#http://weibo.com/1902520272/AdgAY5a54  http://weibo.com/2637370927/AdYvTsFCh
      puts url
      forward = []
      comment = []   
      page = 1
      processing = true
        begin
          begin
            res = task.stable{task.api.statuses.repost_timeline(weibo_id.to_s,count:200,page:page)}#根据weibo_id查转发人信息count  
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

        page = 1
        processing = true
        begin
          begin     
              res = task.stable{task.api.comments.show(weibo_id,count:200,page:page)}#根据weibo_id查评论人信息   
              if !res.blank?&&!res.comments.blank?  
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
      interactive = forward+comment
      @all_interactive += interactive
      begin #解决异常      
       res = task.stable{task.api.statuses.show(id:weibo_id)}#http://weibo.com/2056744733/Ad6n2BxT4
       srouce = ActionView::Base.full_sanitizer.sanitize(res.source)
       rows << [url,res.text,res.reposts_count,res.comments_count,res.reposts_count+res.comments_count,interactive.uniq.size,DateTime.parse(res.created_at).strftime("%Y-%m-%d %H:%S"),res.retweeted_status.nil?? '是' :'否' ,res.user.id,res.user.screen_name,res.user.followers_count,WeiboListInteractiveUserExportor::human_verified_type(res.user.verified_type)*',',srouce]
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
  
  def self.human_verified_type(verified_type)
    verified_types = {
      -1 => "未认证",
      0 =>"名人",
      1 =>"政府",
      2 =>"企业",
      3 =>"媒体",
      4 =>"校园",
      5 =>"网站",
      6 =>"应用",
      7 =>"团体（机构）",
      10 => "微博女郎",
      200 =>"未审核达人",
      220 =>"达人",
    }

    verified_type_goups = {
      -1 => "草根",
      0 =>"橙V",
      1 =>"蓝V",
      2 =>"蓝V",
      3 =>"蓝V",
      4 =>"蓝V",
      5 =>"蓝V",
      6 =>"蓝V",
      7 =>"蓝V",
      200 =>"达人",
      220 =>"达人",
    }

    type = verified_types[verified_type]
    group = verified_type_goups[verified_type]

    [type,group]

  end
  
  

end
