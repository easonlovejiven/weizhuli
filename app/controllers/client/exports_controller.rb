# -*- encoding : utf-8 -*-
class Client::ExportsController < Client::ApplicationController
  layout "client"
  add_breadcrumb "Home", "/", title: "Home"
  add_breadcrumb "数据导出", nil
  

  def index

  end

  def new
    @exportor = params[:exportor]
    @export = MExporter.new
    @export.exportor = @exportor
  end

  def create

    @export = MExporter.new(params[:m_exporter])

    pms = params[:params]
    @export.params = pms
    @export.status = 0
    @export.user_id = current_user.id
    if @export.save
      flash[:success] = "任务创建成功，导出完毕后会将文件发送到您的邮箱，可能过程所耗时间会较长，请耐心等并检查邮箱，"
      redirect_to client_exports_path
    else
      @exportor  = @export.exportor
      render :action=>:new
    end
  end


  def edit
  end

end
