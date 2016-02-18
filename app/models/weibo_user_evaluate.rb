class WeiboUserEvaluate < ActiveRecord::Base
  attr_accessible :comment_average, :comment_rate, :day_posts, :day_posts_in_week, :fake, :forward_average, :forward_rate, :male_fans, :origin_rate, :uid
end
