class Kol < ActiveRecord::Base
  attr_accessible :uid,:description, :interactions, :name, :used_number

  has_many  :purchases, :class_name=>"KolPurchase"

  accepts_nested_attributes_for :purchases


  after_save  :save_used_number



  def save_used_number
    self.update_column :used_number,purchases.count
  end
end
