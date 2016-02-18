# -*- encoding : utf-8 -*-
class NotificationObserver < ActiveRecord::Observer

#  observe :feedback

  def after_create(record)
    email_method = "#{record.class.to_s.underscore}_creation_email"
    Emailer.delay.send(email_method,record)
  end


end

