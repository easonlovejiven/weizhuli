# -*- encoding : utf-8 -*-
class UpdateWeiboAccountQualityWorker

  include Sidekiq::Worker
  sidekiq_options :queue => :update_weibo_account_quality, :backtrace => true,  :retry=>6
  
  def perform()
    begin
      as = WeiboAccount.includes(:user_quality).where("weibo_user_evaluates.id is null").limit(1000)
      as.each{|a|
        puts "Update weibo account evaluate for uid #{a.uid}"
        begin
          a.update_evaluates
        rescue Exception=>e
          puts e.message
        end
      }
    end while !as.blank?
  end
end

