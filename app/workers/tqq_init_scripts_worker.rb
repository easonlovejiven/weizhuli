# -*- encoding : utf-8 -*-
class TqqInitScriptsWorker

  include Sidekiq::Worker
  sidekiq_options :queue => :tqq_init_scripts, :backtrace => true
  
  def perform(openid)
    MonitTqqAccount.find_by_openid(openid).init_load
  end
end

