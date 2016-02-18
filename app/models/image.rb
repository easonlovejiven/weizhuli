# -*- encoding : utf-8 -*-
class Image < Upload

  include Customize::ImageGeo
  attr_accessor :crop_x, :crop_y, :crop_w, :crop_h

  has_attached_file :attachment , :styles => lambda {|attachment| attachment.instance.styles  },
                    :path => ":rails_root/public/system/:attachment/:id/:style/:normalized_file_name",
                    :url => "/system/:attachment/:id/:style/:normalized_file_name" ,
                    :processors => lambda{|instance| instance.processors },
                    :convert_options => {:all => "-quality 80 -strip"} # see http://www.karlstanley.net/blog/?p=4

  after_post_process :save_image_dimensions

  validate :validate_image_size


  def validate_image_size
    case @tmp_content_type
      when "some value"
        if [self.attachment_width , self.attachment_height].max < 1600 ||
          [self.attachment_width , self.attachment_height].min < 800
          errors[:base] << "图片尺寸不能小于 800x1600"
        end
    end
  end

  # use for rendoring json in controller
  def file_path
    paths = {}
    (attachment.styles.keys+[:original]).each{|style|
      paths[style] = attachment.url(style)
    }
    return paths
  end

  def medium_file_url
    file_url(:medium)
  end
  def thumb_file_url
    file_url(:thumb)
  end
  
  
  def styles
    # depend on different content_type, useing different styles
    case @tmp_content_type
      when "a type"
        {:medium => "300x300>", :index_thumb=>"150x150>",:thumb => "100x100>"}
      else
        {:medium => "300x300>", :index_thumb=>"200x125>",:thumb => "100x100>" }
    end
  end
  
  def cropping?
    !crop_x.blank? && !crop_y.blank? && !crop_w.blank? && !crop_h.blank?
  end
  
  def image_geometry(style = :original)
    @geometry ||= {}
    @geometry[style] ||= Paperclip::Geometry.from_file(attachment.path(style))
  end
  
  
  def processors
    return cropping? ? [:cropper] : [:thumbnail]
  end


  def save_image_dimensions
    geo = Paperclip::Geometry.from_file(attachment.queued_for_write[:original])
    self.attachment_width = geo.width
    self.attachment_height = geo.height
  end
  
end
