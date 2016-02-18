# -*- encoding : utf-8 -*-
class MPinganbeijingMonitAccountInfo
  # 平安北京相关 监控帐号每日信息

  include MongoMapper::Document


  key :uid, Integer
  key :weibos,  Array

  timestamps!


end