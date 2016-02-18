# -*- encoding : utf-8 -*-
module Client::SharesHelper
  def share_path(object)
    client_share_path(:content_type=>object.class.to_s, :content_id => object.id,:with_format=>"script")
  end
end

