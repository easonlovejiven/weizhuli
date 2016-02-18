# -*- encoding : utf-8 -*-
class ExportWorker

  include Sidekiq::Worker
  sidekiq_options :queue => :exports, :backtrace => true
  
  def perform(id,title)
    export = MExporter.find(id)
    export.run
  end
end

