# -*- encoding : utf-8 -*-
class Client::WeiboMessagesController < Client::ApplicationController
  layout "client"
  
  add_breadcrumb "Home", "/", title: "my link title"
  add_breadcrumb "发送私信", nil
  
  # GET /client/weibo_messages
  # GET /client/weibo_messages.json
  def index
    @weibo_messages = MWeiboMessage.where(user_id:current_user.id).paginate(page:params[:page],per_page:20)

    respond_to do |format|
      format.html # index.html.erb
      format.json { render json: @weibo_messages }
    end
  end

  # GET /client/weibo_messages/1
  # GET /client/weibo_messages/1.json
  def show
    @weibo_message = MWeiboMessage.where(user_id:current_user.id).find(params[:id])

    respond_to do |format|
      format.html # show.html.erb
      format.json { render json: @weibo_message }
    end
  end

  # GET /client/weibo_messages/new
  # GET /client/weibo_messages/new.json
  def new

  end
  # POST /client/weibo_messages
  # POST /client/weibo_messages.json
  def create

    uids = params[:uids]
    uids.split("\n").each{|row|
      row = row.strip
      next if row.blank?
      MWeiboMessage.create({user_id:current_user.id, uid:row,content:params[:content],status:0})
    }

    respond_to do |format|
      format.html { redirect_to [:client,:weibo_messages], notice: 'Post category was successfully created.' }
      format.json { render json: @weibo_message, status: :created, location: @weibo_message }
    end
  end

  # DELETE /client/weibo_messages/1
  # DELETE /client/weibo_messages/1.json
  def destroy
    @weibo_message = current_user.weibo_messages.find(params[:id])
    @weibo_message.destroy

    respond_to do |format|
      format.html { redirect_to [:client, :weibo_messages] }
      format.json { head :no_content }
    end
  end
end
