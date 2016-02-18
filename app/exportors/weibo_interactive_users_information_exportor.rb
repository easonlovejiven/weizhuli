# -*- encoding : utf-8 -*-
class WeiboInteractiveUsersInformationExportor < ExportorBase

  description <<EOF
  根据  urls 列表导出互动人信息 (基本信息) 
  数据列包括:
    基本信息
    

EOF
  title "互动人信息(根据urls)"


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

  export interactive:"互动人信息列表" do |ins,opts|
    ins.export_interactive(@urls)
  end

  def export_interactive(urls)
      task = GetUserTagsTask.new
      rows << WeiboAccount.to_row_title(:full)
      uniq_uids = []
      @all_interactive = []
      urls.each do|line|
          url = line
          weibo_id = WeiboMidUtil.str_to_mid url.split("/").last#http://weibo.com/1902520272/AdgAY5a54  http://weibo.com/2637370927/AdYvTsFCh
    #http://weibo.com/2803301701/AiivFxLc4
          puts url
          forward = []
          comment = []
          page = 1
          processing = true
            begin
              begin
                res = task.stable{task.api.statuses.repost_timeline(weibo_id,count:200,page:page)}#根据weibo_id查转发人信息count
                  if !res.blank?
                     res.reposts.each do |line|
                       row = []
                      if line.nil?
                         processing = false
                         break
                      end
                      forward << line.user.id

                      if !uniq_uids.include?(line.user.id)
                        uniq_uids << line.user.id 
                        row = WeiboAccount.to_row(line.user)
                        rows << row
                      end


                     end
                   else
                    processing = false
                    break
                   end
              rescue Exception=>e
                next
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
                      comment << line.user.id

                      if !uniq_uids.include?(line.user.id)
                        uniq_uids << line.user.id 
                        row = WeiboAccount.to_row(line.user)
                        rows << row
                      end


                     end
                   else
                    processing = false
                    break
                   end
               rescue Exception=>e
                next
               end
               page+=1
            end while processing == true
          interactive = forward+comment
          @all_interactive += interactive
      end
     
  end

end
