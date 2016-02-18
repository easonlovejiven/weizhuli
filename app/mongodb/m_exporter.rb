# -*- encoding : utf-8 -*-
class MExporter
  include MongoMapper::Document


  key :user_id, Integer
  key :exportor, String
  key :mail_to, String
  key :mail_subject,  String
  key :params, Hash #传递的参数
  key :status, Integer
  key :parent_exporter_id,  Integer
  key :task_id, Integer
  key :file_name_suffix,String

  timestamps!

  validates_presence_of :mail_to


  after_create :create_task
  before_create :create_task_id

  def create_task_id
    self.task_id = Time.now.strftime("%Y%m%d%H%M%S")
  end

  def create_task
    load "app/exportors/#{exportor.to_s.underscore}.rb" # reload exportor
    clazz = exportor.constantize
    if clazz == SearchWeiboInterfaceByKeywordsTimeTwoExportor
      SearchWorker.perform_async(self.id,clazz.title) #重建一个导出任务
    end
    ExportWorker.perform_async(self.id,clazz.title)
  end

  def run
    # $GLOBAL_API_IP="115.28.14.213"
    export = exportor.constantize.new(task_id:self.task_id, mail_to:mail_to,file_name_suffix:file_name_suffix)
    export.export(params).deliver
    self.update_attribute(:status,1)
    $GLOBAL_API_IP=nil
  end
end

