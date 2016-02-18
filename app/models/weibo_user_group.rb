class WeiboUserGroup < ActiveRecord::Base
  attr_accessible :name, :user_id, :weibo_type
end
