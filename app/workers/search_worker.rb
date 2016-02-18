# -*- encoding : utf-8 -*-
class SearchWorker

  include Sidekiq::Worker
  sidekiq_options :queue => :search, :backtrace => true
  
  def perform(id,title)
    export = MExporter.find(id)
    export.run
  end
end
