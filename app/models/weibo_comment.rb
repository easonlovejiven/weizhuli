# -*- encoding : utf-8 -*-
class WeiboComment < ActiveRecord::Base
  belongs_to  :comment_user,  class_name:"WeiboAccount", :foreign_key=>"comment_uid", :primary_key=>"uid"
  scope :time_between, ->(start_time,end_time){where("comment_at between ? and ?", start_time,end_time)}
end
