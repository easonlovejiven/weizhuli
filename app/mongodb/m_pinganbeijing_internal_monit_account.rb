# -*- encoding : utf-8 -*-
class MPinganbeijingInternalMonitAccount
  # 平安北京相关 sohu, renmin 监控帐号每日信息


  include MongoMapper::Document


  key :uid, Integer
  key :date,  Date
  key :screen_name, String
  key :followers_count, Integer
  key :friends_count,   Integer
  key :statuses_count,   Integer


  key :forwards_count,  Integer
  key :comments_count,  Integer
  key :interactions_count,  Integer

  key :forwards_count_yesterday,  Integer
  key :comments_count_yesterday,  Integer
  key :interactions_count_yesterday,  Integer

  key :forwards_count_7day,  Integer
  key :comments_count_7day,  Integer
  key :interactions_count_7day,  Integer

  key :forwards_count_30day,  Integer
  key :comments_count_30day,  Integer
  key :interactions_count_30day,  Integer





  timestamps!



  UIDS = {
    "1" => %w{
      5142026251
      5137225881
      5140563716
      2157629345
      1320950430
      3117947233
      1828407521
      3672864060
      1782894470
      5140863506
      3180359982
      2410504507
      1100653947
      1888779782
      5137429302
      1093612951
      2001834620
      1409859220
      1402070647
      1195469933
      3893628528
      3893647568
      5104652308
      5099205412
      1253421082
      1995727277
      2425320573
      2440498083
      1010113165
      1706197580
      1797084725
      3948408160
      5148748952
      5146632866
      5149143378
      2655766213
      2080602607
      5137420191
      5143936028
      5137245155
      5143674334
      5137246142
      5143675428
      5137417836
      2131839243
      3983266536
      1650536611
      5137275156
      5142541398
      5140861122
      5142020377
      5140871267
      1917293227
      5148754414
      5148754549
      1850354847
      3134332387
      1144261667
      1623536735
      1630353881
      5143880106
      2211076103
      2211095767
      2211918221
      2218054031
      5142233949
      5140568399
      5143861784
      2045895331
      1571769351
      2301263951
      2795411914
      3760443183
      3705071990
      3703970162
      3305464817
      3305466293
      2261689652
      1003136050
      1512835001
      1356703937
      1882992817
      1235648512
      1888858317
      1212188233
      2919776927
      2919796077
      2919804053
      2919812853
      2195569127
      2582728245
      2583508127
      2688542305
      1632381222
      1198981350
      5148936107
      5148970384
      },

    "2" => %w{
      },
    "3" => %w{
    }
  }



  def self.update_stats
    uids = UIDS.values.flatten
    uids.each{|uid|
      begin
        record_user(uid)
      rescue Exception=>e
        puts e.message
        puts e.backtrace
      end

    }
  end



  def self.record_user(uid)

    pinganbeijing = 1288915263


    a = WeiboAccount.find_by_uid(uid)


    today = Date.today


    forward_total = WeiboForward.where(uid:pinganbeijing, forward_uid:uid).count
    comment_total = WeiboComment.where(uid:pinganbeijing, comment_uid:uid).count


    start_day = Date.yesterday

    forward_yesterday = WeiboForward.where(uid:pinganbeijing, forward_uid:uid).where("forward_at between ? and ?", start_day,today).count
    comment_yesterday = WeiboComment.where(uid:pinganbeijing, comment_uid:uid).where("comment_at between ? and ?", start_day,today).count

    start_day = today - 7.day

    forward_last_7day = WeiboForward.where(uid:pinganbeijing, forward_uid:uid).where("forward_at between ? and ?", start_day,today).count
    comment_last_7day = WeiboComment.where(uid:pinganbeijing, comment_uid:uid).where("comment_at between ? and ?", start_day,today).count

    start_day = today - 30.day

    forward_last_30day = WeiboForward.where(uid:pinganbeijing, forward_uid:uid).where("forward_at between ? and ?", start_day,today).count
    comment_last_30day = WeiboComment.where(uid:pinganbeijing, comment_uid:uid).where("comment_at between ? and ?", start_day,today).count


    ma = MPinganbeijingInternalMonitAccount.where(uid:uid, date:Date.yesterday.to_mongo).first
    ma ||= MPinganbeijingInternalMonitAccount.new(
        uid:uid, date:Date.yesterday.to_mongo, screen_name:a.screen_name, 
        followers_count:a.followers_count, friends_count:a.friends_count, statuses_count:a.statuses_count
      )

    ma.forwards_count = forward_total
    ma.comments_count = comment_total
    ma.interactions_count = forward_total+comment_total

    ma.forwards_count_yesterday = forward_yesterday
    ma.comments_count_yesterday = comment_yesterday
    ma.interactions_count_yesterday = forward_yesterday+comment_yesterday

    ma.forwards_count_7day = forward_last_7day
    ma.comments_count_7day = comment_last_7day
    ma.interactions_count_7day = forward_last_7day + comment_last_7day

    ma.forwards_count_30day = forward_last_30day
    ma.comments_count_30day = comment_last_30day
    ma.interactions_count_30day = forward_last_30day + comment_last_30day

    ma.save


  end

end




