# -*- encoding : utf-8 -*-
# 每天抓取 平安北京相关监控帐号每日数据 
class PinganbeijingAccountsLog

  UIDS = {
    '1'=>%w{
3745736194
3645726762
3182797847
3427645762
2879004734
2464645440
2388955087
2281486434
2258833123
1797168385
1631655117
1710175603
},
    '2'=>%w{
3736212437
3736199263
3735698533

3733511642
3728963592
2263473091
2099663371
2121634704
1964026295
    },

    '3'=>%w{
1782732857
1819065697
1523740633
1189752264
1195617880
1997728243
1932383433
1891059891

1774642660
1733113884
2116133051
1450141214
2244070235
2359256527
2359390085
2359719117
2359143997
2344223235
2397524570
2331070501
1610239603
2359215103
2358431235
2358470671
2358448635
2359151203
2359079153
2396331990
2358516625
1999613391
2274359515
2463553261
1345335593
2014811152
3190030552
2120977033

    },

      '4'=>%w{
2358582101
3166594751
3212327963
3546362114
3546827697
3546669581
3547273293
3547261461
3546854664
3546634865
3546615481
3546140241
3313048953
3546690481
3546202020
2928021032
2920454907
3291187847
3546629434
3291558877
3313018557
3313030017
3313026177
3291272453
3291267143
2927979562
3546355647
3546833307

3546326163
3546752242
3546762910
3546268040

3313043647
3282208020
3546859521
3546368980
2634586765
2633147957
3496485065
3496482764
3291247913
3496190742
3496484620
3496482032
3496481612
3291185383
3496484973
3291245233
3313057683
3312961917
3496183051
3546257954
3546263125
3291560557
3546838784
3291197867
3244813327
3544569501
3529574937
3564800187
3662345147
3660978213
3662394775
1923315913
3655145397
3649199212

3649189440
3654873150
1046378492
3659390171
3655237453
3242845183
3655149827
3719178537
3655241863
3654878771
3649088984
3665306353
3262380362
3649076752
3655534394

3659092453
3719158487
3719093285
3718014142

      },

  }
    



  def run
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


  def record_user(uid)
    task = GetUserTagsTask.new

    pinganbeijing = 1288915263

    # 抓取 基本信息
    res = task.api.users.show(uid:uid)
    user = task.save_weibo_user(res)


    # 



    # 抓取微博列表

    task = GetMyWeiboTask.new(uid)
    task.run  

    task.paginate(:per_page=>100){|page|
      weibos = WeiboDetail.where(uid:uid).paginate(:page=>page, :per_page=>100)
      ids = weibos.map(&:weibo_id)*","
      counts = task.stable{task.api.statuses.count(ids:ids)}
      counts.each{|count|
        weibo_id = count['id']
        detail = WeiboDetail.find_by_weibo_id weibo_id
        if detail
          detail.update_attributes(comments_count:count['comments'],reposts_count:count['reposts'])
        end
      }
      weibos.total_entries
    }


    

    statuses = WeiboDetail.where(uid:uid).count
    yesterday_statuses = WeiboDetail.where(uid:uid).where("post_at between ? and ?",Date.yesterday,Date.today).count
    yesterday_origin_status = WeiboDetail.where(uid:uid,origin:true).where("post_at between ? and ?",Date.yesterday,Date.today).count

    total_forwards = WeiboDetail.where(uid:uid).sum("reposts_count")
    total_comments = WeiboDetail.where(uid:uid).sum("comments_count")
    total_forwards_in_day = WeiboDetail.where(uid:uid).where("post_at between ? and ?",Date.yesterday,Date.today).sum("reposts_count")
    total_comments_in_day = WeiboDetail.where(uid:uid).where("post_at between ? and ?",Date.yesterday,Date.today).sum("comments_count")

    total_origin_forwards = WeiboDetail.where(uid:uid,origin:true).sum("reposts_count")
    total_origin_comments = WeiboDetail.where(uid:uid,origin:true).sum("comments_count")
    total_origin_forwards_in_day = WeiboDetail.where(uid:uid,origin:true).where("post_at between ? and ?",Date.yesterday,Date.today).sum("reposts_count")
    total_origin_comments_in_day = WeiboDetail.where(uid:uid,origin:true).where("post_at between ? and ?",Date.yesterday,Date.today).sum("comments_count")

    monit_account = MPinganbeijingMonitAccount.where(uid:uid.to_i,date:Date.to_mongo(Date.yesterday)).first

    monit_account = MPinganbeijingMonitAccount.new(uid:uid,date:Date.yesterday) if monit_account.nil?

    monit_account.screen_name = user.screen_name
    monit_account.followers_count = user.followers_count
    monit_account.friends_count = user.friends_count
    monit_account.statuses_count = user.statuses_count
    monit_account.origin_statuses_count = yesterday_origin_status
    monit_account.forward_statuses_count = yesterday_statuses - yesterday_origin_status
    monit_account.forwards_count = total_forwards
    monit_account.comments_count = total_comments
    monit_account.forwards_count_in_day = total_forwards_in_day
    monit_account.comments_count_in_day = total_comments_in_day
    monit_account.origin_status_forwards = total_origin_forwards
    monit_account.origin_status_comments = total_origin_comments
    monit_account.origin_status_forwards_in_day = total_origin_forwards_in_day
    monit_account.origin_status_comments_in_day = total_origin_comments_in_day


    last_mention = WeiboMention.where(uid:pinganbeijing, mention_uid:uid).last
    mmention = last_mention && MMention.find(last_mention.mention_id)
    monit_account.last_mention_content = mmention && mmention.text
    monit_account.last_mention_time = last_mention && last_mention.mention_at.to_datetime
    monit_account.mentions_count = WeiboMention.where(uid:pinganbeijing, mention_uid:uid).count
    monit_account.mentions_count_30 = WeiboMention.where(uid:pinganbeijing, mention_uid:uid).where("mention_at > ?",Date.today-30.day).count
    monit_account.mentions_count_7 = WeiboMention.where(uid:pinganbeijing, mention_uid:uid).where("mention_at > ?",Date.today-7.day).count



    monit_account.save!


    puts monit_account

  end

end