# -*- encoding : utf-8 -*-
class IntelGiftApplyItem < ActiveRecord::Base
  attr_accessible :intel_gift_apply_id, :intel_gift_id, :number
  belongs_to  :intel_gift_apply
  belongs_to  :intel_gift
end
