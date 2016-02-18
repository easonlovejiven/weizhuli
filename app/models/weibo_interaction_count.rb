# -*- encoding : utf-8 -*-
class WeiboInteractionCount < ActiveRecord::Base
  scope :weibo, where(:platform=>"weibo")
  scope :tqq, where(:platform=>"tqq")
end
