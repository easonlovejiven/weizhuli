# -*- encoding : utf-8 -*-
class MPinganbeijingMonitAccount
  # 平安北京相关 监控帐号每日信息

  include MongoMapper::Document

  key :site,  String

  key :uid, Integer
  key :date,  DateTime
  key :screen_name, String
  key :followers_count, Integer
  key :friends_count,   Integer
  key :statuses_count,   Integer

  key :origin_statuses_count, Integer
  key :forward_statuses_count,  Integer

  key :forwards_count,  Integer
  key :comments_count,  Integer
  key :forwards_count_in_day, Integer
  key :comments_count_in_day, Integer

  key :origin_status_forwards,  Integer
  key :origin_status_comments,  Integer
  key :origin_status_forwards_in_day,  Integer
  key :origin_status_comments_in_day,  Integer

  key :mentions_count,  Integer
  key :mentions_count_30,  Integer
  key :mentions_count_7,  Integer
  key :last_mention_content,  String
  key :last_mention_time, DateTime

  timestamps!


end