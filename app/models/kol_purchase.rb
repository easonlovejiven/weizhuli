# -*- encoding : utf-8 -*-
class KolPurchase < ActiveRecord::Base

  attr_accessor :use_times, :using

  attr_accessible :kol_attributes,:kol_id,:account, :buyer, :description, :forward_weibo, :forward_weibo_image_id,:origin_weibo_comments, 
  :origin_weibo_forwards, :price, :second_level_comments, 
  :second_level_forwards, :use_time, :cooperation_type, :project,
  :use_times, :using

  belongs_to  :kol
  accepts_nested_attributes_for :kol

  scope :kol_name_eq, lambda{|name|includes(:kol).where("kols.name = ?", name)}
  scope :use_time_gt, lambda{|time|where("use_time >= ?", time)}
  scope :use_time_lt, lambda{|time|where("use_time <= ?", time)}
  scope :second_level_interactions_gt, lambda{|name|where("second_level_forwards >= ?", name)}
  scope :second_level_interactions_lt, lambda{|name|where("second_level_forwards <= ?", name)}
  scope :buyer_eq, lambda{|name|where("buyer = ?", name)}
  scope :price_gt, lambda{|price|where("price >= ?", price)}
  scope :price_lt, lambda{|price|where("price < ?", price)}
  scope :account_eq, lambda{|name|where("account = ?", name)}
  scope :cooperation_type_eq, lambda{|name|where("cooperation_type = ?", name)}
  scope :project_eq, lambda{|name|where("project = ?", name)}


  before_save   :check_using

  def self.mysearch(queries)
    scope = scoped
    queries.each{|key,val|
      next if val.blank?
      scope = scope.send(key,val)
    }
    scope
  end


  def used?
    status == 1
  end



  def check_using
    self.status = 1 if using == "true"
  end


  def status_human
    {1=>'已使用',0=>'未使用'}[status]
  end

end
