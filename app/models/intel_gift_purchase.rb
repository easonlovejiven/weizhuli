class IntelGiftPurchase < ActiveRecord::Base
  attr_accessible :intel_gift_id, :number, :price, :total_price
  belongs_to  :intel_gift

  before_save :compute_total_price
  after_create  :increase_gift_number
  after_destroy :decrease_gift_number

  def compute_total_price
    self.total_price = intel_gift.price * number
  end

  def decrease_gift_number
    self.intel_gift.number -= number
    self.intel_gift.save!
  end
  def increase_gift_number
    self.intel_gift.number += number
    self.intel_gift.save!
  end
end
