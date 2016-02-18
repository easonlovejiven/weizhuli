class IntelbizUpdateUser < ActiveRecord::Base
  attr_accessible :name, :status, :uid

  scope :time_between, ->(start_time,end_time){ where("updated_at between ? and ?",start_time,end_time)}
end
