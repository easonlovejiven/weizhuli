# -*- encoding : utf-8 -*-
class UpdateWeiboQualityTask < WeiboTaskBase

  def run
    begin
      as = WeiboAccount.includes(:user_quality).where("weibo_user_evaluates.id is null").limit(1000)
      as.each{|a|
        a.update_evaluates
      }
    end while as.blank?
  end


end
