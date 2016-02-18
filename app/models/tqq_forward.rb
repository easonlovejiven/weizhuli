class TqqForward < ActiveRecord::Base
  attr_accessible :forward_at, :forward_id, :forward_openid, :openid, :weibo_id, :parent_openid
end
