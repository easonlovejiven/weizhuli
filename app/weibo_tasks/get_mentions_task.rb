# -*- encoding : utf-8 -*-
class GetMentionsTask < WeiboTaskBase

  #  this task supported interval
  SUPPORT_INTERVAL = [:hourly]
  ONLY_TOKEN_USER = true
  SUPPORT_MULTI_USERS = false

  def run
    @target_uids.each{|target_uid|
      monit_account = MonitWeiboAccount.find_by_uid(target_uid)
      monit_account.fix_loaded_mentions_number
      last_mention = WeiboMention.where(:uid=>target_uid).order("mention_id desc").first
      last_id = last_mention ? last_mention.mention_id : nil
      mention_results = stable{oapi.statuses.mentions({:count=>1, :page=>1}.merge( last_id ? {:since_id=>last_id} : {}))}

      old_mentions_count = monit_account.loaded_mentions
      new_counts = mention_results.total_number.to_i - old_mentions_count
      debug("new mentions : #{new_counts} ")

      
      per_page = 200
      
      opts = {:count=>per_page}
      if last_id
        opts[:since_id]=last_id 
        debug("get last mention #{last_id}")
      end
      
      paginate(:per_page=>per_page, :total=>new_counts, :reverse=>true){|page|
      
        opts[:page] = page
        # get mentions from server
        mentions_results = stable{oapi.statuses.mentions(opts)}

        mentions = mentions_results['statuses']
        debug("saving new mentions #{mentions.size}, page #{page},  total #{mentions_results.total_number}")
        # save mentions to mongodb and mysql
        mentions.reverse.each{|mention|
          if is_forward(mention, target_uid)
            next
          end
          user = save_weibo_user mention['user']
          mention['user_id'] = user.uid
          mention['to_user_id'] = target_uid
          MMention.create(mention) if MMention.find(mention["id"]).nil?
          if !WeiboMention.where(:uid=>target_uid, :mention_id=>mention['id']).first
            WeiboMention.create(:uid=>target_uid, :mention_id=>mention['id'], :mention_uid=>user.uid,
                                :mention_at=>mention['created_at'])
          end
        }
        
        monit_account.loaded_mentions += per_page
        monit_account.save!
       # mentions_results.total_number
        
      }
      
    }
  end
  

  def is_forward(status, target_uid)
    return true if status.retweeted_status && status.retweeted_status.user && status.retweeted_status.user.id == target_uid
    return false
  end
  



  # 当 monit_weibo_accounts.loaded_mentions 位置错误时, 使用此方法修复 
  def fix_last_mention_position(monit_account)

    last_mention = WeiboMention.where(uid:monit_account.uid).order("mention_id desc").first
    if last_mention.nil?
      monit_account.update_attribute(:loaded_mentions, 0)
      return
    end
    res = oapi.statuses.mentions({:count=>1, :page=>1}.merge({:since_id=>last_mention.mention_id}))
    total_number = res.total_number
    r1 = 1
    r2 = 8000# res.total_number
    last_available_page = r1

    while true

      print "id range #{r2} <--> #{r1}"
      page = r2 - (r2-r1)/2
      

      res = stable{oapi.statuses.mentions({:count=>1, :page=>page}.merge({:since_id=>last_mention.mention_id}))}

      print "\t total: #{res.total_number}\t"

      if res.total_number == 0
        puts " ---> #{page}"
        r2 = page
      else
        puts " <--- #{page}"
        r1 = page
        last_available_page = r1
      end

      if r2-1 == r1
        break 
      end
    end
    real_position = total_number - last_available_page
    monit_account.update_attribute(:loaded_mentions, real_position)
    puts "Find position #{real_position}"
  end
end
