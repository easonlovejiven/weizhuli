# -*- encoding : utf-8 -*-
class Client::UploadsController < Client::ApplicationController


  layout "client"

  def index
    if params[:model] == "select_box"
      @images = Image.includes(:file_references).where(["file_references.user_id=? and file_references.reference_type = ?",current_user.id, "OrderItem"])
      
      render :layout=>false, :action=>"select_box"
    else
      
    end
  end



  # GET /uploads/new
  # GET /uploads/new.xml
  def new
    @upload = Upload.new
    @upload.tmp_content_type = params[:content_type]

    upload_type = ["image","document"].delete(params[:type])
    

    respond_to do |format|
      format.html { 
        layout = true
        layout = "ajax" if request.xhr?
        layout = params[:layout].to_s.strip=="false" ? false : params[:layout] if ["false","ajax","dialog"].include?(params[:layout].to_s.strip)
        if upload_type
          render :action => "new_"+upload_type,:layout=>layout 
        else
          render :layout => layout
        end
      } # new.html.erb
      format.xml  { render :xml => @upload }
    end
  end

  # this method is useless
  # EVERY UPLOADING SHOULD POST TO  /uploads BUT NOT /admin/uploads
  def create
    # USELESS
  end

end
