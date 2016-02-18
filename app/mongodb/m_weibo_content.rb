# -*- encoding : utf-8 -*-
class MWeiboContent
  include MongoMapper::Document

  key :thumbnail_pic,   String


  belongs_to :retweeted_status, :class_name=>"MRetweetContent"


  def url
    str = WeiboMidUtil.mid_to_str mid
    "http://weibo.com/#{uid}/#{str}"
  end
end

