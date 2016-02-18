# -*- encoding : utf-8 -*-
class WeiboContentCountSnapDaily < ActiveRecord::Base
  attr_accessor :new_weibo_forwards,:new_weibo_comments,:new_forwards,:new_comments
end
