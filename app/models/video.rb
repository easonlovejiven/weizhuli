# -*- encoding : utf-8 -*-
class Video < ActiveRecord::Base
	include Customize::Locale
	
	belongs_to :videoable, :polymorphic => true
end
