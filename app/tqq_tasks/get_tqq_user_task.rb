#-*- encoding : utf-8 -*-

#save all tqq_user content for current account
class GetTqqUserTask < TqqTaskBase
  #  this task supported interval
  SUPPORT_INTERVAL = [:hourly,:daily,:weekly,:monthly]
  # if this task stats only for the user which logged in by token
  # means to use this task , the target user have to LOGIN
  ONLY_TOKEN_USER = false
  SUPPORT_MULTI_USERS = false
def initialize
    super(nil)
  end     
#自动将数据库中没有读取过 tag 的用户, 从腾讯api 读取tags
def run
    count = MTqqUser.where(tags:nil).count
    i = 0
    
    # 循环 每次 20 条
    while true
      mus = MTqqUser.where(tags:nil).limit(20).all 
      break if mus.blank?
      users = {}
      ids = []
      mus.each{|u|
        u[:tags] = []
        u.save!
        
        ids << u.id
        users[u.id] = u
      }
      
      ids.each{|id|
      res = stable{api.tags.user.other_info(:fopenid => id).data}
      #res.each{|h|
        openid = res.openid
        tags = []
        #res.each{|info|
          res.delete "weight"
          tags << res.to_a.first[1]
        #}
        
        users[openid].tags = tags
        users[openid].save!
      }
      
      i += 20
      puts "Load user tags #{(i.to_f/count.to_f).round(3)}%"
    end
  end
end
