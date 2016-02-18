class TqqUserInteractionSnapWeekly < ActiveRecord::Base
  attr_accessible :commented_count, :date, :forwarded_count, :from_openid, :interacted_count, :mentioned_count, :openid
end
