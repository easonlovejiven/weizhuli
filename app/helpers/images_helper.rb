# -*- encoding : utf-8 -*-
module ImagesHelper


  # show image for a uploaded image
  # API: ce_image(user, :avatar, image_style, image_options)
  #   argu1 : a model object
  #   argu2 : the Image attribute name which associated to the model
  #   argu3 : image_style , like :thumb, :medium ...
  #   argu4 : image_options, transfer to image_tag 
  # if the image attribute is nil, this method will try to 
  #    get the [attribute_name]_default from the object, to show a defult 
  #    if can not get a default image, display nothing
  #
  # IF you want scaling your image to fix the width and height of a block
  #   just set image_options[:scaling] = true, but when you use :scaling, 
  #   you must set :size, else it doesn't work
  # IF you want make image vertical-align is center, use :vertical-align=>true
  #
  # example : ce_image(User.last, :avatar, :thumb, {:size=>"50x50", :scaling=>true, :class=>"abc", :vertical_align=>true})
  
  def ce_image(object, attribute, image_style=nil, image_options={})
    image = object.send(attribute)
    
    scaling = image_options.delete(:scaling)
    scaling_ratio = 1
    size = image_options.delete(:size)
    vertical_align = image_options.delete(:vertical_align)
    lazy_load = image_options.delete(:lazy_load) || false
    if lazy_load
      image_options[:class] ||= ""
      image_options[:class] += " lazy"
    end
    
    
    # if scaling, reset the size
    if image && scaling && size
      width, height = size.split("x")
      size, scaling_ratio = image.get_scale_size_for_paperclip(:attachment,width,height)
    end
    image_options[:size] = size
    image_options[:"data-scale-ratio"] = scaling_ratio
    
    # if vertical_align, set css "top"
    if height && vertical_align
      img_height = size.split("x")[1] # get image height
      # if image_height less than container height, compute top
      if img_height.to_i < height.to_i
        top = (height.to_i - img_height.to_i) / 2
        image_options[:style] = "margin-top:#{top}px" + (image_options[:style] || "")
      end
    end
    
    
    # if image attribute is nil, show default image
    if !image.nil?
      if lazy_load
        image_options['data-original'] = image_path(image.attachment.url(image_style))
        return image_tag "grey.gif",  image_options
      else
        
        return image_tag image.attachment.url(image_style), image_options
      end
    else
      default_image_method = attribute.to_s+"_default"
      # if model don't supplied the default image url method, show nothing
      if object.respond_to? default_image_method
        url = object.send(attribute.to_s+"_default",image_style)
        if url
          if lazy_load
            image_options['data-original'] = image_path(url)
            return image_tag "grey.gif",  image_options
          else
            return image_tag url , image_options
          end
        else
          raise "can not get default image url with style \"#{image_style}\" for #{object}"
        end
      else
        return nil
      end
    end
  end




  # return user avatar image tag
  def user_avatar_tag(user, style, opts = {})
    if user.avatar || user.property.avatar.blank?
      ce_image(user, :avatar, style, opts)
    elsif user.property.avatar
      image_tag user.property.avatar, opts
    end
  end


end

