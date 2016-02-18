# -*- encoding : utf-8 -*-
class Admin::RolesController < Admin::ApplicationController
  # GET /roles
  # GET /roles.xml
  def index
    @roles = Role..paginate(:page=>params[:page], :per_page=>20)

    respond_to do |format|
      format.html # index.html.erb
      format.xml  { render :xml => @roles }
    end
  end

  # GET /roles/1
  # GET /roles/1.xml
  def show
    @role = Role.find(params[:id])

    respond_to do |format|
      format.html # show.html.erb
      format.xml  { render :xml => @role }
    end
  end

  # GET /roles/new
  # GET /roles/new.xml
  def new
    @role = Role.new

    respond_to do |format|
      format.html # new.html.erb
      format.xml  { render :xml => @role }
    end
  end

  # GET /roles/1/edit
  def edit
    @role = Role.find(params[:id])
  end

  # POST /roles
  # POST /roles.xml
  def create
    @role = Role.new(params[:role])

    respond_to do |format|
      if @role.save
        flash[:notice] = 'Role was successfully created.'
        format.html { redirect_to([:admin,@role]) }
        format.xml  { render :xml => @role, :status => :created, :location => [:admin,@role] }
      else
        format.html { render :action => "new" }
        format.xml  { render :xml => @role.errors, :status => :unprocessable_entity }
      end
    end
  end

  # PUT /roles/1
  # PUT /roles/1.xml
  def update
    @role = Role.find(params[:id])

    respond_to do |format|
      if @role.update_attributes(params[:role])
        flash[:notice] = 'Role was successfully updated.'
        format.html { redirect_to([:admin,@role]) }
        format.xml  { head :ok }
      else
        format.html { render :action => "edit" }
        format.xml  { render :xml => @role.errors, :status => :unprocessable_entity }
      end
    end
  end

  # DELETE /roles/1
  # DELETE /roles/1.xml
  def destroy
    @role = Role.find(params[:id])
    @role.destroy

    respond_to do |format|
      format.html { redirect_to(admin_roles_url) }
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
    @role = Role.find(params[:id])

    # if :action is not empty, and the action return false (failed), do nothing
    # else return to the referer page
    if !params[:operation].blank?  && !send(("operation_"+params[:operation]).to_sym)
    else
      redirect_to request.env['HTTP_REFERER'] || admin_roles_path
    end
  end

  
private

  #
  # for operations
  #
  
  def operations_destroy_all
    Role.destroy params[:roles]
    return true
  end

end
