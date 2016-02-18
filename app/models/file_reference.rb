# -*- encoding : utf-8 -*-
class FileReference < ActiveRecord::Base

  belongs_to  :reference, :polymorphic=>true
  belongs_to  :upload
  belongs_to  :user

  before_create :set_user_id


  def increase_downloads
    self.downloads += 1
    self.save
  end



  def set_user_id
    self.user_id = self.reference.get_user_id if self.reference.respond_to?(:get_user_id)
  end

end
