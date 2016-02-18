# -*- encoding : utf-8 -*-
class SmsCodeWorker

  include Sidekiq::Worker
  sidekiq_options :queue => :sms_code, :backtrace => true
  
  def perform(id,mobile)
    sms_code = SmsCode.find_by_id(id)
    if sms_code
      sms = Sms.new
      sms.send_sms [sms_code.mobile], "感谢您注册微助力, 您的短信验证码是 #{sms_code.code}【微助力】"
    end
  end
end

