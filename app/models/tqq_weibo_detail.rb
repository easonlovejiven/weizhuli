# -*- encoding : utf-8 -*-
class TqqWeiboDetail < ActiveRecord::Base
  attr_accessible :city_code, :count, :country_code, 
    :emotiontype, :emotionurl, :from, :fromurl, :geo, 
    :head, :image, :isvip, :latitude, :location, :longitude, 
    :mcount, :music_title, :music_url, :openid, :post_at, 
    :province_code, :self, :source, :status, :text, :video_realurl, 
    :video_title, :weibo_id, :weibo_type,
    :is_origin, :is_forward,  :is_image,  :is_video,  :is_music


  def url
    "http://t.qq.com/p/t/#{weibo_id}"
  end


  scope :origins, where("tqq_weibo_details.is_origin = 1")
  scope :images, where("tqq_weibo_details.is_image = 1")
  scope :videos, where("tqq_weibo_details.is_video = 1")
  scope :musics, where("tqq_weibo_details.is_music = 1")
  scope :forwards, where("tqq_weibo_details.is_forward = 1")
  

  attr_accessor :detail


  def self.human_type(type)
    ({
      1=>"原创发表",
      2=>"转载",
      3=>"私信",
      4=>"回复",
      5=>"空回",
      6=>"提及",
      7=>"评论"
    })[type]
  end


  def self.to_row_title
  end

  def to_row
    mweibo = MTqqWeiboContent.find self.weibo_id
    srouce = mweibo.from
    type = case 
      when self.is_image? && self.is_video?
        "image + video"
      when self.is_image?
        "image"
      when self.is_video?
        "video"
      when self.is_music?
        "music"
      else
        "text"
    end

    origin = self.is_forward ? "forward" : "origin"

    post_at = self.post_at.strftime("%Y-%m-%d %H:%M:%S")
    [mweibo.text,post_at, self.reposts_count, self.comments_count, self.url, srouce, type, origin]
  end


end
