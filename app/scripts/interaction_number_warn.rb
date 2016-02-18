# -*- encoding : utf-8 -*-
class InteractionNumberWarn



  def perform(uid,setting)

    receiver_emails = setting[:receiver_emails]
    receiver_mobiles = setting[:receiver_mobiles]
    max_interaction = setting[:max_interaction] || 500
    screen_name = setting[:screen_name]

#    receiver_emails = "huye@weizhuli.com"

    wds = WeiboDetail.where(uid:uid).where("reposts_count+comments_count > ? and post_at > ?",max_interaction, Date.today-30.day).all

    sms = Sms.new
    wds = wds.map{|wd|
      if MInteractionWarn.where(uid:uid,weibo_id:wd.weibo_id).first
        nil
      else
        mc = MWeiboContent.find(wd.weibo_id)
        if mc
          mc.text =~ /极客时间/  ? nil : wd
        else
          wd
        end
      end
    }.compact


    wds.each{|wd|
      MInteractionWarn.create(uid:wd.uid,weibo_id:wd.weibo_id)
      receiver_mobiles.each{|mobile|
        # sms.send_sms mobile, "[#{screen_name}]微博互动频率提醒：微博互动达到#{wd.reposts_count+wd.comments_count}, 微博地址：#{wd.url} 【微助力】"
      }
    }



    Notifier.monit_interacts_number_warning(screen_name, wds,receiver_emails).deliver  if !wds.blank?

  end

  def perform_all
    uids = [2637370927, 2295615873,2637370247]
    settings = {
      2637370927=>{
        screen_name:"英特尔中国",
        receiver_emails: %w{
          wangjuan@weizhuli.com
          huye@weizhuli.com
          xiaowen.li@weizhuli.com
          zhangzhen@weizhuli.com
          yutao@weizhuli.com
          jingx.wu@intel.com
          shaojun.sun@ogilvy.com
          clark.wangs@ogilvy.com
          sherry.yu@intel.com
          rita.zhang@intel.com
          jasmine.xu@ogilvy.com
        },

        receiver_mobiles: [
            "18600578412",  # me
            "15210510228",  # da wen
            "13601300887",  # yutao
            # "13810959607",  # fan fan
#            "18600036179",  # sherry
          ]
      },


      2295615873=>{
        screen_name:"英特尔商用频道",
        max_interaction:50,
        
        receiver_emails: %w{
          huye@weizhuli.com
          celia.wang@intel.com
          samantha.gao@ogilvy.com
          zhangzhen@weizhuli.com
          shawn.han@mail.ogilvy.com
          jessicaz.zhang@ogilvy.com
        },

        receiver_mobiles: [
            "18600578412",  # me
            "13501292911",  # Celia
            "15801269933",  # Samantha
            "13811289318",  # Zhangzhen
        ]
      },

      2637370247=>{
        screen_name:"英特尔芯品汇",
        max_interaction:300,

        receiver_emails: %w{
          yafei.fan@weizhuli.com
          huye@weizhuli.com
          xiaowen.li@weizhuli.com
          zhangzhen@weizhuli.com
          yutao@weizhuli.com
          rita.zhang@intel.com
          shaojun.sun@ogilvy.com
          riddle.zhang@weizhuli.com
        },

        receiver_mobiles: [
            "18600578412",  # me
            "15210510228",  # da wen
            "13601300887",  # yutao
            "18618118923",  # rita
            "18500228459",  # 孙少军
#            "18600036179",  # sherry
          ]
      },

    }


    uids.each{|uid| 
      setting = settings[uid]
      perform uid,setting
    }
  end

end