# -*- encoding : utf-8 -*-
class WeiboListForMonitingExportor < ExportorBase

  description <<EOF
  监控帐号微博列表导出
  根据UID列表 导出微博 详情列表
  数据列包括:
    微博基本信息

EOF
  title "监控帐号微博列表(根据uids)"


  before do |this,opts|
    #TODO:
    @start_time = opts[:start_time]
    @end_time = opts[:end_time]
    @uids = case 
            when opts[:uids].is_a?(String)
              opts[:uids].split("\r\n").map{|line| line.blank? ? nil : line.strip}.compact
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

    start_time = start_time
    end_time = end_time
    scope = WeiboDetail.where("uid in (?)",uids)
    scope = scope.where("post_at >= ?",start_time) if start_time
    scope = scope.where("post_at < ?",end_time) if end_time
    scope = scope.order("uid, post_at asc")
    accounts = {}

      rows << %w{UID 内容 时间 转发 评论 URL 来源 类型 原创}
      scope.each{|record|

        accounts[record.uid] ||= WeiboAccount.find_by_uid(record.uid)
        account = accounts[record.uid]

        c = MWeiboContent.find(record.weibo_id)
        next if c.nil?
        srouce = ActionView::Base.full_sanitizer.sanitize(c.source)
        type = case 
          when record.image? && record.video?
            "image + video"
          when record.image?
            "image"
          when record.video?
            "video"
          when record.music?
            "music"
          when record.vote?
            "vote"
          else
            "text"
        end

        origin = !record.forward

        post_at = record.post_at.strftime("%Y-%m-%d %H:%M:%S")
        rows << [account.screen_name, c.text,post_at, record.reposts_count, record.comments_count, record.url, srouce, type, origin]
      }
   
  end




end
