# -*- encoding : utf-8 -*-
class Upload < ActiveRecord::Base

  include Customize::ImageGeo

  attr_accessor :new_file_name
  attr_accessor :tmp_content_type

  has_many  :file_references
  has_attached_file :attachment ,
                    :path => ":rails_root/public/system/:attachment/:id/:style/:normalized_file_name",
                    :url => "/system/:attachment/:id/:style/:normalized_file_name" 
  
  Paperclip.interpolates :normalized_file_name do |attachment, style|
    attachment.instance.normalized_file_name
  end


  before_create :fix_attachment_name



  def file_path(style=nil)
    attachment.url style
  end


  # rename file name
  # http://blog.wyeworks.com/2009/7/13/paperclip-file-rename
  def normalized_file_name
    extension = File.extname(attachment_file_name)
    basename = File.basename(attachment_file_name,extension)
    if !@new_file_name.blank?
      new_file_name = @new_file_name + extension.downcase
      return new_file_name
    elsif basename.length > 240
    	return rand(9999).to_s+Time.new.to_i.to_s+extension.downcase
    else
      return basename+extension.downcase
    end
    
  end


  # for jquery-fileupload-rails
  include Rails.application.routes.url_helpers
  def to_jq_upload
    {
      "name" => read_attribute(:attachment_file_name),
      "size" => read_attribute(:attachment_file_size),
      "url" => attachment.url(:original),
      "delete_url" => upload_path(self),
      "delete_type" => "DELETE" 
    }
  end
  
private


  def fix_attachment_name
    self.attachment_file_name = normalized_file_name
  end


end
