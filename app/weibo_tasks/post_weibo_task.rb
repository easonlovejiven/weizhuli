# -*- encoding : utf-8 -*-
class PostWeiboTask < WeiboTaskBase

  #  this task supported interval
  SUPPORT_INTERVAL = [:hourly,:daily,:weekly,:monthly]
  # if this task stats only for the user which logged in by token
  # means to use this task , the target user have to LOGIN
  ONLY_TOKEN_USER = true
  # this task support multi-users stats in the same time
  SUPPORT_MULTI_USERS = false

  def run
    # task api token 完成了, 该写这一块儿 post 了
    @post = @options[:post]
    return if @post.done?
    begin
      if @post.mod == nil
        # 直发
        if @post.image_id.blank?
          debug("post weibo task update a new weibo...")
          posted = oapi.statuses.update(@post.content)
          debug("post weibo done.")
        else
          debug("post weibo task, upload a weibo with image")

          image_ids = @post.image_id.split(",")
          pids = []
          image_ids.each{|image_id|
            img = Image.find image_id
            f = File.new img.attachment.path
            res = oapi.statuses.upload_pic f
            pids << res.pic_id
          }
          posted = oapi.statuses.upload_url_text status:@post.content, pic_id:pids*","

          # posted = oapi.statuses.upload(@post.content,file,filename:"test",type:"image/jpeg")
        end
      else
        # 转发
        str = @post.forward_url.split("?").first.split("/").last.to_s.strip
        mid = WeiboMidUtil.str_to_mid(str)
        posted = oapi.statuses.repost(mid,status:@post.content)

      end

      @post.update_attribute(:weibo_id, posted.id)
      @post.done!
    rescue Exception=> e
      if e.message =~ /repeat content/
        @post.done! 
      else
        @post.failed!(e.message)
      end
    end
    "done"
  end

end
