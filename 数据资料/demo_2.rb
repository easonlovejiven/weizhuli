##
# = 运送方式表(配送区域)
#
# == Fields
#
# freight_template_id :: 模板id外键
# area_ids :: 目的地 运送地区(存id,格式为'省-市-区',以'-'分隔)
# frist_item :: 首件
# first_fee :: 首费
# reforwarding_fee :: 续费
# first_amount :: 首
# additional_amount :: 续
# delivery_way :: 运送方式
# is_default? :: 是否是默认运送方式
# active? :: 有效？
#
class Mind::Freight < ActiveRecord::Base
  self.table_name= :shop_freights
  
  belongs_to :freight_template, class_name: 'Mind::FreightTemplate', foreign_key: :template_id
  
  before_save do
    self.active = true
  end
  
  DELIVERY_STATE = {'顺丰' => 0, '宅急送' => 1, '联邦' => 2, '邮政' => 3}
  DEFAULT_STATE  = {'不是' => 0, '是' => 1}
  
  def default_name
    DEFAULT_STATE.invert[self.is_default]
  end
  
  def delivery_way_name
    DELIVERY_STATE.invert[self.delivery_way]
  end
  
  def area_format
    Data::Province.where(id: area_ids.split(',').flatten).pluck(:name).join(',')
  end
  
  def area_ids
    read_attribute(:area_ids).to_s.split(',')
  end
  
  def area_ids=(value)
    write_attribute(:area_ids, value.try(:join, ','))
  end
  
  def self.destroy_and_create!(template_id, freights)
    self.where(freight_template_id: template_id).destroy_all
    return if freights.blank?
    data = []
    freights.each do |freight|
      raise ArgumentError, type_error(template_id) if freight[:first_fee].to_i > 0 && freight[:first_amount].to_i == 0
      data << {freight_template_id: template_id, delivery_way: freight[:delivery_way], area_ids: freight[:area_ids], is_default: freight[:is_default], first_fee: freight[:first_fee], additional_fee: freight[:additional_fee], first_amount: freight[:first_amount], additional_amount: freight[:additional_amount]}
    end
    self.create!(data)
  end
  
  def self.type_error temp_id
    temp = ::Mind::FreightTemplate.find_by(id: temp_id)
    if temp.valuation_type == 0
      '你设置了首件运费，首件数不能为0'
    else
      '你设置了首重运费，首重数不能为0'
    end
  end
  
  # 运费计算方式
  # quantity：是模板中的数量或重量的总和
  def calculation(quantity)
    return first_fee if quantity <= first_amount || additional_amount == 0
    remain_num = quantity - first_amount
    first_fee + (remain_num / additional_amount.to_f).ceil * additional_fee
  end

  # 查找当前使用哪种计算方式
  def self.calculation(template_id, quantity, province_id)
    freights = where(freight_template_id: template_id)
    freight  = freights.select { |f| f.area_ids.include?(province_id.to_s) }.first || freights.first
    #tofix 会出现 shop_freight_templates 的 shop_freights为空的情况，例： （ID： 120）
    freight ? freight.calculation(quantity)  : 0
  end

end