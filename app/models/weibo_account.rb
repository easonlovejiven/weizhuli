# -*- encoding : utf-8 -*-
class WeiboAccount < ActiveRecord::Base

  has_many  :user_attributes, :foreign_key=>"uid", :primary_key=>"uid", :class_name=>"WeiboUserAttribute"
  has_one   :user_quality, :foreign_key=>"uid", :primary_key=>"uid", :class_name=>"WeiboUserEvaluate"

  scope :uid_in, lambda{|uids| where(["weibo_accounts.uid in (?)",uids])}

  before_save   :set_values
  
  # attrs 从 weibo api 返回的用户数据
  # keys 会和表的 columns 比较, 表 里边有的属性会保存,没有不保存
  def self.create_or_update(attrs)
    # find by id first
    account = self.find_by_uid(attrs['id'])
    
    # if account exist, update attributes
    # else create new one
    account = self.new if !account
    
    attrs.each{|key,value|
      key = 'uid' if key=='id'
      value = {'m'=>1,'f'=>0,'n'=>-1}[value] if key == 'gender'
      account[key] = value if account.attributes.keys.include? key
    }
    
    # save record
    account.save!
  end


  def self.to_row_title(mode = :default)
    case mode
    when :simple
      %w{UID 昵称 位置 性别 粉丝 关注 微博 注册时间 认证信息}
    when :default
      %w{UID 昵称 位置 性别 粉丝 关注 微博 注册时间 认证信息 认证原因}
    when :full
      %w{UID 昵称 位置 性别 粉丝 关注 微博 注册时间 认证信息 认证原因 备注 标签}
    when :quality
      %w{UID 昵称 位置 性别 粉丝 关注 微博 注册时间 认证信息 认证原因 备注 标签 被转发率 平均被转发 被评论率 平均被评论 活跃度 原创占比
}
    end
  end




  def location(full=false)
    full ? self['location'] : self['location'].to_s.split(" ").first
  end



  def to_row(mode = :default)


    created_at = (self.created_at || self.updated_at).strftime("%Y-%m-%d %H:%M")
    ar = [self.uid, self.screen_name, self.location, self.human_gender, self.followers_count, self.friends_count,
        self.statuses_count, created_at, self.human_verified_type.uniq*","
    ]

    levels = {
      :simple => 0,
      :default=> 1,
      :full=>2,
      :quality=>3
    }

    level = levels[mode] || 1

    a = nil


    if level >= 0
    end

    if level >= 1
      a ||= MUser.find(self.uid)
      ar << a.try(:verified_reason)
    end

    if level >= 2
      a ||= MUser.find(self.uid)
      ar << a.try(:description)  
      ar << (a.try(:tags) || []) * ","
    end

    if level >=3
      ar << forward_rate
      ar << forward_average
      ar << comment_rate
      ar << comment_average

      ar << activate_rate
      ar << origin_rate
    end

    ar
  end





  def self.to_row(user)

   [
      user.id,
      user.screen_name,
      user.location,
      user.gender,
      user.followers_count,
      user.friends_count,
      user.statuses_count,
      Time.parse(user.created_at).to_s,
      WeiboAccount.human_verified_type(user.verified_type),
      user.verified_reason,
      user.description
    ]


  end




  def forward_rate
    user_quality && user_quality.forward_rate ? (user_quality.forward_rate / 100.0).round(2) : nil
  end
  def origin_rate
    user_quality && user_quality.origin_rate ? user_quality.origin_rate : nil
  end

  def forward_average
    user_quality && user_quality.forward_average ? (user_quality.forward_average / 100.0).round(2) : nil
  end

  def comment_rate
    user_quality && user_quality.comment_rate ? (user_quality.comment_rate / 100.0).round(2) : nil
  end

  def comment_average
    user_quality && user_quality.comment_average ? (user_quality.comment_average / 100.0).round(2) : nil
  end

  def human_verified_type
    WeiboAccount::human_verified_type(verified_type)
  end

  def human_gender
    WeiboAccount::human_gender(gender)
  end

  def activate_rate
    forward_average && comment_average ? forward_average + comment_average : nil
  end


  # 微博注册时长
  def weibo_age
    Date.today - self.created_at
  end

  def self.human_verified_type(verified_type)
    verified_types = {
      -1 => "未认证",
      0 =>"名人",
      1 =>"政府",
      2 =>"企业",
      3 =>"媒体",
      4 =>"校园",
      5 =>"网站",
      6 =>"应用",
      7 =>"团体（机构）",
      10 => "微博女郎",
      200 =>"未审核达人",
      220 =>"达人",
    }

    verified_type_goups = {
      -1 => "草根",
      0 =>"橙V",
      1 =>"蓝V",
      2 =>"蓝V",
      3 =>"蓝V",
      4 =>"蓝V",
      5 =>"蓝V",
      6 =>"蓝V",
      7 =>"蓝V",
      200 =>"达人",
      220 =>"达人",
    }

    type = verified_types[verified_type]
    group = verified_type_goups[verified_type]

    [type,group]

  end


  def self.human_gender(gender)
    genders = {1=>"男",0=>"女"}
    genders[gender]
  end
  def self.fm_gender(gender)
    genders = {'m'=>"男",'f'=>"女"}
    genders[gender]
  end
  def update_evaluates
    task = GetUserTagsTask.new
    rnd_code = 0-rand(100000000)


    #a.update_attributes(forward_rate:rnd_code)
    res = task.stable{task.api.statuses.user_timeline(uid:self.uid,count:100)}
    statuses = res.statuses

    forwards = 0
    comments = 0
    forwarded_weibos = 0
    commented_weibos = 0

    origins = 0
    posts_in_week = 0
    last_day_for_posts =  Date.today
    last_day_for_posts_in_week = Date.today

    statuses.each{|status|
      forwards += status.reposts_count
      comments += status.comments_count

      forwarded_weibos += 1 if status.reposts_count > 0
      commented_weibos += 1 if status.comments_count > 0

      origins += 1 if status.retweeted_status.blank?
      if status.created_at.to_datetime >= Date.today - 1.week + 1.day
        posts_in_week += 1 
        last_day_for_posts_in_week = status.created_at.to_date
      end
      last_day_for_posts = status.created_at.to_date

    }

    status_size = statuses.size.to_f

    if status_size > 0
      forward_rate = (forwarded_weibos.to_f / status_size * 100).to_i
      comment_rate = (commented_weibos.to_f / status_size * 100).to_i

      forward_average = (forwards.to_f /  status_size * 100).to_i
      comment_average = (comments.to_f /  status_size * 100).to_i

      origin_rate  =  (origins.to_f /  status_size * 100).to_i

      
    else
      forward_rate = 0
      comment_rate = 0

      forward_average = 0
      comment_average = 0

      origin_rate = 0
    end
    days = (Date.today - last_day_for_posts).to_f

    day_posts = days == 0 ? 0 : statuses.size / days 
    days = (Date.today - last_day_for_posts_in_week).to_f
    day_posts_in_week = days == 0 ? 0 : posts_in_week / days


    eva = WeiboUserEvaluate.where(uid:self.uid).first
    eva = WeiboUserEvaluate.new(uid:self.uid) if eva.nil?
    eva.forward_rate = forward_rate
    eva.forward_average = forward_average
    eva.comment_rate = comment_rate
    eva.comment_average = comment_average

    eva.day_posts = day_posts
    eva.day_posts_in_week = day_posts_in_week

    eva.origin_rate = origin_rate

    eva.save!
    eva
  end



  def update_info
    task = GetUserTagsTask.new
    begin
      res = task.stable{task.api.users.show(uid:uid)}
      task.save_weibo_user(res)
    rescue Exception=>e
      if e.message =~ /exist/
        raise e
      end
    end

  end



  def set_values
    self.has_avatar = self.profile_image_url =~ /\/0\/1/
  end

  def self.find_by_uid(uid)
    cache_key = uid_cache_key(uid)
    aid = $REDIS ? $REDIS.get(cache_key) : nil
    if aid
      where(id:aid).first
    else
      a = where(uid:uid).first
      $REDIS && $REDIS.set(cache_key,a.id) if a
      a
    end
  end



  def self.uid_cache_key(uid)
    "c.wa.#{uid}"
  end

end
