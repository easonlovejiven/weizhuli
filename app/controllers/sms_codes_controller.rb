class SmsCodesController < ApplicationController

  layout "frontend"


  def create

    @sms_code = SmsCode.new(params[:sms_code])
    if @sms_code.save
      session[:last_sms_code] = Time.now.to_i
      render :json=>{status:"success", :expires_at=>@sms_code.expires_at}
    else
      render :json=>{status:"failed",:errors=>@sms_code.errors}
    end

  end
end
