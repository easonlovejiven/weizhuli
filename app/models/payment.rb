# -*- encoding : utf-8 -*-
class Payment < ActiveRecord::Base

  STATUS_NEW = 0
  STATUS_PROCESSING = 1
  STATUS_SUCCESSED = 2
  STATUS_FAILED = 3

  after_save :check_status


  belongs_to  :order


  scope   :successed, where(["payments.status = ?", STATUS_SUCCESSED])
  



  def successed?
    self.status == STATUS_SUCCESSED
  end


  def failed?
    self.status == STATUS_FAILED
  end



  def pay_success
    update_attribute(:status, STATUS_SUCCESSED)
  end

  def pay_failed
    update_attribute(:status, STATUS_FAILED)
  end


  # 
  def check_status
    if(status_changed? && status_change[1] == STATUS_SUCCESSED)
      self.order.check_payment_status
    end
  end

end
