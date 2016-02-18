# -*- encoding : utf-8 -*-
class TagRelation < ActiveRecord::Base

  belongs_to  :tag
  belongs_to  :content, :polymorphic=>true

end
