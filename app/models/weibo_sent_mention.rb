class WeiboSentMention < ActiveRecord::Base
  attr_accessible :content, :mention_at, :mention_id, :target_uid, :uid
  scope :time_between, ->(start_time,end_time){where("mention_at >= ? and mention_at < ?", start_time,end_time)}
end
