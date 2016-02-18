# -*- encoding : utf-8 -*-
class WeiboForwardSpreadWorker

  include Sidekiq::Worker
  sidekiq_options :queue => :gexf_generator, :backtrace => true
  
  def perform(forward_spread_id)
    task = MForwardSpreadTask.find forward_spread_id
    task.run if task
  end
end

