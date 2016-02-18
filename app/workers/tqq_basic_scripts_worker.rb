# -*- encoding : utf-8 -*-
class TqqBasicScriptsWorker

  include Sidekiq::Worker
  sidekiq_options :queue => :tqq_basic_scripts, :backtrace => true
  
  def perform(openid)
    monit = MonitTqqAccount.find_by_openid(openid)
    monit.run_basic_scripts
    monit.run_snap_scripts
  end
end

