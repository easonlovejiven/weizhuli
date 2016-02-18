# -*- encoding : utf-8 -*-
class MonitWeiboAccount < ActiveRecord::Base
  has_many :monit_task
  has_many :collection_task, :through => :monit_task

  INIT_LOADED = 1

  COMPARES = {
    # 英特尔中国 : 英特尔中国天天事 英特尔新极客 英特尔商用频道 超极本 高通中国
    # Snapdragon骁龙 联想 ThinkPad 东芝电脑 
     # 戴尔中国 ASUS华硕 惠普电脑 杜蕾斯官方微博 戴尔促销 ARM中国 AMD中国 Acer宏碁

    #2637370927=>[1340241374,2295615873,2637370247,1738056157,
#2619244577,2183473425,1617785922,1765189187,
#1687053504,1747360663,1847000261,1942473263,1785529887,2216786767,1883832215,1775695331,2030206793],
    #1. @英特尔中国=> [周报中的监控帐号：英特尔中国、超极本、英特尔商用频道、英特尔中国天天事、Qualcomm中国、AMD中国、联想、戴尔中国、ASUS华硕、可口可乐、星巴克中国、小米公司]。
    2637370927=>[2637370247,2295615873,1340241374,1738056157,1883832215,
    2183473425,1687053504,1747360663,1795839430,1741514817,1771925961],
 
    # 英特尔商用频道 : 英特尔中国 英特尔中国天天事  超极本 思科数据中心 CSDN云计算 IT经理世界杂志 ThinkPad 中国云计算论坛 阿里云  
    2295615873=>[2637370927, 1340241374,2637370247, 1979838530, 1741045432, 1654815470, 1617785922, 2841727664,1644971875],

    # 金融街购物中心微博: 万达广场 赛特购物中心 西单大悦城 北京新世界百货 赛特奥莱 世贸天阶THEPLACE SOLANA蓝色港湾 新光天地 欧美汇
    # 凯德MALL西直门 东方新天地 燕莎友谊商城 VIVA北京富力广场 庄胜崇光百货SOGO 复兴门百盛 Gate新中关 汉光百货 北京银泰中心 侨福芳草地 国贸商城CWM
    1924531943=>[2607667467,1904055083,1458510924,1846075301,1774791253,1968652261,1752446921,2673186813,1894206637,2097835254,2139920133,
      3401622210,1974538530,2126253693,2262763191,1721735450,1683590694,1913929485,2097226675,2707715883],
    # 英特尔中国天天事   超极本  
    1340241374=>[2295615873,2637370247],
    # 超极本 : 同 intel
    #2637370247=>[1340241374,2295615873,1738056157,
    #2619244577,2183473425,1617785922,1765189187,
    #1687053504,1747360663,1847000261,1942473263,1785529887,2216786767,1883832215,1775695331,2030206793],
    # 2. @超极本 => [周报中的监控帐号：超极本、英特尔中国、英特尔商用频道、英特尔中国天天事、惠普电脑、ThinkPad、戴尔促销、饭团AMD、小米手机、杜蕾斯官方微博]。
    #2637370247=>[2637370927,2295615873,1340241374,1847000261,1617785922,1785529887,2027607132,2202387347,1942473263],
    #3. @英特尔芯品汇 => [%w{  英特尔中国 英特尔商 用频道 英特尔知IN 惠普电脑 Thinkpad 饭团AMD 杜蕾斯官方微博  小米手机}
    2637370247=>[2637370927, 2295615873, 1340241374, 1847000261, 1617785922, 2027607132, 1942473263, 2202387347],
    #北京宠爱国际动物医院
    3869439663=>[3869439663],
    #超能双雄  3906939792
    3906939792=>[3906939792],
  }
  COMPARESMONTH = {
    #3. @英特尔芯品汇 => [%w{  英特尔中国 英特尔商 用频道 英特尔知IN 惠普电脑 Thinkpad 饭团AMD 杜蕾斯官方微博  小米公司}
    2637370247=>[2637370927, 2295615873, 1340241374, 1847000261, 1617785922, 2027607132, 1942473263, 1771925961],
    #1. @英特尔中国=> [周报中的监控帐号：英特尔中国、超极本、英特尔商用频道、英特尔中国天天事、Qualcomm中国、AMD中国、联想、戴尔中国、ASUS华硕、可口可乐、星巴克中国、小米公司]。
    2637370927=>[2637370247,2295615873,1340241374,1738056157,1883832215,
    2183473425,1687053504,1747360663,1795839430,1741514817,1771925961],
    
  }

  AUTHED_UID_AND_KEYS = {
    2637370927=>"1075842038",
    2295615873=>"1384091891",
    1288915263=>"744205941",
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
  #小伟改：WeiboReport2 
  def generate_weeily_report2(end_date,opts={})
    cuids = opts[:compare_uids] || compare_uids
    cuids.each{|uid|
      raise "#{uid} is not in compare uids for #{@uid}" if !compare_uids.include? uid
    }
    report = WeiboReport2.new self.uid, cuids, end_date, opts
    report.generate_excel_report
    nil
  end
  
   #小伟改：WeiboMonthlyReport
  def generate_monthly_report(end_date,opts={})
    cuids = opts[:compare_uids] || compare_uids
    cuids.each{|uid|
      raise "#{uid} is not in compare uids for #{@uid}" if !compare_uids.include? uid
    }
    report = WeiboMonthlyReport.new self.uid, cuids, end_date, opts
    report.generate_excel_report
    nil
  end

  # end_date : last day of the week
  # opts : export_file,  mail_to
  #MonitWeiboAccount.find_by_uid('2295615873').send_weekly_report("2014-05-24",mail_to:"yawei.zhang@weizhuli.com",include_sheets:"new_fans_ranking")

  def send_weekly_report end_date,opts={}

    end_date = Date.parse(end_date) if end_date.is_a? String
    opts[:export_file] ||= "data/#{self.screen_name}_weekly_#{end_date.to_s}.xls"
    export_file = opts[:export_file]
    filename = File.basename export_file
    self.generate_weeily_report(end_date, opts)

 
    mail_to = opts[:mail_to] || "huye@weizhuli.com,jianhe.yuan@weizhuli.com,yutao@weizhuli.com,zhangzhen@weizhuli.com,boll.yue@weizhuli.com,nana.tian@weizhuli.com"

    Notifier.report(to:mail_to,
        subject:"#{self.screen_name} 周报 #{end_date.to_s}",
        attachments:[[filename,export_file]]
        ).deliver
  end
  #小伟改：send_weekly_report2 end_date,opts={} 
  #MonitWeiboAccount.find_by_uid('2295615873').send_weekly_report2("2014-04-09",mail_to:"yawei.zhang@weizhuli.com",include_sheets:"get_weibo_list")
  def send_weekly_report2 end_date,opts={}

    end_date = Date.parse(end_date) if end_date.is_a? String
    opts[:export_file] ||= "data/#{self.screen_name}_weekly_#{end_date.to_s}.xls"
    export_file = opts[:export_file]
    filename = File.basename export_file
    self.generate_weeily_report2(end_date, opts)

    mail_to = opts[:mail_to] || "huye@weizhuli.com,riddle.zhang@weizhuli.com,yawei.zhang@weizhuli.com,yutao@weizhuli.com,zhangzhen@weizhuli.com,yafei.fan@weizhuli.com,wangjuan@weizhuli.com,xiaowen.li@weizhuli.com,haobing@weizhuli.com"

    Notifier.report(to:mail_to,
        subject:"#{self.screen_name} 周报 #{end_date.to_s}",
        attachments:[[filename,export_file]]
        ).deliver
  end
  
  #小伟改：send_weekly_report2 end_date,opts={}
  #MonitWeiboAccount.find_by_uid('3869439663').send_monthly_report("2014-04-09",mail_to:"wangjuan@weizhuli.com")
  def send_monthly_report end_date,opts={}

    end_date = Date.parse(end_date) if end_date.is_a? String
    opts[:export_file] ||= "data/#{self.screen_name}_monthly_#{end_date.to_s}.xls"
    export_file = opts[:export_file]
    filename = File.basename export_file
    opts[:report_type] = :monthly
    self.generate_weeily_report(end_date, opts)

 
    mail_to = opts[:mail_to] || "huye@weizhuli.com,jianhe.yuan@weizhuli.com,zhangzhen@weizhuli.com,boll.yue@weizhuli.com,nana.tian@weizhuli.com"


    Notifier.report(to:mail_to,
        subject:"#{self.screen_name}月报 #{end_date.to_s}",
        attachments:[[filename,export_file]]
        ).deliver
  end


  def init_weibo_info
    WeiboInitScriptsWorker.perform_async(uid) if status == 1
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

    # basics

    task = GetMyWeiboTask.new(uid)
    task.run


    if status == 1

      last_forward_id = WeiboForward.order("id desc").where(uid:uid).first.try(:id)
      last_comment_id = WeiboComment.order("id desc").where(uid:uid).first.try(:id)
      last_mention_id = WeiboMention.order("id desc").where(uid:uid).first.try(:id)



      task = GetRelationsTask.new(uid)
      task.run


      task = GetUserForwardsCommentsTask.new(uid)
      task.run

      run_mention_task



      # check_notice(last_forward_id,last_comment_id,last_mention_id)
    end
      


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
      warning_uids = config["warn_uids"] || []
      high_interaction_uids = config["high_interaction_uids"] || []
      high_quality_uids = config["high_quality_uids"] || []
      high_both_uids = config["high_interaction_and_quality_uids"] || []

      receiver_mobiles = config["mobiles"] || []
      receiver_emails = (config["emails"] || [])*","  #"huye@weizhuli.com,xiaowen.li@weizhuli.com"

      all_uids = warning_uids + high_interaction_uids + high_quality_uids + high_both_uids

      # 相关用户的互动 , 发送预警
      fs = WeiboForward.where(uid:uid, forward_uid:all_uids).where("id > ?",last_forward_id).all
      cs = WeiboComment.where(uid:uid, comment_uid:all_uids).where("id > ?",last_comment_id).all
      ms = WeiboMention.where(uid:uid, mention_uid:all_uids).where("id > ?",last_mention_id).all

      match_uids = fs.map(&:forward_uid) + cs.map(&:comment_uid) + ms.map(&:mention_uid)
      match_uids.uniq!

      # 发现预警
      if match_uids.size > 0

        match_names= WeiboAccount.where(uid:match_uids).map(&:screen_name).uniq
        if receiver_mobiles.present?
          sms = Sms.new
          if match_names.size > 3
            match_names = match_names[0..2]*","+" 等#{match_names.size}人" 
          else
            match_names = match_names*","
          end
          # sms.send_sms receiver_mobiles, "【微助力】 微博互动提醒：[#{match_names}] 与[#{self.screen_name}]发生了互动，详情请见邮件。"
        end

        ins = []

        fs.each{|forward|
          mf = MForward.find(forward.forward_id)
          a = WeiboAccount.find_by_uid(forward.forward_uid)
          utype = high_interaction_uids.include?(forward.forward_uid) ? "高互动粉丝" : nil
          utype = high_quality_uids.include?(forward.forward_uid) ? "高质量粉丝" : nil if utype.nil?
          utype = high_both_uids.include?(forward.forward_uid) ? "高质量高互动粉丝" : nil if utype.nil?

          ins << {:action=>"转发",:user=>a.screen_name,:user_type=>utype,:content=>mf,:url=>"http://weibo.com/#{forward.forward_uid}/#{WeiboMidUtil.mid_to_str(forward.forward_id.to_s)}", :time=>forward.forward_at.strftime("%Y-%m-%d %H:%M")}
        }
        cs.each{|comment|
          mc = MComment.find(comment.comment_id)
          a = WeiboAccount.find_by_uid(comment.comment_uid)
          utype = high_interaction_uids.include?(comment.comment_uid) ? "高互动粉丝" : nil
          utype = high_quality_uids.include?(comment.comment_uid) ? "高质量粉丝" : nil if utype.nil?
          utype = high_both_uids.include?(comment.comment_uid) ? "高质量高互动粉丝" : nil if utype.nil?

          ins << {:action=>"评论",:user=>a.screen_name,:user_type=>utype,:content=>mc,:url=>"http://weibo.com/#{comment.uid}/#{WeiboMidUtil.mid_to_str(comment.weibo_id.to_s)}", :time=>comment.comment_at.strftime("%Y-%m-%d %H:%M")}
        }
        ms.each{|mention|
          mm = MMention.find(mention.mention_id)
          a = WeiboAccount.find_by_uid(mention.mention_uid)
          utype = high_interaction_uids.include?(mention.mention_uid) ? "高互动粉丝" : nil
          utype = high_quality_uids.include?(mention.mention_uid) ? "高质量粉丝" : nil if utype.nil?
          utype = high_both_uids.include?(mention.mention_uid) ? "高质量高互动粉丝" : nil if utype.nil?

          ins << {:action=>"主动@",:user=>a.screen_name,:user_type=>utype,:content=>mm,:url=>"http://weibo.com/#{mention.mention_uid}/#{WeiboMidUtil.mid_to_str(mention.mention_id.to_s)}", :time=>mention.mention_at.strftime("%Y-%m-%d %H:%M")}

        }

        Notifier.monit_interacts_warning(screen_name,ins,receiver_emails).deliver
      end
    end

  end


  # 只监控从现在起的微博及互动
  def temp_init
    init_weibo_info
    task = GetUserTagsTask.new
    weibo = task.api.statuses.user_timeline({:uid=>target_uid,:count=>1,:page=>1})
    weibo["statuses"].each{|post|
      task.save_weibo(post)
    }
  end



end


















