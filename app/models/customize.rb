# -*- encoding : utf-8 -*-
module Customize


  module Counter

    def self.included(klass)
      klass.class_eval do
        def self.auto_counter(attr)
          eval <<-EOF
            def increase_#{attr}
              self.update_attribute(:#{attr}, self.#{attr}+1)
            end
            def decrease_#{attr}
              self.update_attribute(:#{attr}, self.#{attr}-1)
            end
          EOF
        end
      end
    end
  
  
  end
  
  
  module Locale

    def self.included(klass)
      klass.class_eval do

        
        def self.locale_class_name
          if self.superclass == ActiveRecord::Base
            self.to_s+"Locale"
          else
            self.superclass.to_s+"Locale"
          end
        end
        
        def self.locale_table_name
          locale_class_name.constantize.table_name
        end



        after_initialize :integrate_locale_attributes
        has_many  :locales, :class_name=>locale_class_name,:dependent=>:destroy
        has_one   :current_locale,  :class_name=>locale_class_name, :conditions=>proc{[self.class.locale_table_name+".locale = ?",I18n.locale]}
        accepts_nested_attributes_for :locales, :allow_destroy => true
        accepts_nested_attributes_for :current_locale, :allow_destroy => true
        #scope :with_locale, includes(:locales).where([locale_table_name+".locale = ?",I18n.locale])
        



        def correct_locale
          (locales.select{|loc|loc.locale == I18n.locale.to_s}.first || locales.first)
        end
        

        
      :private
      
        # dynamic integrate current locale attributes to main object
        # for example : event.title = event.locale.title, ...
        def  integrate_locale_attributes    
          self.class.locale_class_name.constantize.column_names.each{|key|
            attrs = self.attributes.keys
            if !attrs.include?(key) && !self.respond_to?(key)&&
              self.class.to_s.underscore+"_id" != key &&
              # except these keys
              !["id","created_at","updated_at"].include?(key)
              self.class.class_eval <<-EOF
              
                def #{key}
                  if locales.loaded?
                    l = correct_locale
                    l && l.#{key}
                  else
                    (current_locale || locales.first).#{key}
                  end
                end
              EOF
              
            end
          }
        end
        
        
      end
    end
  end
  
  
  module ImageGeo
    
    DEFAULT_PICTURE_WIDTH = 1550
    DEFAULT_PICTURE_HEIGHT = 1600
  
  
    
    def get_scale_size_for_paperclip(attribute,width,height)
      org_width = send(attribute.to_s+"_width")
      org_height = send(attribute.to_s+"_height")
      return get_scale_size(DEFAULT_PICTURE_WIDTH,DEFAULT_PICTURE_HEIGHT,width,height) if org_width.blank? ||org_height.blank?
      return get_scale_size(org_width,org_height,width,height)
    end
    
    def get_scale_size(org_width,org_height,width,height)
      ratio = org_width.to_f/org_height.to_f
      ratio_new = width.to_f/height.to_f
      scale = (ratio < ratio_new ? height.to_f/org_height.to_f : width.to_f/org_width.to_f)
      return ["#{(org_width*scale).to_i}x#{(org_height*scale).to_i}", scale]
    end
  
  
  end
  

  #####################
  # obj.check_verification_code = true
  # obj.inputed_verification_code = params[:valid_code]
  # obj.verification_code = session[:valid_code]
  ######################
  module  Verificatable
    def self.included(klass)
      klass.class_eval do
        attr_accessor :verification_code, :inputed_verification_code, :check_verification_code
        validate :validate_verification_code
        
        def set_verification_code(code1,code2)
          @check_verification_code = true
          @inputed_verification_code = code1
          @verification_code = code2
        end
        
        def validate_verification_code
          if(@check_verification_code == true && (@verification_code != @inputed_verification_code || @inputed_verification_code.blank?))
            errors[:verification_code] << _("您输入的验证码不正确")
          end
        end
      end
    end
  end



  # every model will have a "search" method,
  # used "searchlogic" method.
  # params : named_scope name and value (include searchlogic named_scope)
  # Note : you need create a constants AVAILABLE_SEARCH_KEYS in each model, 
  #           to define which named_scope can be used for this model
  module Searchable

    def self.included(klass)
      klass.class_eval do
        extend Extend
      end
    end
    
    module Extend
      def search(params={})
        # google search "dynamic composition named_scopes"
        # http://www.ruby-forum.com/topic/165600
        # http://refactormycode.com/codes/788-advanced-search-form-named-scopes
        # http://github.com/binarylogic/searchlogic
        scope = scoped({})
        return scope if params.nil?
        # use ransack instead of meta_search
        scope = scope.ransack(params.delete_if{|k,v| !self::AVAILABLE_SEARCH_KEYS.include?(k.to_s.to_sym)})
        scope
      end
    end
    

  end




  module Taggable
    def self.included(klass)
      klass.class_eval do
        extend Extend
        # relationsships
        has_many    :tag_relations,   :as=>:content,    :dependent=>:destroy
        accepts_nested_attributes_for :tag_relations, :allow_destroy => true,:reject_if=>proc{|img_attrs|img_attrs["tag_id"].blank?}
        has_many    :tags,   :through=>:tag_relations,  :source => :tag
        accepts_nested_attributes_for :tags, :allow_destroy => true
        
        # activerecord callbacks
        before_save :save_tag_relations
        
        scope :with_tag_ids, lambda{|tag_ids|
          includes(:tag_relations).where(["tag_relations.tag_id in (?)", tag_ids])
        }
        
        scope :with_tag_name, lambda{|tag_name|
          with_tag_names([tag_name])
        }
        
        
        
        scope :with_tag_names, lambda{|tag_names|
          tag_names = tag_names.split(/[, ]/) if tag_names.is_a?(String)
          tag_ids = Tag.name_in(tag_names).map(&:id)
          with_tag_ids(tag_ids)
        }
        
        scope :with_tags, lambda{|tags|
          tags = [tags] if tags.is_a?(Tag)
          tag_ids = tags.map(&:id)
          with_tag_ids(tag_ids)
        }
        
        
        attr_accessor :tag_names
        
        def tag_names
          @tag_names ||= tag_relations.map{|tr|tr.tag.name}*","
        end
        
        
        def save_tag_relations
          tag_rels = []
          
          # update tags, and save new tags
          tag_names.split(",").each{|tag_name|
            next if tag_name.blank?
            tag_name = tag_name.strip
            tag = Tag.find_or_create_by_name(tag_name)
            cond = {
              :tag_id=>tag.id,
              :content_id=>self.id,
              :content_type=>self.type,
            }
            tag_relation = TagRelation.find(:first,:conditions => cond) || TagRelation.new(cond)
            tag_rels << tag_relation.attributes.merge(:_destroy => 0)

          }
          
          # remove deleted tags
          self.tag_relations.each{|tr|
            if tag_rels.index{|new_tr|new_tr["id"] == tr.id}.nil?
              tag_rels << {:id=>tr.id, :_destroy=>1}
            end
          }
          self.tag_relations_attributes = tag_rels
        end
        
        
        
        
        
      end
    end


    module Extend
    end

  end
  
  
end
