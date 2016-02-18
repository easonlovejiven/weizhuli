class TqqUserRelation < ActiveRecord::Base
  attr_accessible :by_openid, :each_other, :follow_time, :openid
end
