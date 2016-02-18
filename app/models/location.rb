# -*- encoding : utf-8 -*-
class Location < ActiveRecord::Base

  acts_as_nested_set
  
  
  
  include Customize::Searchable
  include Customize::Locale

  STATUS_DISABLED = 0
  STATUS_AVAILABLE = 1
  
  FIRST_TIER = [2,3,4,5,158,289,346,303,221,167,144,193,132,376,180,367,121,275,399,258,241,431,110,436,230,338,409,423,204,324]

  has_many :productions
  #has_friendly_id :friendly_id_string,:use_slug => true
  
  scope :parent_id_eq, lambda{|pid| where(["parent_id = ?",pid])}
  scope :available, where({:status=>STATUS_AVAILABLE})
  
  scope :with_parent_and_locale, lambda{|params|
    parent_id,level = params
    l = Location.find(parent_id)
    
    case level
      when "province"
        where({:parent_id=>parent_id})
      when "city"
          where({:parent_id=>parent_id})
      when "region"
          where({:parent_id=>parent_id})
    end
    
  }
  scope :name_like, lambda{|p|{:include => [:locales],:conditions => ['location_locales.name like ? or location_locales.name like ? ',"%#{p}%","%#{p}%"] }}

  

  AVAILABLE_SEARCH_KEYS = [:name_starts_with, :parent_id_eq, :with_parent_and_locale, :name_like]

  #search_methods  :with_parent_and_locale, :name_like


  def children_class
    child_class_map = {
	    Country => Province,
      Province => City,
      City => Region,
      Region => Area,
    }
    return child_class_map[self.class]
  end



  
#this method only for friendly_id do't change it
  def friendly_id_string
     self.name.to_url
  end


  def set_available
    self.update_attribute(:status, STATUS_AVAILABLE)
  end

  def set_disable
    self.update_attribute(:status, STATUS_DISABLED)
  end

  def available?
    status == STATUS_AVAILABLE
  end

  def human_status
    {0=>"不可用",1=>"可用"}[status]
  end
  
  def self.first_tier
  	self.where("id in (?)", FIRST_TIER)
  end



:private

  def after_save

    # if self a availabe, make parent available
    if self.available?
    
      self.parent.set_available if self.parent

      # if all childre a disabled, make self disable
      if !self.children.blank? && !self.children.map(&:status).include?(1)
        self.set_disable
      end
    end
  end
end
