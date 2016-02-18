# -*- encoding : utf-8 -*-
class WeiboBasicScriptsWorker

  include Sidekiq::Worker
  sidekiq_options :queue => :basic_scripts, :backtrace => true
  
  def perform(uid)
    monit = MonitWeiboAccount.find_by_uid(uid)
    monit.run_basic_scripts
    monit.run_snap_scripts
  end
end

