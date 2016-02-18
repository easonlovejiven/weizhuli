# -*- encoding : utf-8 -*-
class Reports::DailiesController < ApplicationController

  layout "reports"

  def index

    if current_user.nil? || current_user.authentications.blank?
      redirect_to new_reports_user_path(weixin_openid:params[:weixin_openid])
      return 
    end


    yesterday = Date.yesterday
    #@uid = current_user.authentications.weibo.first.uid
    @uid = current_user.authentications.first.uid
    m = MonitWeiboAccount.initialized.find_by_uid(@uid)
    if m.nil?
      render  :text=>"您的微博帐号还没有完成数据监控"
    else
      last_snap = WeiboAccountSnapDaily.where(uid:@uid).last
      if last_snap
        redirect_to reports_daily_path(@uid, date:last_snap.date)
      else
        render  :text=>"您的微博帐号还没有完成数据监控"
      end
    end


  end


  def show
    @uid = params[:id]
    @date= Date.parse(params[:date])
    @yesterday = @date.yesterday
    if current_user.authentications.weibo.where(uid:@uid).first
      render :layout=>false
    else
      render  :text=>"微博帐号未绑定"
    end

  end
end
