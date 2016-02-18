# -*- encoding : utf-8 -*-
module ApplicationHelper

  def first_access?
    cookies[Rails.application.config.session_options[:key]].blank?
  end


  def friendly_location_name(name)
    name.gsub("市","")
  end






  def my_cache(should_cache, *args,&block)
    if should_cache
      
      # store all cache key to db
      # when expire, just find these keys to delete
      key = args.first

      CacheKey.create(:key=>key, :url=>controller.fragment_cache_key(key)) if CacheKey.where(:key=>key).blank?
      
      return cache(*args,&block)
    else
      return block.call
    end
  end
  
  
  
  def truncate_u(string, options={})
    chars = string.split(//)
    if chars.size > options[:length]
      return chars[0..options[:length]-1].to_s+(options[:suffix] || "...")
    end
    return string
  end

  def str_length(string)
  	return 0 if string.blank?
    string = string.split(//)
    string.length
  end

=begin
 def user_salutation(user)
    if user.profile.nil?
       return s_("他(她)")
    else
      if !current_user.blank?
        if current_user.id == user.id
          return s_('我')
        end
      end
      	
      if user.profile.gender
        return s_("他")
      elsif user.profile.gender.nil?
        return s_("他(她)")
      else
        return s_("她")
      end
  end
end
=end

def user_salutation(user)
    if user.business_card.nil?
       return s_("他(她)")
    else
      if !current_user.blank?
        if current_user.id == user.id
          return s_('我')
        end
      end
      	
      if user.business_card.gender
        return s_("他")
      elsif user.business_card.gender.nil?
        return s_("他(她)")
      else
        return s_("她")
      end
  end
end


  def strip_html(content)
    strip_tags(content.gsub("&nbsp;","").gsub("&gt;","").gsub("&gl;",""))
  end



  def go_back_link(content=nil, &block)
    if block
      link_to yield, session[:last_link]
    else
      link_to content||(_("<<返回")+session[:last_link_title]), session[:last_link]
    end
  end


  def error_msg(form,att)
    if !form.error_message_on(att).blank?
      content_tag(:div, :class=>"error_msg mgL110 radius2") do
        raw(form.object.errors[att])
      end
    else
      nil
    end
  end

end
