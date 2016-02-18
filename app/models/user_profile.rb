class UserProfile < ActiveRecord::Base
  attr_accessible :company, :mobile, :phone, :realname, :title, :user_id, :weixin_openid
  belongs_to  :user


  validates :realname,  :presence=>true
  validates :mobile,  :presence=>true



end
