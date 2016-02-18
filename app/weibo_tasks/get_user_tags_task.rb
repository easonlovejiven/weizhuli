# -*- encoding : utf-8 -*-

# save all weibo content for current account
class GetUserTagsTask < WeiboTaskBase

  #  this task supported interval
  SUPPORT_INTERVAL = [:hourly,:daily,:weekly,:monthly]
  # if this task stats only for the user which logged in by token
  # means to use this task , the target user have to LOGIN
  ONLY_TOKEN_USER = false
  SUPPORT_MULTI_USERS = false

  def initialize
    super(nil)
  end

  # 自动将数据库中没有读取过 tag 的用户, 从新浪api 读取tags
  def run
    count = MUser.where(tags:nil).count
    i = 0
    
    # 循环 每次 20 条
    while true
      mus = MUser.where(tags:nil).limit(20).all 
      break if mus.blank?
      users = {}
      ids = []
      mus.each{|u|
        u[:tags] = []
        u.save!
        
        ids << u.id
        users[u.id] = u
      }
      
      
      res = stable{api.tags.tags_batch ids*","}
      res.each{|h|
        uid = h[:id]
        tags = []
        h[:tags].each{|info|
          info.delete "weight"
          tags << info.to_a.first[1]
        }
        
        users[uid].tags = tags
        users[uid].save!
      }
      
      i += 20
      puts "Load user tags #{(i.to_f/count.to_f).round(3)}%"
    end
  end


end
