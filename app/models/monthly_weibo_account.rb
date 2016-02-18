# -*- encoding : utf-8 -*-
class MonthlyWeiboAccount < ActiveRecord::Base

  INIT_LOADED = 1

  COMPARES = {
    #英特尔中国	 => 英特尔知IN	  英特尔商用频道	  英特尔芯品汇	  联想	  戴尔中国	  ASUS华硕	  
    #东芝电脑  Acer宏碁 高通中国 AMD中国 可口可乐 杜蕾斯官方微博
    2637370927 => [ 1340241374, 2295615873, 2637370247, 2183473425, 1687053504, 1747360663,
               1765189187, 1775695331, 1650102012, 1883832215, 1795839430, 1942473263]
  }
  

  AUTHED_UID_AND_KEYS = {
    2637370927=>"1075842038",
    2295615873=>"1384091891",
    1288915263=>"3778658839",
    2637370247=>"1075842038",
  }


  after_create :init_weibo_info


  scope :available, where("status = 1")
  scope :initialized, available.where(["analyse_status = ?",INIT_LOADED])
  scope :weibo, where("platform = 'weibo'")
  scope :tqq, where("platform = 'tqq'")


  def compare_uids
    COMPARES[self.uid]
  end

  def generate_weeily_report(end_date,opts={})
    cuids = opts[:compare_uids] || compare_uids
    cuids.each{|uid|
      raise "#{uid} is not in compare uids for #{@uid}" if !compare_uids.include? uid
    }
    report = WeiboReport.new self.uid, cuids, end_date, opts
    report.generate_excel_report
    nil
  end

  # end_date : last day of the week
  # opts : export_file,  mail_to
  #MonitWeiboAccount.find_by_uid('3869439663').send_weekly_report("2014-04-09",mail_to:"wangjuan@weizhuli.com")

  def send_weekly_report end_date,opts={}

    end_date = Date.parse(end_date) if end_date.is_a? String
    opts[:export_file] ||= "data/#{self.screen_name}_weekly_#{end_date.to_s}.xls"
    export_file = opts[:export_file]
    filename = File.basename export_file
    self.generate_weeily_report(end_date, opts)

    mail_to = opts[:mail_to] || "huye@weizhuli.com,yawei.zhang@weizhuli.com,yutao@weizhuli.com,zhangzhen@weizhuli.com,yafei.fan@weizhuli.com,wangjuan@weizhuli.com,xiaowen.li@weizhuli.com,haobing@weizhuli.com"

    Notifier.report(to:mail_to,
        subject:"#{self.screen_name} 周报 #{end_date.to_s}",
        attachments:[[filename,export_file]]
        ).deliver
  end


  def init_weibo_info
    WeiboInitScriptsWorker.perform_async(uid)
    task = GetWeiboBasicTask.new(uid)
    account =  task.load_weibo_user(uid)
    self.update_attribute(:screen_name, account.screen_name)
  end

  def init_load
    run_basic_scripts
    self.update_attribute(:analyse_status, INIT_LOADED)
  end

  def delay_run_basic_scripts
    WeiboBasicScriptsWorker.perform_async(uid)
  end

  def run_basic_scripts

    last_forward_id = WeiboForward.order("id desc").where(uid:uid).first.try(:id)
    last_comment_id = WeiboComment.order("id desc").where(uid:uid).first.try(:id)
    last_mention_id = WeiboMention.order("id desc").where(uid:uid).first.try(:id)


    # basics

    task = GetMyWeiboTask.new(uid)
    task.run

    task = GetRelationsTask.new(uid)
    task.run


    task = GetUserForwardsCommentsTask.new(uid)
    task.run

    run_mention_task



    check_notice(last_forward_id,last_comment_id,last_mention_id)
  end

  def run_mention_task
    if self.loaded_mentions >= 0
      appkey = AUTHED_UID_AND_KEYS[uid]
      task = GetMentionsTask.new(uid,:appkey=>appkey)
      task.run
    end
  end

  # 
  def fix_loaded_mentions_number
    if self.loaded_mentions >= 0
      appkey = AUTHED_UID_AND_KEYS[uid]
      task = GetMentionsTask.new(uid,:appkey=>appkey)
      task.fix_last_mention_position(self)
    end
  end

  def delay_run_snap_scripts(options={})
    WeiboSnapScriptsWorker.perform_async(uid)
  end
  

  # options:
  #     time : 
  #     snap_types : [:hourly, :daily, :weekly, :monthly]
  def run_snap_scripts(options={})
    # snaps

    now = options[:time] || Time.now
    snap_intervals = options[:snap_types] || [:hourly]
