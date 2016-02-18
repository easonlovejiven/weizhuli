# -*- encoding : utf-8 -*-
class WeiboListContentExportor < ExportorBase

  description <<EOF
  根据 指定 监控帐号的微博 URL 列表导出微博互动信息 (uid，说的内容，互动时间，互动的微博连接) 
  数据列包括:
    uid，说的内容，互动时间，互动的微博连接
    

EOF
  title "监控帐号微博互动内容列表(根据urls)"


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
    ins.export_content(@urls)
  end

  def export_content(urls)
     
     #接口提取 api 通过url 转发 评论的内容 查出这些人说了些什么
  task = GetUserTagsTask.new
    te = TextEvaluate.new
    rows << WeiboAccount.to_row_title(:full)+%w{内容 互动时间 互动微博连接 动作 正负面 正负面匹配词 有效性}
       
      urls.each do|line|
      
        url = line.strip
        weibo_id = ::WeiboMidUtil.str_to_mid url.split("/").last
        commentcount = 0
        forward_weibo = WeiboForward.where("weibo_id = ?",weibo_id)
        comment_weibo = WeiboComment.where("weibo_id = ?",weibo_id)
          if !comment_weibo.nil?
            comment_weibo.each do |comment|
               row = []
               account = task.load_weibo_user(comment.comment_uid.to_s)
               comment.blank? ? commentat = '' : commentat = comment.comment_at.strftime("%Y-%m-%d %H:%M:%S")
               url = "http://weibo.com/#{comment.uid}/#{WeiboMidUtil.mid_to_str(comment.comment_id.to_s)}"
               c  = MComment.find(comment.comment_id)
               next if c.nil?
               eva,eva_word = te.evaluate(c.text)
               valid = te.valid(c.text)
               row = account.to_row(:full) + [url,c.text,commentat,'评论',eva,eva_word,valid]
               rows << row
            end
          end
          if !forward_weibo.nil?
            forward_weibo.each do |forward|
              row = []
              account = task.load_weibo_user(forward.forward_uid.to_s)
              forward.blank? ? forwardat = '': forwardat = forward.forward_at.strftime("%Y-%m-%d %H:%M:%S")
              url = "http://weibo.com/#{forward.forward_uid}/#{WeiboMidUtil.mid_to_str(forward.forward_id.to_s)}"
              c =  MForward.find(forward.forward_id)
              next if c.nil?
               eva,eva_word = te.evaluate(c.text)
               valid = te.valid(c.text)
              row = account.to_row(:full) + [url,c.text,forwardat,'转发',eva,eva_word,valid]
               rows << row
            end
          end
       
      end    

   end


end
