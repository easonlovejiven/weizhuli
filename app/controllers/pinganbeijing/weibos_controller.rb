# -*- encoding : utf-8 -*-
class Pinganbeijing::WeibosController < Pinganbeijing::ApplicationController
  layout "client"

  def index

    @q = params[:search] || {}

    @account_type= params[:account_type]

    # @uids = PinganbeijingAccountsLog::UIDS[@account_type]
    # @uids = @uid if @uids.blank?

    @uids = [params[:uid]]

    if @uids.compact.blank?
      render :text=>"参数错误"
      return false
    end
    @weibos = WeiboDetail.where(uid:@uids).mysearch(@q).order("weibo_id desc").paginate(:page=>params[:page],:per_page=>20)

    
  end
end
