# -*- encoding : utf-8 -*-
class Feedback < ActiveRecord::Base
  include Customize::Verificatable

  STATUS_NOT_DEAL = 0
  STATUS_IN_PROCESS = 1
  STATUS_HAS_BOUGHT = 2
  STATUS_NOT_BUY = 3

  validate :check_detail

  def check_detail
    if self.details.blank?
      self.errors[:price_status] << _("请您填写您的问题或反馈内容")
    end
  end

  def status_text
    case status
      when 0
        return _("未处理")
      when 1
        return _("处理中")
      when 2
        return _("问题解决")
      when 3
        return _("无法解决")
    end
  end

end

