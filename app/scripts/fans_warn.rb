# -*- encoding : utf-8 -*-
class FansWarn



  def perform(uid,setting)

    screen_name = setting[:screen_name]
    receiver_mobiles = setting[:receiver_mobiles]
    receiver_emails = setting[:receiver_emails]
    now = Time.now.to_i
    last_hour = Time.at(now - now % 3600) - 2.hour 

    new_rels = WeiboUserRelation.where(uid:uid).where("follow_time between ? and ?",last_hour, last_hour+1.hour ).all

    puts "========= 共新增 #{new_rels.size} 个粉丝. 时间: #{last_hour.to_s}"
    accounts = []
    new_rels.each{|rel|
      a = WeiboAccount.find_by_uid(rel.by_uid)
      if a
        a.update_evaluates if a.user_quality.nil? || a.user_quality.origin_rate == -1
        muser = MUser.find(a.uid)
        account_check = true
        account_check = false if account_check && a.followers_count < 500 || a.statuses_count < 50
        account_check = false if account_check && a.comment_rate < 0.5
        account_check = false if account_check && a.origin_rate < 0.05
        account_check = false if account_check && !a.verified && muser.tags.blank?
        
        accounts << a if account_check
      end

    }

    puts "========= 高质量粉丝 #{accounts.size} 个"

    if !accounts.blank?
      sms = Sms.new
      receiver_mobiles.each{|mobile|
        # sms.send_sms mobile, "[#{screen_name}]新增粉丝提醒：新增粉丝有#{accounts.size}个高质量粉丝，详情请见邮件【微助力】"
      }


      Notifier.monit_fans_warning(screen_name, accounts,receiver_emails).deliver  
    end

  end

  def perform_all
    uids = [2295615873]
    settings = {

      2295615873=>{
        screen_name:"英特尔商用频道",
        
        receiver_emails: %w{
          huye@weizhuli.com
          celia.wang@intel.com
          maya.wang@ogilvy.com
          samantha.gao@ogilvy.com
          zhi.zhou@ogilvy.com
          zhangzhen@weizhuli.com
        },

        receiver_mobiles: [
            "18600578412",  # me
        ]
      },
    }


    settings.each{|uid,setting| 
      perform uid,setting
    }
  end

end