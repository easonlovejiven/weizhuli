# -*- encoding : utf-8 -*-
class WeixinReportMailWorker

  include Sidekiq::Worker
  sidekiq_options :queue => :email, :backtrace => true
  
  def perform(user_id)
    email_body = <<-EOF
      您的日报
    EOF




    Notifier.report(to:"huye@weizhuli.com", subject:"您的日报",body:email_body).deliver
  end
end

