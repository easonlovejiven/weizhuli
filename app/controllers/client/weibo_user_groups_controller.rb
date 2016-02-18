# -*- encoding : utf-8 -*-
class Client::WeiboUserGroupsController < Client::ApplicationController
  layout "client"
  
  add_breadcrumb "系统管理", nil, title: "my link title"
  add_breadcrumb "微博类型", :client_weibo_user_groups_path
  
  # GET /client/weibo_user_groups
  # GET /client/weibo_user_groups.json
  def index
    @weibo_user_group = current_user.weibo_user_groups.build
    @weibo_user_groups = current_user.weibo_user_groups.all

    respond_to do |format|
      format.html # index.html.erb
      format.json { render json: @weibo_user_groups }
    end
  end

  # GET /client/weibo_user_groups/1
  # GET /client/weibo_user_groups/1.json
  def show
    @weibo_user_group = current_user.weibo_user_groups.find(params[:id])

    respond_to do |format|
      format.html # show.html.erb
      format.json { render json: @weibo_user_group }
    end
  end

  # GET /client/weibo_user_groups/new
  # GET /client/weibo_user_groups/new.json
  def new
    @weibo_user_group = current_user.weibo_user_groups.build

    respond_to do |format|
      format.html # new.html.erb
      format.json { render json: @weibo_user_group }
    end
  end

  # GET /client/weibo_user_groups/1/edit
  def edit
    @weibo_user_group = current_user.weibo_user_groups.find(params[:id])
  end

  # POST /client/weibo_user_groups
  # POST /client/weibo_user_groups.json
  def create
    @weibo_user_group = current_user.weibo_user_groups.build(params[:weibo_user_group])

    respond_to do |format|
      if @weibo_user_group.save
        format.html { redirect_to [:client,:weibo_user_groups], notice: 'Weibo User Group was successfully created.' }
        format.json { render json: @weibo_user_group, status: :created, location: @weibo_user_group }
      else
        format.html { render action: "index" }
        format.json { render json: @weibo_user_group.errors, status: :unprocessable_entity }
      end
    end
  end

  # PUT /client/weibo_user_groups/1
  # PUT /client/weibo_user_groups/1.json
  def update
    @weibo_user_group = current_user.weibo_user_groups.find(params[:id])

    respond_to do |format|
      if @weibo_user_group.update_attributes(params[:weibo_user_group])
        format.html { redirect_to [:client,@weibo_user_group], notice: 'Weibo User Group was successfully updated.' }
        format.json { head :no_content }
      else
        format.html { render action: "edit" }
        format.json { render json: @weibo_user_group.errors, status: :unprocessable_entity }
      end
    end
  end

  # DELETE /client/weibo_user_groups/1
  # DELETE /client/weibo_user_groups/1.json
  def destroy
    @weibo_user_group = current_user.weibo_user_groups.find(params[:id])
    @weibo_user_group.destroy

    respond_to do |format|
      format.html { redirect_to [:client, :weibo_user_groups] }
      format.json { head :no_content }
    end
  end
end
