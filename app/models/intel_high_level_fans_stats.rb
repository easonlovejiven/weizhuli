class IntelHighLevelFansStats < ActiveRecord::Base
  attr_accessible :category, :date, :number, :uid

  CATEGORY_HIGH_LEVEL_FANS = 1
  CATEGORY_KOLS = 2
  CATEGORY_KOLS_AVERAGE_INTERACTION = 3
  CATEGORY_HIGH_LEVEL_FANS_AVERAGE_INTERACTION = 4
end
