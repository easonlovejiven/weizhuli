# -*- encoding : utf-8 -*-
class MForwardSpreadTask
  include MongoMapper::Document


  key :weibo_id, Integer
  key :status,  Integer
  key :description, String
  timestamps!



  after_create  :create_task


  def run
    WeiboForward.analyze_tree(weibo_id)
    WeiboForwardRelation.generate_gexf(weibo_id)
    update_attribute(:status,1)
  end



  def create_task
    WeiboForwardSpreadWorker.perform_async(self.id)
  end
end

