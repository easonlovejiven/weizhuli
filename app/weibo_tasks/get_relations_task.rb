# -*- encoding : utf-8 -*-
# archive user relations each hour
class GetRelationsTask < WeiboTaskBase

  #  this task supported interval
  SUPPORT_INTERVAL = [:hourly]
  ONLY_TOKEN_USER = false
  SUPPORT_MULTI_USERS = false

  def run
    waccount = WeiboAccount.find_by_uid(@target_uid.to_i)
    
    
    # for friends
    info("loading friend ids for user #{@target_id}")
    friend_ids = stable{api.friendships.friends_ids(:uid=>@target_uid, :count=>5000).ids}
    new_ids = []
    info("checking new friends")
    friend_ids.each_with_index{|id,index|
      old_rel = WeiboUserRelation.where(:by_uid=>@target_uid, :uid=>id).first
      if !old_rel
        new_ids.unshift id
      else
        # 启用将会每次更新最多 5000 follow time
        # old_rel.update_attributes(:follow_time=>Time.now-1.hour)
      end
    }
    info("saving new #{new_ids.size} friends for user #{@target_id}")
    
    # 第一次 抓取的时候, follow_time 置空, 以免统计不准确
    follow_time = WeiboUserRelation.where(:by_uid=>@target_uid).last ? Time.now-1.hour : nil



      batch_import{

        new_ids.each{|id|
        begin
          import_for_batch(WeiboUserRelation.new(:by_uid=>@target_uid, :uid=>id, :follow_time=>follow_time),:ignore => true)
        rescue Exception=>e
          puts e.message
        end
        }
      }
    
    
    per_page = 200
    paginate(:per_page=>per_page){|page|
      results = stable{api.friendships.friends(:uid=>@target_uid, :count=>per_page)}
      batch_import{
          results.users.each{|user|
            save_weibo_user user
          }
      }      
      new_ids.size
      
    }


    
    # for followers
    info("loading follow ids for user #{@target_id}")
    follower_ids = stable{api.friendships.followers_ids(:uid=>@target_uid, :count=>5000).ids}
    new_ids = []
    offset = 0

    info("checking new followers")
    follower_ids.each_with_index{|id,index|
      if !WeiboUserRelation.where(:uid=>@target_uid, :by_uid=>id).first
        new_ids.unshift id
        offset = index
      end
    }
    offset += 1
    info("saving new #{new_ids.size} followers, offset #{offset} for user #{@target_id}")
    # 第一次 抓取的时候, follow_time 置空, 以免统计不准确
    follow_time = WeiboUserRelation.where(:uid=>@target_uid).last ? Time.now-1.hour : nil
    batch_import{
      new_ids.each{|id|
        begin
          import_for_batch WeiboUserRelation.new(:uid=>@target_uid, :by_uid=>id, :follow_time=>follow_time),:ignore => true
        rescue Exception=>e
          puts e.message
        end
      }
    }
    
    m_f_fans = {'m'=>0,'f'=>0}

    per_page = 200
    paginate(:per_page=>per_page){|page|
      results = stable{api.friendships.followers(:uid=>@target_uid, :count=>per_page)}
        batch_import{
          results.users.each{|user|
            if new_ids.include? user.id
              m_f_fans[user['gender']] += 1
              save_weibo_user user
            end
          }
        }

      offset
      
    }
    
    waccount.update_attributes({'male_fans' => m_f_fans['m'], 'female_fans' => m_f_fans['f']})
    
  end


end
