# -*- encoding : utf-8 -*-
class Admin::LocationsController < Admin::ApplicationController

  layout 'admin'

  # GET /locations
  # GET /locations.xml
  def index
    @locations = Location.search(params[:search]).includes(:locales).order("status desc, locations.id asc").paginate(:page=>params[:page],:per_page=>$DEFAULT_PER_PAGE_BE)

    respond_to do |format|
      format.html # index.html.erb
      format.xml  { render :xml => @locations }
    end
  end

  # GET /locations/1
  # GET /locations/1.xml
  def show
    @location = Location.find(params[:id])

    respond_to do |format|
      format.html # show.html.erb
      format.xml  { render :xml => @location }
    end
  end

	def init_new_form
    @location.locales.build(:locale=>I18n.locale)
	end
	
  # GET /locations/new
  # GET /locations/new.xml
  def new
    @location = Location.new(:status=>1)
    init_new_form

    respond_to do |format|
      format.html # new.html.erb
      format.xml  { render :xml => @location }
    end
  end

  # GET /locations/1/edit
  def edit
    @location = Location.find(params[:id])
  end

  # POST /locations
  # POST /locations.xml
  def create
    parent = Location.find(params[:location][:parent_id])
    @location = parent.children_class.new(params[:location])

    respond_to do |format|
      if @location.save
        flash[:notice] = 'Admin::Location was successfully created.'
        format.html { redirect_to(admin_location_path(@location)) }
        format.xml  { render :xml => @location, :status => :created, :location => [:admin,@location] }
      else
        format.html { render :action => "new" }
        format.xml  { render :xml => @location.errors, :status => :unprocessable_entity }
      end
    end
  end

  # PUT /locations/1
  # PUT /locations/1.xml
  def update
    @location = Location.find(params[:id])
    respond_to do |format|
      if @location.update_attributes(params[:country] || params[:province] || params[:city] || params[:region] || params[:area])
        flash[:notice] = 'Admin::Location was successfully updated.'
        format.html { redirect_to(admin_location_path(@location)) }
        format.xml  { head :ok }
      else
        format.html { render :action => "edit" }
        format.xml  { render :xml => @location.errors, :status => :unprocessable_entity }
      end
    end
  end

  # DELETE /locations/1
  # DELETE /locations/1.xml
  def destroy
    @location = Location.find(params[:id])
    @location.destroy

    respond_to do |format|
      format.html { redirect_to(admin_locations_url) }
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
    @location = Location.find(params[:id])

    # if :action is not empty, and the action return false (failed), do nothing
    # else return to the referer page
    if !params[:operation].blank?  && !send(("operation_"+params[:operation]).to_sym)
    else
      redirect_to request.env['HTTP_REFERER'] || admin_locations_path
    end
  end

  
private

  #
  # for operations
  #
  
  def operations_destroy_all
    Location.destroy params[:locations]
    return true
  end

  
end
