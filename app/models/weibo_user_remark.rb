class WeiboUserRemark < ActiveRecord::Base
  attr_accessible :address, :company, :demo, :email, :interactions, :phone, :real_name, :uid, :user_id, :group_id

  belongs_to  :group, :class_name=>"WeiboUserGroup"
end
