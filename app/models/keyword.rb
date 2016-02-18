class Keyword < ActiveRecord::Base
  attr_accessible :category_id, :name, :user_id

  belongs_to  :category,  :class_name=>"KeywordCategory"

  scope :user,  ->(user){where("user_id = ?", user.id)}

  
end

