# 积分策略
## type: 注册，收入1元，拉入一人，下级拉人，拉入厂家，下级拉厂家，拉入商家，下级拉商家，签到
# 更新积分
module Integralable
  extend ActiveSupport::Concern

  included do |base|
    after_commit :update_integral, on: :create
  end

  def update_integral
    Core::IntegralDetail.send(self.class.to_s.underscore.gsub('/', '_'), self)
  end
end

##
# => 积分纪录表
# signed_at 获取时间
# point 本次签到获取金豆数
## type: 注册，收入1元，拉入一人，下级拉人，拉入厂家，下级拉厂家，拉入商家，下级拉商家，签到
class Core::IntegralDetail < ActiveRecord::Base
  self.table_name = :core_integral_details
  belongs_to :user, class_name: 'Core::User', foreign_key: :user_id

  RULE = {
    1 => '注册',
    2 => '收入',
    3 => '邀请用户',
    4 => '下级邀请用户',
    5 => '邀请厂家',
    6 => '下级邀请厂家',
    7 => '邀请商家',
    8 => '下级邀请商家',
    9 => '签到'
  }

  RULE_VAL = {
    1 => 50,
    2 => 10,
    3 => 10,
    4 => 5,
    5 => 200,
    6 => 100,
    7 => 100,
    8 => 50,
    9 => 1
  }

  def type_name
    RULE[point_type]
  end

  class << self

    def core_user(obj)
      add_point_count_log(obj, 1, RULE_VAL[1])
      # 邀请用户得积分
      fx_user_parent = obj.fx_user.try(:parent)
      if  fx_user_parent
        level1_user = Core::User.find_by(id: fx_user_parent.id)
        level2_user = Core::User.find_by(id: fx_user_parent.parent.try(:id))
        add_point_count_log(level1_user, 3, RULE_VAL[3]) if level1_user
        add_point_count_log(level2_user, 4, RULE_VAL[4]) if level2_user
      end
    end

    def trade_transaction(obj)
      return false unless [11, 12, 13, 14, 15].include? obj.optype
      return false unless obj.target
      add_point_count_log(obj.target, 2, (RULE_VAL[2] * obj.amount))
    end

    def mind_store(obj)
      deal_store_shop(obj.mind_id, 7, 8)
    end

    def mind_shop(obj)
      deal_store_shop(obj.mind_id, 5, 6)
    end

    private

    def add_point_count_log(core_user, point_type, point)
      return false unless core_user
      core_user.update_column(:point_count, core_user.point_count + point)
      core_user.integrals.create(point_type: point_type, point: point)
    end

    def deal_store_shop(mind_id, point_type, superior_point_type)
      invite_user = Core::User.find_by(id: mind_id)
      # 管家邀请
      add_point_count_log(invite_user, point_type, RULE_VAL[point_type]) if invite_user
      # 管家上级
      #add_point_count_log(invite_user.try(:superior).try(:core_user), superior_point_type, RULE_VAL[superior_point_type])
      if invite_user
        fx_user_parent = invite_user.fx_user.try(:parent)
        level1_user = Core::User.find_by(id: fx_user_parent.try(:id))
        add_point_count_log(level1_user, superior_point_type, RULE_VAL[superior_point_type]) if level1_user
      end
    end
  end
end

# 注册，收入1元，拉入一人，下级拉人，拉入厂家，下级拉厂家，拉入商家，下级拉商家，签到
在以上节点的models中包含Integralable module 通过回调触发
