# -*- encoding : utf-8 -*-
# archive user relations each hour

require 'csv'

class IntelAllFansStatusTask < WeiboTaskBase

  SUPPORT_INTERVAL = [:temp]
  ONLY_TOKEN_USER = false
  SUPPORT_MULTI_USERS = false
  

  # 统计全量粉丝当中的真实粉丝包括粉丝的互动数量，以及标签
  def run
  
    
    last_line = CSV.parse(`tail intel_fans_list.csv -n1`)
    last_id = last_line.blank? ? 0 : last_line.first.first
    

    # 取得所有 fans uid
    all_users = WeiboUserRelation.where(["uid = 2637370927 and id > ?", last_id]).count
    per_page = 1000
    
    done = 0
    

    File.open('intel_fans_list.csv', 'a'){ |outfile|
    
      CSV::Writer.generate(outfile) do |csv|
      
        paginate(:per_page=>per_page, :total=>all_users) do |page|
        
          relations = WeiboUserRelation.where(["uid = 2637370927 and id > ?", last_id]).order("id asc").paginate(:per_page=>per_page, :page=>page)
          
          # 循环每一个 relations
          relations.each{|rel|
            uid = rel.by_uid  # 粉丝 UID
            
            print "checking uid : #{uid} ......"
            
            # 根据 UID 查询数据
            
            user = WeiboAccount.find_by_uid(uid)
            muser = MUser.find(uid)
            if user.nil? || muser.nil?
              begin
                muser = stable{api.users.show(:uid=>uid)  }
              rescue Exception=>e
                done += 1
                next if e.message =~ /User does not exists/
              end
              save_weibo_user muser
              user = WeiboAccount.find_by_uid(uid)
            end
            
            fake = check_user_is_fake(uid)
            tags = get_users_tag([uid]).first
            
            tags = tags.tags.map{|tag| tag.delete(:weight); tag.to_a.flatten.last}*"," if tags
            
            csv << [
              rel.id, 
              fake,
              user.screen_name,
              user.uid,
              user.verified_type,
              user.gender,
              user.friends_count,
              user.followers_count,
              user.statuses_count,
              user.created_at,
              Time.now,
              tags
            ]
            
            
            done += 1
            puts "finished [id:#{rel.id}] #{done}, total #{all_users} percent #{(done.to_f/ all_users.to_f).round(4)}, current uid #{uid}"
          }
        
        end
      
      
      end
    
    }
    # loop and check if already have user info and user status in databases
    
    
    
    
  end
  
  
  def check_user_is_fake(uid)
    weibos = stable{api.statuses.user_timeline(:uid=>uid)  }
    # 判断90% 以上微博都是 0 转发, <=1评论
    t = 0
    weibos.statuses.each{|weibo|
      t += 1 if weibo.reposts_count == 0 && weibo.comments_count <=1
    }
    return (t.to_f / weibos.statuses.size.to_f)  > 0.9
  end
  
  
  def get_users_tag(uids)
    tags = stable{api.tags.tags_batch(uids*",")  }
  end
  


end
