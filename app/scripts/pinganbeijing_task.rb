# -*- encoding : utf-8 -*-
class PinganbeijingTask


  def send_daily_weibo_list
    uid = 1288915263
    # intel china daily weibo list report
    date= Date.today.strftime("%Y-%m-%d")
    filename = "pinganbeijing-daily-weibo-list-#{date}.xls"
    filepath = "data/#{filename}"

    book = Spreadsheet::Workbook.new
    sheet = book.create_worksheet
    titles = %w{
        UID
        Content
        Post\ at
        Reposts
        Comments
        Url
        Source
      }
    sheet_set(sheet, 0,0, titles)
    row = 1
    WeiboDetail.where("uid in (?) and post_at > ?",uid,Date.yesterday).
#    WeiboDetail.where("uid in (?) and post_at between ? and ?",uid,'2013-8-1','2013-8-15').
      order("weibo_id asc").each{|weibo|

      mweibo = MWeiboContent.find(weibo.weibo_id)
      srouce = ActionView::Base.full_sanitizer.sanitize(mweibo.source)
      post_at = weibo.post_at.strftime("%Y-%m-%d %H:%M:%S")

      sheet_set sheet, row,0, [weibo.uid, mweibo.text,post_at, weibo.reposts_count, 
        weibo.comments_count, weibo.url, srouce]
      row  += 1
    }
    book.write filepath

    body = ""
    Notifier.report(:from => "Report <notice@weizhuli.com>", subject:"平安北京微博列表 #{date}",
      body:body,to:"huye@weizhuli.com",
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