# -*- encoding : utf-8 -*-
class MForward
  include MongoMapper::Document

  belongs_to  :user, :class_name=>"MUser"
  belongs_to  :weibo, :class_name=>"MWeiboContent"

end

