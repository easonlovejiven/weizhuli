class WeiboSentComment < ActiveRecord::Base
  attr_accessible :comment_at, :comment_id, :content, :target_uid, :target_weibo_id, :uid
  scope :time_between, ->(start_time,end_time){where("comment_at >= ? and comment_at < ?", start_time,end_time)}
end
