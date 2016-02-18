# -*- encoding : utf-8 -*-
class TqqAccount < ActiveRecord::Base
  attr_accessible :birth_day, :birth_month, :birth_year, :city_code, 
  :country_code, :email, :exp, :fansnum, :favnum, :head, :homecity_code, :homecountry_code, 
  :homepage, :homeprovince_code, :hometown_code, :idolnum, 
  :industry_code, :introduction, :isent, :ismyblack, :ismyfans, :ismyidol, :isrealname, :isvip, 
  :level, :location, :mutual_fans_num, :name, :nick, :openid, :province_code, 
  :regtime, :send_private_flag, :sex, :tweetnum, :verifyinfo

  has_one   :user_quality, :foreign_key=>"openid", :primary_key=>"openid", :class_name=>"TqqUserEvaluate"

  scope :openid_in, lambda{|openids| where(["tqq_accounts.openid in (?)",openids])}



  def self.to_row_titles(mode=:default)
    case mode
    when :default
      %w{openid name nick 微博 收听  听众 location  创建时间   性别   经验  等级   是否实名认证  vip  认证类型 标签}
    when :full
      %w{openid name nick 微博 收听  听众 location  创建时间   性别   经验  等级   是否实名认证  vip  认证类型 标签 活跃度}
    end


  end

  def to_row(mode=:default)

    mu = MTqqUser.find openid
    vinfo = mu.try(:verifyinfo)

    sexes = {
      1 => "男",
      2 => "女",
      0 => "未知",
    }


    _sex = sexes[sex]
    _isrealname = {true=>"是", false=>"否"}[isrealname]
    _isvip = {false=>"否",true=>"是"}[isvip]

    _regtime = regtime.strftime("%Y-%m-%d %H:%M:%S")
    tags = []
   if  mu && !mu.tag.nil?
     mu.tag.each do |line| 
      tags << line["name"].to_s
     end
    end

    row = [openid, name, nick, tweetnum, idolnum, fansnum, human_location*',', _regtime, _sex, exp, level, _isrealname, _isvip, vinfo,tags*","]


    levels = {
      :simple => 0,
      :default=> 1,
      :full=>2,
      :quality=>3
    }

    row_level = levels[mode] || 1

    if row_level >=2
      row << ((forward_average && comment_average) ?  forward_average + comment_average : nil)
    end



    row
  end



  def forward_rate
    user_quality && user_quality.forward_rate ? (user_quality.forward_rate / 100.0).round(2) : nil
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

  def human_gender
    TqqAccount::human_gender(gender)
  end

  def activate_rate
    forward_average && comment_average ? forward_average + comment_average : nil
  end


  def self.human_gender(gender)
    genders = {
      1 => "男",
      2 => "女",
      0 => "未知",
    }
    genders[gender]
  end


  # return [国家, 省份, 城市]
  def human_location
    @@doc ||= REXML::Document.new(File.new('lib/tqq_locations.xml'))

    country_name, province_name, city_name = nil

    country_node = REXML::XPath.first @@doc,"*/CountryRegion[@Code='#{country_code}']"
    if country_node
      country_name = country_node.attribute("Name").value
      province_node= REXML::XPath.first country_node,"State[@Code='#{province_code}']"

      if province_node
        province_name = province_node.attribute("Name").value
        city_node = REXML::XPath.first province_node,"City[@Code='#{city_code}']"

        if city_node
          city_name = city_node.attribute("Name").value
        end
      end


    end

    [country_name, province_name, city_name]

  end

  def update_evaluates
    task = GetTqqBasicTask.new
    rnd_code = 0-rand(100000000)


    #a.update_attributes(forward_rate:rnd_code)
    res = task.stable{task.api.statuses.user_timeline(reqnum:70,fopenid:openid)}

    statuses = res.data.try(:info) || []

    forwards = 0
    comments = 0
    forwarded_weibos = 0
    commented_weibos = 0

    origins = 0
    posts_in_week = 0
    last_day_for_posts =  Date.today
    last_day_for_posts_in_week = Date.today
    statuses.each{|status|
      forwards += status['count']
      comments += status.mcount

      forwarded_weibos += 1 if status['count'] > 0
      commented_weibos += 1 if status.mcount > 0

      origins += 1 if status['type'] == 1
      if Time.at(status.timestamp) >= Date.today - 1.week + 1.day
        posts_in_week += 1 
        last_day_for_posts_in_week = Time.at(status.timestamp).to_date
      end
      last_day_for_posts = Time.at(status.timestamp).to_date

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
    days = ((Date.today - last_day_for_posts).to_f == 0) ? 1 : (Date.today - last_day_for_posts)

    day_posts = days == 0 ? 0 : statuses.size / days 
    days = (Date.today - last_day_for_posts_in_week).to_f
    day_posts_in_week = days == 0 ? 0 : posts_in_week / days


    eva = TqqUserEvaluate.where(openid:self.openid).first
    eva = TqqUserEvaluate.new(openid:self.openid) if eva.nil?
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



end
