# -*- encoding : utf-8 -*-
class MUser
  include MongoMapper::Document

  key :tags,  Array

  def self.find_by_id(id)
    begin
      MUser.find(id)
    rescue Exception=>e
      e.message << " UID: #{id}"
      raise
    end
  end
end
