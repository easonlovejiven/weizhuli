# -*- encoding : utf-8 -*-
# archive user relations each hour
class GetTqqBasicTask < TqqTaskBase

  SUPPORT_INTERVAL = [:hourly]
  ONLY_TOKEN_USER = false
  SUPPORT_MULTI_USERS = true
  
  def run
    user = stable{api.user.other_info(name:@name, fopenid:@openid)}
    save_weibo_user user.data
  end
  
  


end
