# -*- encoding : utf-8 -*-
class WeiboSnapScriptsWorker

  include Sidekiq::Worker
  sidekiq_options :queue => :snap_scripts, :backtrace => true
  
  def perform(uid)
    MonitWeiboAccount.find_by_uid(uid).run_snap_scripts(snap_types:[:daily])
  end
end

