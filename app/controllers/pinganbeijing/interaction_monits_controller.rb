# -*- encoding : utf-8 -*-
class Pinganbeijing::InteractionMonitsController < ApplicationController

  layout "client"

  def index

    @range = params[:range] || "1"

    @account_type= params[:account_type]

    @sort_col = params[:sort_col] || "interactions_count"
    @sort_type = params[:sort_type] || "0"

    operator = @sort_type == '1' ? :asc : :desc
    s = @sort_col.to_sym.send(operator)


    @accounts = MPinganbeijingInternalMonitAccount.where(date:Date.yesterday.to_mongo)
    @accounts = @accounts.where(uid:MPinganbeijingInternalMonitAccount::UIDS) if params[:type]
    @accounts = @accounts.sort(s)


  end

end
