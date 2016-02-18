# -*- encoding : utf-8 -*-
class News < ActiveRecord::Base

  IMAGE_FILE_REF_TYPE_MAIN = "main"
  IMAGE_FILE_REF_TYPE_OTHER  = "other"

  AVAILABLE_SEARCH_KEYS = [:title_contains, :industry_id_equals, :locale_equals, :industry_id_eq]
  ACTIVE_STATUS =  1
  INACTIVE_STATUS = 0
  
  
  
  # for thinking_sphinx
  define_index  do
    
    indexes "''", :as => :empty 
    indexes title
    indexes content
    
    has created_at, updated_at
    has views, :as=>:hot
  end
  # alias thinking_sphinx::search to ts_search
  class << self
    alias ts_search search
  end


  include Customize::Searchable
  include Customize::Taggable


  belongs_to  :category, :foreign_key=>"category_id" ,:class_name=>"NewsCategory"
  has_many  :comments, :as=>:target

  has_one   :image_reference, :class_name=>"FileReference", :conditions=>["category = ?",IMAGE_FILE_REF_TYPE_MAIN], :as=>:reference,
            :dependent=>:destroy
  has_one   :image,  :through=>:image_reference, :source => :upload
  accepts_nested_attributes_for :image_reference, :allow_destroy => true,:reject_if=>proc{|img_attrs|img_attrs["upload_id"].blank?}

  has_many   :image_references, :class_name=>"FileReference", :conditions=>["category = ?",IMAGE_FILE_REF_TYPE_OTHER], :as=>:reference, :dependent=>:destroy
  has_many   :images,  :through=>:image_references, :source => :upload
  accepts_nested_attributes_for :image_references, :allow_destroy => true,:reject_if=>proc{|img_attrs|img_attrs["upload_id"].blank?}






  validates_presence_of :title, :message => "标题不能为空"
  validates_presence_of :content, :message => "内容不能为空"
  validates_presence_of :category_id, :message => "请选择类别"

  scope :previous, lambda { |p| {:conditions => ["id < ?", p.id], :limit => 1, :order => "id  DESC"} }
  scope :next, lambda { |p| {:conditions => ["id > ?", p.id], :limit => 1, :order => "id  ASC"}  }

  scope :with_category, lambda {|cat| includes(:category).where(["news_categories.internal_name = ? and locale = ?",cat,I18n.locale]).order("news.id desc")}
  scope :localee, lambda{["news.locale = ?",I18n.locale]}
  scope :category_id_eq, lambda {|cat_id| where(["news_category_id = ?",cat_id])}
  scope :order_by, lambda{|argus| column,direction = argus;  order("#{column} #{direction}")}
  scope :with_image,  includes(:image_references).where("file_references.id is not null")

  #search_methods :order_by




  def category_name
    category && category.name
  end

  def image_default(style)
    "/images/news_default_#{style}.jpg"
  end


  
end
