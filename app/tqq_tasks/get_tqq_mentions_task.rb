# -*- encoding : utf-8 -*-
class GetTqqMentionsTask < TqqTaskBase

  #  this task supported interval
  SUPPORT_INTERVAL = [:hourly]
  ONLY_TOKEN_USER = true
  SUPPORT_MULTI_USERS = false

  def run
      
      # load mentions
      mention_openids = []
      while true
        last_mention = TqqMention.where(:openid=>@openid).order("mention_at desc").first
        pagetime = last_mention ? last_mention.mention_at.to_i : 1
        # get mentions from server
        mentions_results = stable{oapi.statuses.mentions_timeline({type:1,pagetime:pagetime+1,reqnum:70,pageflag:2})}
        mentions = mentions_results.data.try(:info) || []
        debug("saving new mentions #{mentions ? mentions.size : 0}, total #{mentions_results.data.try(:totalnum)}")
        # save mentions to mongodb and mysql
        (mentions || []).reverse.each{|mention|
          begin
            MTqqMention.create(mention)
          rescue
          end
          if !TqqMention.where(:openid=>@openid, :mention_id=>mention['id']).first
            TqqMention.create(:openid=>@openid, :mention_id=>mention['id'], :mention_openid=>mention["openid"],
                                :mention_at=>Time.at(mention['timestamp']))
          end
          mention_openids << mention["openid"]
        }
        
       # mentions_results.total_number
       break if mentions_results.data.nil? || mentions_results.data.hasnext == 1
        
      end
      

      # load mention users
      mention_openids.each{|openid|
        load_weibo_user(openid:openid)
      }


  end
  


end
