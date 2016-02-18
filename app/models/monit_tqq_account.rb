# -*- encoding : utf-8 -*-
class MonitTqqAccount < ActiveRecord::Base
  attr_accessible :analyse_status, :name, :nick, :openid, :status

  INIT_LOADED = 1

  COMPARES = {
    "0B6A468C0642625453023BFB0D1B8570"=>[
      "334FF584F2A77237CDE67F58B1DA20CF","43AFF8C3E6A0A98B653F56BE78535199","2B7C9EE9B6878DF1E1C4EC28ED7EEE15",
      "F83B98A70026D6F54DDC3325B0EEB8DC","A6AD5631683AA595967D945FB78DB61C","8553E3309EDF8235F4CB846C6396DB35",
      "997B01BB7EA298442DC62C8912FF57AD"
    ]
  }


  AUTHED_UID_AND_KEYS = {
#    2637370927=>"1075842038",
  }


  after_create :init_weibo_info


  scope :available, where("status = 1")
  scope :initialized, available.where(["analyse_status = ?",INIT_LOADED])
  scope :weibo, where("platform = 'weibo'")
  scope :tqq, where("platform = 'tqq'")


  def compare_openids
    COMPARES[self.openid]
  end

  def generate_weeily_report(end_date,opts={})
    report = TqqReport.new self.openid, compare_openids, end_date, opts
    report.generate_excel_report
    nil
  end

  # end_date : last day of the week
  # opts : export_file,  mail_to
#MonitTqqAccount.find_by_openid('0B6A468C0642625453023BFB0D1B8570').send_weekly_report '2014-03-31',mail_to:"yawei.zhang@weizhuli.com"
  def send_weekly_report end_date,opts={}

    end_date = Date.parse(end_date) if end_date.is_a? String
    opts[:export_file] ||= "data/#{self.nick}_tqq_weekly_#{end_date.to_s}.xls"
    export_file = opts[:export_file]
    filename = File.basename export_file
    self.generate_weeily_report(end_date, opts)

    mail_to = opts[:mail_to] || "huye@weizhuli.com,zhangzhen@weizhuli.com,yutao@weizhuli.com,yawei.zhang@weizhuli.com,nana.tian@weizhuli.com,wangjuan@weizhuli.com"
    subject = opts[:subject] || "腾讯 #{self.nick} 周报 #{end_date.to_s}"
    Notifier.report(to:mail_to,
        subject:subject,
        attachments:[[filename,export_file]]
        ).deliver
  end


  def init_weibo_info
    #TqqInitScriptsWorker.perform_async(openid)
    task = GetTqqBasicTask.new(openid:openid,name:name)
    account = task.run
    self.update_attributes(openid:account.openid,name:account.name, nick:account.nick)
  end

  def init_load
    run_basic_scripts
    self.update_attribute(:analyse_status, INIT_LOADED)
  end

  def delay_run_basic_scripts
    TqqBasicScriptsWorker.perform_async(openid)
  end

  def run_basic_scripts
    # basics
    get_relations_task.run
    get_weibo_task.run
    get_forwards_comments_task.run


    run_mention_task
  end

  def run_mention_task
    if self.mention_status == 1
      get_mentions_task.run
    end
  end

  # 
  def delay_run_snap_scripts(options={})
    TqqSnapScriptsWorker.perform_async(openid)
  end
  
  def run_snap_scripts(options={})
    # snaps

    now = options[:time] || Time.now
    snap_intervals = [:hourly]
    snap_intervals << :daily if now.hour == 0
    snap_intervals << :weekly if now.wday == 1 && now.hour == 0
    snap_intervals << :monthly if now.day == 1 && now.hour == 0

    task = GetTqqAccountSnapTask.new(openid:openid,:time=>now)
    task.interval_types = snap_intervals
    task.run


    task = GetTqqUserInteractSnapTask.new(openid:openid,:time=>now)
    task.interval_types = snap_intervals
    task.run

    task =GetTqqContentCountSnapTask.new(openid:openid,:time=>now)
    task.interval_types = snap_intervals
    task.run


  end

  def get_basic_task
    GetTqqBasicTask.new(openid:openid,name:name)
  end

  def get_weibo_task
    GetTqqWeiboTask.new(openid:openid)
  end

  def get_forwards_comments_task
    GetTqqForwardsCommentsTask.new(openid:openid)
  end

  def get_mentions_task
    GetTqqMentionsTask.new(openid:openid,name:name)
  end

  def get_relations_task
    GetTqqRelationsTask.new(openid:openid)
  end

  def get_user_interact_snap_task
    task = GetTqqUserInteractSnapTask.new(openid:openid,:time=>Time.now)
    task.interval_types = [:hourly]
    task
  end




end
