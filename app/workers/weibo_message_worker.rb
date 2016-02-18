# -*- encoding : utf-8 -*-
class WeiboMessageWorker

  include Sidekiq::Worker
  sidekiq_options :queue => :weibo_message, :backtrace => true
  
  def perform(id)
    MWeiboMessage.find(id).run
  end
end

