# -*- encoding : utf-8 -*-
class WeiboDetail < ActiveRecord::Base

  scope :origins, where("weibo_details.origin = 1")
  scope :images, where("weibo_details.image = 1")
  scope :videos, where("weibo_details.video = 1")
  scope :musics, where("weibo_details.music = 1")
  scope :forwards, where("weibo_details.forward = 1")
  scope :time_between, ->(start_time,end_time){where("post_at between ? and ?", start_time,end_time)}
  scope :start_time, ->(start_time){where("post_at >= ?", start_time)}
  scope :end_time, ->(end_time){where("post_at < ?",end_time)}
  scope :keyword, ->(keyword){
    reg= Regexp.new(keyword)
    ids = MWeiboContent.where(text:reg).limit(1000).map(&:id)
    where(weibo_id:ids)
  }


  attr_accessor :detail


  def url
    str = WeiboMidUtil.mid_to_str weibo_id.to_s
    "http://weibo.com/#{uid}/#{str}"
  end


  def to_row
    mweibo = MWeiboContent.find self.weibo_id
    srouce = ActionView::Base.full_sanitizer.sanitize(mweibo.source)
    type = case 
      when self.image? && self.video?
        "image + video"
      when self.image?
        "image"
      when self.video?
        "video"
      when self.music?
        "music"
      when self.vote?
        "vote"
      else
        "text"
    end

    origin = self.forward ? "forward" : "origin"

    post_at = self.post_at.strftime("%Y-%m-%d %H:%M:%S")
    [mweibo.text,post_at, self.reposts_count, self.comments_count, self.url, srouce, type, origin]
  end


  # before use mysearch, you must set WeiboUserRelation::current_uid && WeiboUserRelation::current_user_id
  def self.mysearch(queries)
    scope = scoped
    queries.each{|key,val|
      next if val.blank?
      scope = scope.send(key,val)
    }
    scope
  end




end
