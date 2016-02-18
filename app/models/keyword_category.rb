class KeywordCategory < ActiveRecord::Base

  acts_as_nested_set

  attr_accessible :category, :parent_id, :user_id
  
  scope :user,  ->(user){where("user_id = ?", user.id)}
  
  def self.init_for_user(user)
    root = where(user_id:user.id).root
    if root.nil?
      build_from_hash  user.id,nil, "root" => nil
    end
    
  end
  
  
  
  def self.build_from_hash(user_id,parent_id,hash)
    if hash.is_a? Hash
      hash.each{|key,value|
        node = where(user_id:user_id, category:key, parent_id:parent_id).first_or_create
        build_from_hash(user_id, node.id, value) if value
      }
    elsif hash.is_a? Array
      hash.each{|key|
        Keyword.where(user_id:user_id, name:key, category_id:parent_id).first_or_create
      }
    end
  end
  
end