#    snap_intervals << :daily if now.hour == 0
#    snap_intervals << :weekly if now.wday == 1 && now.hour == 0
#    snap_intervals << :monthly if now.day == 1 && now.hour == 0

    task = GetAccountSnapTask.new(uid,:time=>now)
    task.interval_types = snap_intervals
    task.run


    task =GetContentCountSnapTask.new(uid,:time=>now)
    task.interval_types = snap_intervals
    task.run

    task = GetUserInteractSnapTask.new(uid,:time=>now)
    task.interval_types = snap_intervals
    task.run


  end



  def check_notice(last_forward_id,last_comment_id,last_mention_id)

    configs = YAML.load_file("config/monit_warn_uids.yml")

    # 预警
    if !configs["monits"][uid.to_i].blank?
      config = configs["monits"][uid.to_i]
      #大雯 马宏升在北京 戈峻_英特尔 苏珊围脖 等灯等灯2011
      warning_uids = config["warn_uids"]
      receiver_mobiles = config["mobiles"]
      receiver_emails = config["emails"]*","  #"huye@weizhuli.com,xiaowen.li@weizhuli.com"

      # 相关用户的互动 , 发送预警
      fs = WeiboForward.where(uid:uid, forward_uid:warning_uids).where("id > ?",last_forward_id).all
      cs = WeiboComment.where(uid:uid, comment_uid:warning_uids).where("id > ?",last_comment_id).all
      ms = WeiboMention.where(uid:uid, mention_uid:warning_uids).where("id > ?",last_mention_id).all

      match_uids = fs.map(&:forward_uid) + cs.map(&:comment_uid) + ms.map(&:mention_uid)
      match_uids.uniq!

      # 发现预警
      if match_uids.size > 0

        match_names= WeiboAccount.where(uid:match_uids).map(&:screen_name).uniq
        sms = Sms.new
        sms.send_sms receiver_mobiles, "微博互动提醒：[#{match_names*","}] 与[#{self.screen_name}]发生了互动，详情请见邮件。【微助力】"

        ins = []

        fs.each{|forward|
          mf = MForward.find(forward.forward_id)
          a = WeiboAccount.find_by_uid(forward.forward_uid)
          ins << {:action=>"转发",:user=>a.screen_name,:content=>mf.text,:url=>"http://weibo.com/#{forward.forward_uid}/#{WeiboMidUtil.mid_to_str(forward.forward_id.to_s)}", :time=>forward.forward_at.strftime("%Y-%m-%d %H:%M")}
        }
        cs.each{|comment|
          mc = MComment.find(comment.comment_id)
          a = WeiboAccount.find_by_uid(comment.comment_uid)
          ins << {:action=>"评论",:user=>a.screen_name,:content=>mc.text,:url=>"http://weibo.com/#{comment.uid}/#{WeiboMidUtil.mid_to_str(comment.weibo_id.to_s)}", :time=>comment.comment_at.strftime("%Y-%m-%d %H:%M")}
        }
        ms.each{|mention|
          mm = MMention.find(mention.mention_id)
          a = WeiboAccount.find_by_uid(mention.mention_uid)
          ins << {:action=>"主动@",:user=>a.screen_name,:content=>mm.text,:url=>"http://weibo.com/#{mention.mention_uid}/#{WeiboMidUtil.mid_to_str(mention.mention_id.to_s)}", :time=>mention.mention_at.strftime("%Y-%m-%d %H:%M")}

        }

        Notifier.monit_interacts_warning(screen_name,ins,receiver_emails).deliver
      end
    end

  end






end

