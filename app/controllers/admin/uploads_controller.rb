# -*- encoding : utf-8 -*-
class Admin::UploadsController < Admin::ApplicationController


  layout "admin"

  # GET /uploads
  # GET /uploads.xml
  def index
    @uploads = Upload.paginate(:include=>[:file_references],:page=>params[:page],:per_page=>$DEFAULT_PER_PAGE_BE,:order=>"created_at desc")

    respond_to do |format|
      format.html # index.html.erb
      format.xml  { render :xml => @uploads }
    end
  end

  # GET /uploads/1
  # GET /uploads/1.xml
  def show
    @upload = Upload.find(params[:id])

    respond_to do |format|
      format.html # show.html.erb
      format.xml  { render :xml => @upload }
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

  # GET /uploads/1/edit
  def edit
    @upload = Upload.find(params[:id])
  end

  # this method is useless
  # EVERY UPLOADING SHOULD POST TO  /uploads BUT NOT /admin/uploads
  def create
    # USELESS
  end

  # PUT /uploads/1
  # PUT /uploads/1.xml
  def update
    @upload = Upload.find(params[:id])

    respond_to do |format|
      if @upload.update_attributes(params[:upload])
        flash[:notice] = 'Upload was successfully updated.'
        format.html { redirect_to(@upload) }
        format.xml  { head :ok }
      else
        format.html { render :action => "edit" }
        format.xml  { render :xml => @upload.errors, :status => :unprocessable_entity }
      end
    end
  end

  # DELETE /uploads/1
  # DELETE /uploads/1.xml
  def destroy
    @upload = Upload.find(params[:id])
    @upload.destroy

    respond_to do |format|
      format.html { redirect_to(admin_uploads_url) }
      format.xml  { head :ok }
    end
  end
  


  def operations
    # if :action is not empty, and the action return false (failed), do nothing
    # else return to the referer page
    if !params[:operation].blank?  && !send(("operations_"+params[:operation]).to_sym)
    else
      redirect_to request.env['HTTP_REFERER']
    end
  end

  def operation
    @upload = Upload.find(params[:id])

    # if :action is not empty, and the action return false (failed), do nothing
    # else return to the referer page
    if !params[:operation].blank?  && !send(("operation_"+params[:operation]).to_sym)
    else
      redirect_to request.env['HTTP_REFERER'] || admin_uploads_path
    end
  end

  
private

  #
  # for operations
  #
  
  def operations_destroy_all
    Upload.destroy params[:uploads]
    return true
  end

  
end
