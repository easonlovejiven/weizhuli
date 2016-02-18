# -*- encoding : utf-8 -*-
# archive user relations each hour
class GetWeiboBasicTask < WeiboTaskBase

  SUPPORT_INTERVAL = [:hourly]
  ONLY_TOKEN_USER = false
  SUPPORT_MULTI_USERS = true
  

  def run
    user = stable{api.users.show(:uid=>@uid)  }
    save_weibo_user user
  end
  
  


end
