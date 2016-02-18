# -*- encoding : utf-8 -*-
class MMention
  include MongoMapper::Document

  belongs_to  :user, :class_name=>"MUser"



  def self.fix_mention_weibo_id
    count = MMention.where(to_user_id:1288915263,:retweeted_status.ne=>nil).count
    page = 1
    while page*1000 <= count
      mms = MMention.where(to_user_id:1288915263,:retweeted_status.ne=>nil).page(page).per_page(1000).all
      mms.each{|mm|

        wm = WeiboMention.find_by_mention_id(mm.id)
        wm.forward_weibo_id = mm.retweeted_status['id']
        wm.save
      }
      page += 1
    end
  end
end

