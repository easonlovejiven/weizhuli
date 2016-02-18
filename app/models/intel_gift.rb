# -*- encoding : utf-8 -*-
class IntelGift < ActiveRecord::Base
  attr_accessible :description, :name, :number, :owner, :price, :category

  has_many  :intel_gift_purchases
end
