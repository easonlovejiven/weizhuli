# -*- encoding : utf-8 -*-
class Client::PostGeosController < Client::ApplicationController
  layout "client"
  
  add_breadcrumb "系统管理", nil, title: "my link title"
  add_breadcrumb "微博位置", :client_post_geos_path
  
  # GET /client/post_geos
  # GET /client/post_geos.json
  def index
    @post_geos = current_user.settings.post_geos || []

    respond_to do |format|
      format.html # index.html.erb
      format.json { render json: @post_geos }
    end
  end

  # GET /client/post_geos/1
  # GET /client/post_geos/1.json
  def show
    @post_geo = current_user.post_geos.find(params[:id])

    respond_to do |format|
      format.html # show.html.erb
      format.json { render json: @post_geo }
    end
  end

  # GET /client/post_geos/new
  # GET /client/post_geos/new.json
  def new
    @post_geo = current_user.post_geos.build

    respond_to do |format|
      format.html # new.html.erb
      format.json { render json: @post_geo }
    end
  end

  # GET /client/post_geos/1/edit
  def edit
    @post_geo = current_user.post_geos.find(params[:id])
  end

  # POST /client/post_geos
  # POST /client/post_geos.json
  def create
    @post_geos = params[:post_geos].split("\n").map{|line| line.blank? ? nil : line.strip}.compact
    current_user.settings.post_geos = @post_geos

    respond_to do |format|
      format.html { redirect_to [:client,:post_geos], notice: 'Post category was successfully created.' }
      format.json { render json: @post_geo, status: :created, location: @post_geo }
    end
  end

  # PUT /client/post_geos/1
  # PUT /client/post_geos/1.json
  def update
    geos = params[:post_geos].split("\n").map{|line| line.blank? ? nil : line.strip}.compact
    current_user.settings.post_geos = geos

    respond_to do |format|
      format.html { redirect_to client_post_geos_path, notice: 'Post geos was successfully updated.' }
      format.json { head :no_content }
    end
  end

  # DELETE /client/post_geos/1
  # DELETE /client/post_geos/1.json
  def destroy
    @post_geo = current_user.post_geos.find(params[:id])
    @post_geo.destroy

    respond_to do |format|
      format.html { redirect_to [:client, :post_geos] }
      format.json { head :no_content }
    end
  end
end
