# -*- encoding : utf-8 -*-
class UserSessionsController < ApplicationController

     layout 'frontend'

    def new
      @user_session = UserSession.new
      if params.keys.include?("login_failed")
        @user_session.errors[:login] << _("登录失败, 帐户被禁用或尚未激活")
      end
      if request.xhr?
        render :action =>:ajax_login,:layout=>false
      end
    end

    def create
      @user_session = UserSession.new(params[:user_session])
      respond_to do |wants|
        if @user_session.save
          if @user_session.login == 'intelhq'
            @user_session = UserSession.new(User.find_by_login("intelbiz"))
            @user_session.save
          end
          wants.html {
            after_login
          }
          wants.json {
            render :json=>{:status=>"success"}
          }
          wants.js { render :update do |page|
              page.reload
          end}

        else
          wants.html {
            render :action => :new
          }
          wants.json {
            render :json=>{:status=>"failed", :errors=>@user_session.errors}
          }
          wants.js { render :update do |page|
              page['#dialog'].replace_html :partial => "sites/new_js",:locals => {:ac=>"login",:user_session => @user_session}
          end}
        end

      end
    end


    # after login, response to how to redirect
    def after_login
      
      if current_user.role_symbols.include? :admin
        redirect_to admin_root_url
      elsif current_user.role_symbols.include? :pinganbeijing
        redirect_to params[:return].blank? ?  pinganbeijing_root_url : params[:return]
      elsif current_user.role_symbols.include? :client
        redirect_to params[:return].blank? ?  client_root_url : params[:return]
      elsif current_user.role_symbols.include? :renren
        redirect_to params[:return].blank? ?  client_contents_url : params[:return]
      elsif current_user.role_symbols.include? :gift_applyer
        redirect_to params[:return].blank? ?  intel_gift_applies_url : params[:return]
      else
        redirect_to params[:return].blank? ?  client_root_url : params[:return]
      end

    end

    def destroy
      current_user_session.destroy if current_user_session
      redirect_to params[:return] || "/"
    end

end

