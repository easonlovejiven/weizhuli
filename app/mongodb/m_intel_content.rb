# -*- encoding : utf-8 -*-
class MIntelContent
  include MongoMapper::Document

  key :uid, Integer
  key :screen_name, String
  key :mid, Integer
  key :text, String
  key :images, Array

  key :post_at, DateTime
  key :source, String

  key :is_image,  Boolean
  key :is_video,  Boolean

  key :forwards,  Integer
  key :comments,  Integer
  key :interactions,  Integer



  key :geo, String
  key :tag1, String
  key :tag2, String
  key :tag3, String
  key :tag4, String
  key :tag5, String
  key :tag6, String

  timestamps!





  DIMENSION_COLUMNS = {
    "Objective"=>"tag1",
    "Message"=>"tag2",
    "Target Audience"=>"tag3",
    "Formats"=>"tag4",
    "Resource"=>"tag5",
    "Topics"=>"tag6",
  }

  DIMENSIONS = [
    ["Objective",[
      "Awareness",
      "Education",
      "Loyalty",
    ]],
    ["Message",[
      "2in1/PC",
      "Wearable",
      "Real Sense",
      "Tablet/Phone",
      "Culture&History",
    ]],
    ["Target Audience",[
      "Savvy Adopter",
      "Trendy Mobile",
      "Mobile Achiever",
      "Industry Influencer",
    ]],

    ["Topics",[
      "Tech Innovation",
      "Fashion/Art",
      "Entertainment",
      "Better Life",
      "Sports",
    ]],

    ["Formats",[
      "Infographic/photo",
      "Gif/video/audio",
      "Quiz/survey",
      "Interactive/Game",
    ]],



  ]


  def url
    "http://weibo.com/#{uid}/#{WeiboMidUtil.mid_to_str(mid)}"
  end

  def self.sync_from_weibo_list(update=false, uids=nil,start_time=nil,end_time=nil)
    uids ||= [2637370927,1340241374,2295615873,2637370247]
    start_time ||= Date.yesterday
    end_time ||= Date.today

    weibos = WeiboDetail.origins.where(uid:uids).where("post_at > ? and post_at < ?",start_time,end_time).all

    weibos.each{|weibo|
      content = MIntelContent.find_by_mid(weibo.weibo_id)
      next if !update && content
      content = MIntelContent.new(uid:weibo.uid,mid:weibo.weibo_id) if content.nil?

      mweibo = MWeiboContent.find(weibo.weibo_id)
      post = Post.find_by_weibo_id(weibo.weibo_id.to_s)
      content.text = mweibo.text
      content.post_at = weibo.post_at
      content.is_image = weibo.image?
      content.is_video = weibo.video?
      content.forwards = weibo.reposts_count
      content.comments = weibo.comments_count
      content.interactions = content.forwards+content.comments

      if post
        content.tag1 = post['tag1']
        content.tag2 = post['tag2']
        content.tag3 = post['tag3']
        content.tag4 = post['tag4']
        content.tag5 = post['tag5']
        content.tag6 = post['tag6']
      end

      content.images = mweibo.pic_urls.map{|pic| pic['thumbnail_pic']}
      content.source = ActionView::Base.full_sanitizer.sanitize mweibo.source

      content.save!
    }

  end
end

