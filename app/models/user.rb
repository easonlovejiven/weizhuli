# -*- encoding : utf-8 -*-
class User < ActiveRecord::Base
  include Customize::Verificatable
  include RailsSettings::Extend

  STATUS_FORBIDDEN = 0
  STATUS_ACTIVED = 1
  STATUS_VERIFIED = 2
  IMAGE_FILE_REF_TYPE_AVATAR = "avatar"

  AVAILABLE_SEARCH_KEYS = [:login_contains, :created_at_lt, :created_at_gt, :from_events, :business_card_country_id_eq, :business_card_province_id_eq, :business_card_city_id_eq]



  attr_accessor  :affilicatoin_id, :valid_sms_code, :sms_code

  # friendly_id for users, url will be /user/15283115535(timestamp)
  extend FriendlyId
  friendly_id :generate_friendly_id, :use=>:slugged

  # for thinking_sphinx
=begin
  define_index do

    indexes "''", :as => :empty
    indexes current_login_ip
    indexes login
    indexes email
    indexes status


    has created_at, updated_at
  end
=end
  # alias thinking_sphinx::search to ts_search
  class << self
    alias ts_search search
  end

  include Customize::Searchable



  validate :validate_sms_code



  has_many :authentications, :dependent=>:destroy
  has_and_belongs_to_many  :roles
  accepts_nested_attributes_for :roles, :allow_destroy => false


  has_one   :avatar_reference, :class_name=>"FileReference", :as=>:reference,
            :dependent=>:destroy
  accepts_nested_attributes_for :avatar_reference, :allow_destroy => true, :reject_if=>proc{|img_attrs|img_attrs["upload_id"].blank?}
  has_one   :avatar,  :through=>:avatar_reference, :source => :upload

  has_many  :uploaded_file_references, :class_name=>"FileReference"
  has_many  :uploaded_files, :through=>:uploaded_file_references, :source => :upload
  
  has_many  :post_categories
  has_many  :weibo_user_groups
  
  has_one   :profile, :class_name=>"UserProfile", :dependent=>:destroy
  accepts_nested_attributes_for :profile

  
  


#  after_create  "deliver_activation_instructions!"


  scope :id_eq, lambda{|user_id| where(["users.id = ?",user_id])}
  scope :has_avatar, lambda{includes(:avatar_reference).where("file_references.id is not null")}
  scope :actived, where(:status=>1)
  scope :actived_or_verified, where("status=1 or status=2")
  scope :without_me , lambda{| user | where("users.id <>?", user.id) }

  scope :role_eq ,lambda{|role| includes(:roles).where(["roles.name = ? ",role])}
  scope :role_noteq ,lambda{|role| includes(:roles).where(["roles.name != ? ",role])}



  #use ransack instead of meta_search
  #search_methods  :from_events,:business_card_country_id_eq, :business_card_province_id_eq, :business_card_city_id_eq

  # this is dangers
  # default_scope where("users.id != 1") # when you want skip this scope, use User.unscoped , see http://apidock.com/rails/ActiveRecord/Base/unscoped/class



  acts_as_authentic do |c|


=begin
#    c.login_field :email
#    c.validates_length_of :login, :within => 3..8,:message => "用户名为3到8个字符"
    c.validates_presence_of :password_confirmation,:message => lambda{_("重复密码不能为空")},:on => :create
    c.validates_presence_of :email,:message => lambda{_("email不能为空")}
    c.validates_format_of :email, :with => /\w+([-+.]\w+)*@\w+([-.]\w+)*\.\w+([-.]\w+)*/, :on => :create, :message => lambda{_("email格式不正确")}
=end
    c.login_field :login
    c.validate_email_field false
    c.validates_presence_of :email, :message => "不能为空"
    c.validates_presence_of :login, :message => "名不能为空"
    c.validates_presence_of :password, :message => "密码不能为空",:on => :create
    c.validates_uniqueness_of_login_field_options :message=>"用户已存在, 请直接登录"
    c.validates_confirmation_of_password_field_options :message => "重复密码不匹配", :on => :create
  end




  def displayable_name
    self.nickname || self.login
  end


  def role_symbols
    (roles || []).map {|r| r.name.to_sym}
  end

  def has_role?(role)
    role_symbols.include?(role.to_sym)
  end

  def evaluated?(target)
    Evaluate.evaluated?(self, target)
  end

  def active!
    update_attributes(:status=>STATUS_ACTIVED)
  end

  def active?
    status > 0
  end

  def email_verify!
    update_attributes(:status=>STATUS_VERIFIED)
  end

  def email_verify?
    status == STATUS_VERIFIED
  end


  def deliver_password_reset_instructions!
    reset_perishable_token!
    Notifier.delay.password_reset_instructions(self, I18n.locale)
  end

  def deliver_activation_instructions!
  	if self.status == 2
  	  self.default_user_token = set_user_token
  	  self.save
		  #reset_perishable_token!
		  Notifier.delay.activation_instructions(self, I18n.locale)
		end
  end














  def avatar_url(style=:thumb)
    if avatar
      return avatar.attachment.url(style)
  else
      return avatar_default(style)
    end
  end


  def avatar_default(style)
    return (business_card && business_card.gender == false) ? "/images/avatar_default_0.jpg" : "/images/avatar_default_1.jpg"
  end


  # this for authlogic , override login method
  def self.find_by_login_method(login)
    unscoped{
      return find_by_login(login)
    }
  end





  # OVERRIDE as_json method
  def as_json(options={})
    {:user=>
      {
        :id=>self.id,
        :name=>self.displayable_name,
      }
    }.merge(options[:hash])
  end




  def self.human_attribute_name(attr, opts={})

    attributes = {
      :"login" => _("用户名"),
      :"email" => '邮箱',
      :"password" => _("密码"),
      :"password_confirmation" => _("确认密码"),
      :'profile.mobile' => _("手机号"),
      :'profile.realname' => _("姓名"),
      :'sms_code' => "手机验证码",

    }
    attributes[attr] || super

  end



  # for friendly_id
  def generate_friendly_id
    s = []
    3.times{s << rand(10)}
    (self.created_at||Time.now).to_i.to_s+s*""
  end

  def should_generate_new_friendly_id?
    new_record? || self.slug.nil?
  end


  def set_user_token
      user_token = (0...12).map{ ('a'..'z').to_a[rand(26)] }.join
  end
  

  # use for file_reference
  def get_user_id
    self.id
  end


  def get_property
    if property.nil?
      self.build_property
      self.save!
    end
    property
  end


  #
  def validate_sms_code
    return if !valid_sms_code
    sc = SmsCode.find_by_code_and_mobile(@sms_code,self.profile.mobile)
    if sc && sc.expires_at >= Time.now.to_i
      sc.destroy
    else
      self.errors[:sms_code] << "不正确"
    end
  end

end

