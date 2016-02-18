# -*- encoding : utf-8 -*-
class TinyVideo < ActiveRecord::Base

  has_attached_file :original
  #, :path => "videos/:original/:id.:extension",
  belongs_to :user

end

