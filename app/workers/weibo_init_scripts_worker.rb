# -*- encoding : utf-8 -*-
class WeiboInitScriptsWorker

  include Sidekiq::Worker
  sidekiq_options :queue => :init_scripts, :backtrace => true
  
  def perform(uid)
    MonitWeiboAccount.find_by_uid(uid).init_load
  end
end

