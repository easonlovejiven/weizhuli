class TqqContentCountSnapHourly < ActiveRecord::Base
  attr_accessible :be_commented_count, :be_forwarded_count, :commented_count, :date, :forward_count, :image_count, :music_count, :new_statuses_count, :openid, :origin_count, :statuses_count, :video_count
end
