# -*- encoding : utf-8 -*-
class IntelChinaDailyWorker

  include Sidekiq::Worker
  sidekiq_options :queue => :reports, :backtrace => true
  
  def perform
    uid = 2637370927
    # intel china daily weibo list report
    date= Date.today.strftime("%Y-%m-%d")
    filename = "intelchina-daily-weibo-list-#{date}.xls"
    filepath = "/tmp/#{filename}"

    book = Spreadsheet::Workbook.new
    sheet = book.create_worksheet
    titles = %w{
        UID
        Content
        Post\ at
        Reposts
        Comments
        Pure\ interactions
        Url
        Source
      }
    sheet_set(sheet, 0,0, titles)
    row = 1
    WeiboDetail.where("uid in (?) and post_at > ?",uid,Date.today-7.day).
#    WeiboDetail.where("uid in (?) and post_at between ? and ?",uid,'2013-8-1','2013-8-15').
      order("weibo_id asc").each{|weibo|

      mweibo = MWeiboContent.find(weibo.weibo_id)
      srouce = ActionView::Base.full_sanitizer.sanitize(mweibo.source)
      post_at = weibo.post_at.strftime("%Y-%m-%d %H:%M:%S")
      pure_interactions = WeiboDetail.find_by_sql(<<-EOF
      select count(DISTINCT uid) counts from
      (
      (
      select forward_uid uid
      from weibo_forwards f
      where f.forward_uid
      and f.weibo_id = '#{weibo.weibo_id}'
      ) union(
      select comment_uid uid
      from weibo_comments f
      where f.comment_uid
      and f.weibo_id = '#{weibo.weibo_id}'
      ) 
      )as t 
      EOF
      ).first.counts
      sheet_set sheet, row,0, [weibo.uid, mweibo.text,post_at, weibo.reposts_count, 
        weibo.comments_count,pure_interactions, weibo.url, srouce]
      row  += 1
    }
    book.write filepath

    #查看中国最近发微博 互动   是因特尔中国的粉丝的有多少 (大文)
    sql = <<EOF
      select count(distinct from_uid)  counts
      from weibo_user_interaction_snap_dailies snap 
      left join weibo_user_relations rels on rels.by_uid=snap.from_uid and rels.uid=2637370927 
      where date between '#{Date.today-1.day}' and '#{Date.today}'
      and snap.uid=2637370927 
      and rels.id is not null 
      and (forwarded_count > 0 or commented_count>0)
EOF

    a = WeiboAccount.find_by_sql(sql).first
    
    body = "昨日与英特尔中国互动数量 : #{a.counts}"
    Notifier.report(:from => "Report <notice@weizhuli.com>", subject:"Intelchina微博列表 #{date}",
      body:body,to:"huye@weizhuli.com,yutao@weizhuli.com,zhangzhen@weizhuli.com,xiaowen.li@weizhuli.com",
      attachments:{filename.to_s=>filepath}).deliver
  end


  def sheet_set(sheet,row,col,data)
    if data.is_a? Array
      data.each{|d|
        sheet[row,col] = d
        col += 1
      }
    else
      sheet[row,col] = data
    end
  end

end

