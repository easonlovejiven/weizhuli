# -*- encoding : utf-8 -*-
class WeiboUserRelation < ActiveRecord::Base


  # see http://stackoverflow.com/questions/10680845/owner-filtered-model-objects-on-rails-3
  class_attribute :current_uid
  class_attribute :current_user_id


  belongs_to  :by_user, :foreign_key=>"by_uid", :primary_key=>"uid", :class_name=>"WeiboAccount"
  belongs_to  :user, :foreign_key=>"uid", :primary_key=>"uid", :class_name=>"WeiboAccount"

  scope :between, ->(uid1,uid2){where("(uid = ? and by_uid = ?) or (uid = ? and by_uid = ?)",uid1,uid2,uid2,uid1)}
  scope :is_friends, ->(is){
    #TODO
  }
  scope :is_verified, ->(is){
    if is_true(is)
      includes(:by_user).where("weibo_accounts.verified_type between 0 and 10")
    elsif is_true(is) == false
      includes(:by_user).where("weibo_accounts.verified_type not between 0 and 10")
    end

  }
  scope :has_interactions, ->(is){
    #TODO
    if is_true(is)
    elsif is_true(is) == false
    end
  }
  scope :has_avatar, ->(is){
    if is_true(is)
      includes(:by_user).where("weibo_accounts.has_avatar = ?",1)
    elsif is_true(is) == false
      includes(:by_user).where("weibo_accounts.has_avatar = ?",0)
    end
  }
  scope :gender, ->(g){includes(:by_user).where("weibo_accounts.gender = ?",g)}
  scope :friends_range, ->(range){
    a,b = range.split("-").map(&:to_i)
    if b.nil?
      includes(:by_user).where("weibo_accounts.friends_count >= ?",a)
    else
      includes(:by_user).where("weibo_accounts.friends_count between ? and ?",a,b)
    end
  }

  scope :followers_range, ->(range){
    a,b = range.split("-").map(&:to_i)
    if b.nil?
      includes(:by_user).where("weibo_accounts.followers_count >= ?",a)
    else
      includes(:by_user).where("weibo_accounts.followers_count between ? and ?",a,b)
    end
  }
  scope :reg_time, ->(range){
    a,b = range.split("-").map(&:to_i)
    date_a = Date.today - a.day
    date_b = Date.today - b.to_i.day
    if b.nil?
      includes(:by_user).where("weibo_accounts.created_at <= ?",date_a)
    else
      includes(:by_user).where("weibo_accounts.created_at between ? and ?",date_b,date_a)
    end
  }
  scope :weibo_number, ->(range){
    a,b = range.split("-").map(&:to_i)
    if b.nil?
      includes(:by_user).where("weibo_accounts.statuses_count >= ?",a)
    else
      includes(:by_user).where("weibo_accounts.statuses_count between ? and ?",a,b)
    end
  }
  scope :province, ->(province_id){includes(:by_user).where("weibo_accounts.province = ?", province_id)}
  scope :city, ->(city_id){includes(:by_user).where("weibo_accounts.city = ?",city_id)}

  scope :join_remarks, ->{
    joins("left join weibo_user_remarks on weibo_user_remarks.uid = weibo_user_relations.by_uid and weibo_user_remarks.user_id = #{current_user_id}")
  }
  scope :has_email, ->(is){
    if is_true(is)
      join_remarks.where("weibo_user_remarks.email is not null")
    elsif is_true(is) == false
      join_remarks.where("weibo_user_remarks.email is null")
    end

  }
  scope :has_phone, ->(is){
    if is_true(is)
      join_remarks.where("weibo_user_remarks.phone is not null")
    elsif is_true(is) == false
      join_remarks.where("weibo_user_remarks.phone is null")
    end
  }
  scope :has_address, ->(is){
    if is_true(is)
      join_remarks.where("weibo_user_remarks.address is not null")
    elsif is_true(is) == false
      join_remarks.where("weibo_user_remarks.address is null")
    end
  }
  scope :has_company, ->(is){
    if is_true(is)
      join_remarks.where("weibo_user_remarks.company is not null")
    elsif is_true(is) == false
      join_remarks.where("weibo_user_remarks.company is null")
    end
  }
  scope :in_group, ->(group_id){#join_remarks.where("weibo_user_remarks.email is not null")
    #TODO
    join_remarks.where("weibo_user_remarks.group_id = ?",group_id)
  }


  # before use mysearch, you must set WeiboUserRelation::current_uid && WeiboUserRelation::current_user_id
  def self.mysearch(queries)
    scope = scoped
    (queries||[]).each{|key,val|
      next if val.blank?
      scope = scope.send(key,val)
    }
    scope
  end





  def self.is_true(val)
    return true if ['yes','1',1,true,'true'].include?(val.downcase)
    return false if ['no','0',0,false,'false'].include?(val.downcase)
    return nil
  end


end
