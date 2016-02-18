# -*- encoding : utf-8 -*-
class AuthenticationsController < ApplicationController
  # GET /authentications
  # GET /authentications.xml
  def index
    @authentications = current_user.authentications if current_user
  end

  def new
  end


  # POST /authentications
  # POST /authentications.xml
  def create

    omniauth = session["omniauth.auth"]
    uid = case omniauth['provider']
    when "weibo"
      omniauth["uid"]
    when "tqq2"
      omniauth["uid"]
    else 
      omniauth['uid']
    end

    if ['weibo','tqq2','tsohu2','renren'].include? omniauth['provider']
      @token = omniauth[:credentials]
      # 保存 token 到数据库
      WeiboToken.create_or_update(@token.merge(:uid=>uid,:appkey=>session[:appkey],:platform=>omniauth['provider']))
      # 保存 用户数据
      # WeiboAccount.create_or_update(omniauth['extra']['raw_info'])
    end
    authentication = Authentication.find_by_provider_and_uid(omniauth['provider'], uid)
    if authentication
      flash[:notice] = "Signed in successfully."
      flash[:authentication_user] = authentication.user
      if UserSession.create(authentication.user).valid?
        redirect_to session[:auth_return_url] || after_login_path
      else
        redirect_to login_path(:login_failed=>"")
      end
    elsif current_user
      current_user.authentications.create!(:provider => omniauth['provider'], :uid => uid)
      flash[:notice] = "Authentication successful."
      redirect_to session[:auth_return_url] || after_login_path
    else
#      @user = User.create(:login=>"#{omniauth.provider}@#{omniauth['uid']}",:status=>1, :password=>"123123", :password_confirmation=>"123123", :email=>"unknow")
#      @user.roles << Role.find_by_name("client")
#      @user.authentications.create!(:provider => omniauth['provider'], :uid => uid)
#      @user_session = UserSession.create(@user)
      #session[:omniauth] = omniauth
      flash[:notice] = "请您登录"
      redirect_to root_path
    end
  end


  def create_from_report

  end

  # DELETE /authentications/1
  # DELETE /authentications/1.xml
  def destroy
    @authentication = current_user.authentications.find(params[:id])
    @authentication.destroy
    flash[:notice] = "Successfully destroyed authentication."
    redirect_to authentications_url
  end
end
