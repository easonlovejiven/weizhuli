class Client::WeiboUserRemarksController < ApplicationController
  def show
    uid = params[:id]
    remark = WeiboUserRemark.where(user_id:current_user.id,uid:uid).first_or_create
    render :json=>remark
  end

  def update
    uid = params[:id]
    remark = WeiboUserRemark.where(user_id:current_user.id,uid:uid).first_or_create
    remark.update_attributes(params[:weibo_user_remark])
  end
end
