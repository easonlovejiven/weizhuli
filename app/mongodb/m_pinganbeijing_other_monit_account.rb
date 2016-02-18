# -*- encoding : utf-8 -*-
class MPinganbeijingOtherMonitAccount
  # 平安北京相关 sohu, renmin 监控帐号每日信息

  include MongoMapper::Document

  key :site,  String

  key :uid, Integer
  key :date,  Date
  key :screen_name, String
  key :followers_count, Integer
  key :friends_count,   Integer
  key :statuses_count,   Integer


  key :forwards_count,  Integer
  key :comments_count,  Integer
  key :mentions_count,  Integer

  timestamps!


end