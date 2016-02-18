# -*- encoding : utf-8 -*-
class UploadsController < ApplicationController

  layout 'dialog'




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

  # POST /documents
  # POST /documents.xml
  def create
    
  
    if params[:upload][:type].blank?
      type = MIME::Types.type_for(params[:upload][:attachment].original_filename).to_s
      clazz = (type=~/image/) ? Image : Document
      @upload = clazz.new(params[:upload])
    else
      
      @upload = params[:upload][:type].constantize.new(params[:upload])
    end
    @upload.attachment_content_type = type.blank? ? "unknow" : type
    # convert orient automaticlly 
    if @upload.type == "Image" && params[:upload][:attachment]
      `convert -auto-orient  #{params[:upload][:attachment].tempfile.path} #{params[:upload][:attachment].tempfile.path}`
    end

    respond_to do |format|
      if @upload.save
        #flash[:notice] = 'Upload was successfully created.'
        format.html { render :layout=>false }
        format.xml  { render :xml => @upload, :status => :created}
        format.js { render :json=>@upload.to_json(:methods=>[:file_path])}
      else
        format.html { render :text => %Q[<script>alert("#{@upload.errors[:base]}");window.history.go(-1);</script>] }
        format.xml  { render :xml => @upload.errors, :status => :unprocessable_entity }
        format.js { render :json=>@upload.errors}
      end
    end


  end

  def update
    create
  end
  
  def new_avatar
  end
end
