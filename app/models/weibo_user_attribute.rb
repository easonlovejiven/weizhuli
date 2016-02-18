class WeiboUserAttribute < ActiveRecord::Base
  attr_accessible :keyword_id, :uid, :user_id, :weight
  
  belongs_to  :keyword
  
end
