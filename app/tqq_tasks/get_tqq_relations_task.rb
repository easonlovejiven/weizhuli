# -*- encoding : utf-8 -*-
# archive user relations each hour
class GetTqqRelationsTask < TqqTaskBase

  #  this task supported interval
  SUPPORT_INTERVAL = [:hourly]
  ONLY_TOKEN_USER = false
  SUPPORT_MULTI_USERS = false

  def run
    
    debug("START <GetTqqRelationsTask> for openid #{@openid}")



    # for friends

    per_page = 30
    page = 0
    new_openids = []
    mode = TqqUserRelation.where(by_openid:@openid).first.nil? ? 1 : 0
    debug("load #{mode == 1 ? '10K' : '1K'} friends from api")
    while
      startindex = per_page * page
      res = stable{api.friends.user_idollist(fopenid:@openid,reqnum:per_page,mode:mode,startindex:startindex)}
      rels = res.data.try(:info) || []
      rels.each{|rel|
        follow_time = (mode == 0 ? Time.now-1.hour : nil)
        r = TqqUserRelation.where(by_openid:@openid,openid:rel.openid).first
        if r.nil?
          TqqUserRelation.create(by_openid:@openid,openid:rel.openid,follow_time:follow_time)
          new_openids << rel.openid
        end
      }
      debug("get #{rels.size} friends in page #{page} ")
      break if res.data.nil? || res.data.hasnext == 1
      page += 1
    end

    debug("get #{new_openids.size} new friends")




    # for followers
    per_page = 30
    page = 0
    new_openids = []
    mode = TqqUserRelation.where(openid:@openid).first.nil? ? 1 : 0
    debug("load #{mode == 1 ? '10K' : '1K'} followers from api")
    while
      startindex = per_page * page
      res = stable{api.friends.user_fanslist(fopenid:@openid,reqnum:per_page,mode:mode,startindex:startindex)}
      rels = res.data.try(:info) || []
      rels.each{|rel|
        follow_time = (mode == 0 ? Time.now-1.hour : nil)
        r = TqqUserRelation.where(openid:@openid,by_openid:rel.openid).first
        if r.nil?
          TqqUserRelation.create(openid:@openid,by_openid:rel.openid,follow_time:follow_time)
          new_openids << rel.openid
        end
      }
      debug("get #{rels.size} followers in page #{page} ")
      break if res.data.nil? || res.data.hasnext == 1
      page += 1
    end

    debug("get #{new_openids.size} new followers")

    new_openids.each{|openid|
      load_weibo_user openid:openid
    }







  end


end
