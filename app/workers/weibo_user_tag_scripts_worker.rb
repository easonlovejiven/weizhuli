# -*- encoding : utf-8 -*-
class WeiboUserTagScriptsWorker

  include Sidekiq::Worker
  sidekiq_options :queue => :basic_scripts, :backtrace => true
  
  def perform
    GetUserTagsTask.new.run
  end
end

