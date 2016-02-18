# -*- encoding : utf-8 -*-
class WeiboToken < ActiveRecord::Base

  scope :tqq, where("weibo_tokens.platform='tqq2'")
  scope :weibo, where("weibo_tokens.platform='weibo'")


  def get_weibo_client
    @client = WeiboOAuth2::Client.new 
    @client.get_token_from_hash()
  end


  # attrs :  {"token"=>"2.005wKAMBXlStODcbce8802d6ybQFfE", "uid"=>1093490924, "expires"=>true, "expires_at"=>1363207413}
  def self.create_or_update(attrs)
    # find by id first
    token= self.find_by_uid(attrs['uid'])
    
    # if token exist, update attributes
    # else create new one
    token = self.new if !token
    
    attrs.each{|key,value|
      token[key] = value if token.attributes.keys.include? key
    }
    
    # save record
    token.save!
    
  end
  
  def self.select_weibo_interface
    key = "2751696217"
    secret = "3dbddd005fc1af2600f795806cc372bc"
    WeiboOAuth2::Config.api_key = key
    WeiboOAuth2::Config.api_secret = secret


    @client = WeiboOAuth2::Client.new
    u = "a11139606@sina.cn"
    p = "m11134558"
    t = @client.auth_password.get_token(u,p)
  end

end
