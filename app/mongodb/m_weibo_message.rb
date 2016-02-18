# -*- encoding : utf-8 -*-
class MWeiboMessage
  include MongoMapper::Document

  key :user_id, Integer
  key :uid,     Integer
  key :content, String
  key :image_url, String
  key :error,   String
  key :status,  Integer



  after_create :create_task

  def create_task

  end

  def run
    # TODO: run task


    self.update_attribute(:status,1)
  end


  def human_status
    ({0=>"未发送",1=>"已发送",2=>"正在发送",3=>"已发送"})[status] || "未发送"
  end

end

