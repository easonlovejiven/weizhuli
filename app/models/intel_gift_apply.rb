# -*- encoding : utf-8 -*-
class IntelGiftApply < ActiveRecord::Base

  APPROVERS = %w{sherry.yu@intel.com rita.zhang@intelsocial.com tg.plus@live.cn xiaowen.li@weizhuli.com boll.yue@weizhuli.com}



  attr_accessible :approve_code, :approver, :campaign, :intel_gift_id, :status, :total_price, :use_number, :use_time,
    :items_attributes, :account, :approve_emails, :apply_description

  has_many  :items, :class_name=>"IntelGiftApplyItem",:dependent=>:destroy
  belongs_to  :applyer, :class_name=>"User"
  

  accepts_nested_attributes_for :items


  before_save :compute_total_price
  after_create  :send_approve_emails


  scope   :campaign_eq, ->(c){where(campaign:c)}
  scope   :use_time_gt, ->(c){where("use_time >= ?",c)}
  scope   :use_time_lt, ->(c){where("use_time <= ?",c)}



  def gen_approve_code
    code = (0...6).map{ ('a'..'z').to_a[rand(26)] }.join
    self.approve_code = code
  end

  def gen_approve_code!
    gen_approve_code
    save!
  end


  def human_status
    {0=>"待审核",1=>"通过审核",2=>"已拒绝"}[status]
  end


  def compute_total_price
    t = 0
    items.each{|item| t += item.intel_gift.price * item.number}
    self.total_price = t
    puts
  end


  def send_approve_emails
    if status == 0
      approve_emails.split("\n").each{|email|
        Notifier.intel_gift_apply_appove(email,self).deliver
      }
    end
  end

  def self.mysearch(queries)
    scope = scoped
    (queries||[]).each{|key,val|
      next if val.blank?
      scope = scope.send(key,val)
    }
    scope
  end



end
