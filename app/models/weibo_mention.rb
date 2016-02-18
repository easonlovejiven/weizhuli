# -*- encoding : utf-8 -*-
class WeiboMention < ActiveRecord::Base
  scope :time_between, ->(start_time,end_time){where("mention_at between ? and ?", start_time,end_time)}
  scope :start_time, ->(start_time){where("mention_at >= ?", start_time)}
  scope :end_time, ->(end_time){where("mention_at < ?",end_time)}
  scope :over_forward, ->(is){
    if is_true(is)
      where("weibo_mentions.forward_weibo_id is not null")
    else
      where("weibo_mentions.forward_weibo_id is null")
    end
  }

  belongs_to  :mention_user, :foreign_key=>"mention_uid", :primary_key=>"uid", :class_name=>"WeiboAccount"
  belongs_to  :user, :foreign_key=>"uid", :primary_key=>"uid", :class_name=>"WeiboAccount"

  scope :is_verified, ->(is){
    if is_true(is)
      includes(:mention_user).where("weibo_accounts.verified_type between 0 and 10")
    elsif is_true(is) == false
      includes(:mention_user).where("weibo_accounts.verified_type not between 0 and 10")
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
      includes(:mention_user).where("weibo_accounts.has_avatar = ?",1)
    elsif is_true(is) == false
      includes(:mention_user).where("weibo_accounts.has_avatar = ?",0)
    end
  }
  scope :gender, ->(g){includes(:mention_user).where("weibo_accounts.gender = ?",g)}
  scope :friends_range, ->(range){
    a,b = range.split("-").map(&:to_i)
    if b.nil?
      includes(:mention_user).where("weibo_accounts.friends_count >= ?",a)
    else
      includes(:mention_user).where("weibo_accounts.friends_count between ? and ?",a,b)
    end
  }

  scope :followers_range, ->(range){
    a,b = range.split("-").map(&:to_i)
    if b.nil?
      includes(:mention_user).where("weibo_accounts.followers_count >= ?",a)
    else
      includes(:mention_user).where("weibo_accounts.followers_count between ? and ?",a,b)
    end
  }
  scope :reg_time, ->(range){
    a,b = range.split("-").map(&:to_i)
    date_a = Date.today - a.day
    date_b = Date.today - b.to_i.day
    if b.nil?
      includes(:mention_user).where("weibo_accounts.created_at <= ?",date_a)
    else
      includes(:mention_user).where("weibo_accounts.created_at between ? and ?",date_b,date_a)
    end
  }
  scope :weibo_number, ->(range){
    a,b = range.split("-").map(&:to_i)
    if b.nil?
      includes(:mention_user).where("weibo_accounts.statuses_count >= ?",a)
    else
      includes(:mention_user).where("weibo_accounts.statuses_count between ? and ?",a,b)
    end
  }
  scope :province, ->(province_id){includes(:mention_user).where("weibo_accounts.province = ?", province_id)}
  scope :city, ->(city_id){includes(:mention_user).where("weibo_accounts.city = ?",city_id)}

  scope :is_beijing,  ->(value){
    if value=="北京"
      includes(:mention_user).where("weibo_accounts.province = ?", 11)
    else
      includes(:mention_user).where("weibo_accounts.province != ?", 11)
    end
  }


  def url
    "http://weibo.com/#{mention_uid}/#{WeiboMidUtil.mid_to_str(mention_id.to_s)}"
  end

  # before use mysearch, you must set WeiboUserRelation::current_uid && WeiboUserRelation::current_user_id
  def self.mysearch(queries)
    scope = scoped
    queries.each{|key,val|
      next if val.to_s.blank? 
      scope = scope.send(key,val)
    }
    scope
  end




  def self.is_true(val)
    return true if ['yes','1',1,true,'true'].include?(val.is_a?(String) ? val.downcase : val)
    return false if ['no','0',0,false,'false'].include?(val.is_a?(String) ? val.downcase : val)
    return nil
  end



end
