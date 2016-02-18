# -*- encoding : utf-8 -*-
class Client::PostCategoriesController < Client::ApplicationController
  layout "client"
  
  add_breadcrumb "系统管理", nil, title: "my link title"
  add_breadcrumb "微博类型", :client_post_categories_path
  
  # GET /client/post_categories
  # GET /client/post_categories.json
  def index
    @post_category = current_user.post_categories.build
    @post_categories = current_user.post_categories.all

    respond_to do |format|
      format.html # index.html.erb
      format.json { render json: @post_categories }
    end
  end

  # GET /client/post_categories/1
  # GET /client/post_categories/1.json
  def show
    @post_category = current_user.post_categories.find(params[:id])

    respond_to do |format|
      format.html # show.html.erb
      format.json { render json: @post_category }
    end
  end

  # GET /client/post_categories/new
  # GET /client/post_categories/new.json
  def new
    @post_category = current_user.post_categories.build

    respond_to do |format|
      format.html # new.html.erb
      format.json { render json: @post_category }
    end
  end

  # GET /client/post_categories/1/edit
  def edit
    @post_category = current_user.post_categories.find(params[:id])
  end

  # POST /client/post_categories
  # POST /client/post_categories.json
  def create
    @post_category = current_user.post_categories.build(params[:post_category])

    respond_to do |format|
      if @post_category.save
        format.html { redirect_to [:client,:post_categories], notice: 'Post category was successfully created.' }
        format.json { render json: @post_category, status: :created, location: @post_category }
      else
        format.html { render action: "index" }
        format.json { render json: @post_category.errors, status: :unprocessable_entity }
      end
    end
  end

  # PUT /client/post_categories/1
  # PUT /client/post_categories/1.json
  def update
    @post_category = current_user.post_categories.find(params[:id])

    respond_to do |format|
      if @post_category.update_attributes(params[:post_category])
        format.html { redirect_to [:client,@post_category], notice: 'Post category was successfully updated.' }
        format.json { head :no_content }
      else
        format.html { render action: "edit" }
        format.json { render json: @post_category.errors, status: :unprocessable_entity }
      end
    end
  end

  # DELETE /client/post_categories/1
  # DELETE /client/post_categories/1.json
  def destroy
    @post_category = current_user.post_categories.find(params[:id])
    @post_category.destroy

    respond_to do |format|
      format.html { redirect_to [:client, :post_categories] }
      format.json { head :no_content }
    end
  end
end
