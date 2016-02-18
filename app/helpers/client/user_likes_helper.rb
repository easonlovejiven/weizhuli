# -*- encoding : utf-8 -*-
module Client::UserLikesHelper


  def ilike_path(obj)
    client_user_like_path(obj.class.to_s, obj.id)
  end


end
