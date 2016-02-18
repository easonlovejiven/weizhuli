# -*- encoding : utf-8 -*-
class Admin::FileReferencesController < Admin::ApplicationController
  layout 'admin'
  # GET /file_references
  # GET /file_references.xml
  def index
    @file_references = FileReference.paginate(:page=>params[:page],:per_page=>$DEFAULT_PER_PAGE_BE,:order=>"created_at desc")

    respond_to do |format|
      format.html # index.html.erb
      format.xml  { render :xml => @file_references }
    end
  end

  # GET /file_references/1
  # GET /file_references/1.xml
  def show
    @file_reference = FileReference.find(params[:id])

    respond_to do |format|
      format.html # show.html.erb
      format.xml  { render :xml => @file_reference }
    end
  end

  # GET /file_references/new
  # GET /file_references/new.xml
  def new
    @file_reference = FileReference.new

    respond_to do |format|
      format.html # new.html.erb
      format.xml  { render :xml => @file_reference }
    end
  end

  # GET /file_references/1/edit
  def edit
    @file_reference = FileReference.find(params[:id])
  end

  # POST /file_references
  # POST /file_references.xml
  def create
    @file_reference = FileReference.new(params[:file_reference])

    respond_to do |format|
      if @file_reference.save
        flash[:notice] = 'FileReference was successfully created.'
        format.html { redirect_to([:admin,@file_reference]) }
        format.xml  { render :xml => @file_reference, :status => :created, :location => @file_reference }
      else
        format.html { render :action => "new" }
        format.xml  { render :xml => @file_reference.errors, :status => :unprocessable_entity }
      end
    end
  end

  # PUT /file_references/1
  # PUT /file_references/1.xml
  def update
    @file_reference = FileReference.find(params[:id])

    respond_to do |format|
      if @file_reference.update_attributes(params[:file_reference])
        flash[:notice] = 'FileReference was successfully updated.'
        format.html { redirect_to([:admin,@file_reference]) }
        format.xml  { head :ok }
      else
        format.html { render :action => "edit" }
        format.xml  { render :xml => @file_reference.errors, :status => :unprocessable_entity }
      end
    end
  end

  # DELETE /file_references/1
  # DELETE /file_references/1.xml
  def destroy
    @file_reference = FileReference.find(params[:id])
    @file_reference.destroy

    respond_to do |format|
      format.html { redirect_to(admin_file_references_url) }
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
    @file_reference = FileReference.find(params[:id])

    # if :action is not empty, and the action return false (failed), do nothing
    # else return to the referer page
    if !params[:operation].blank?  && !send(("operation_"+params[:operation]).to_sym)
    else
      redirect_to request.env['HTTP_REFERER'] || admin_file_references_path
    end
  end

  
private

  #
  # for operations
  #
  
  def operations_destroy_all
    FileRecerence.destroy params[:file_references]
    return true
  end






end
