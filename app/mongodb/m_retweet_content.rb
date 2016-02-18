# -*- encoding : utf-8 -*-
class MRetweetContent
  include MongoMapper::Document

  belongs_to :user, :class_name=>"MUser"

end

