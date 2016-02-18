class WeiboPrivateMessage < ActiveRecord::Base
  attr_accessible :content, :message_id, :send_at, :target_uid, :uid
  scope :time_between, ->(start_time,end_time){where("send_at between ? and ?", start_time,end_time)}
end
