# -*- encoding : utf-8 -*-
class PasswordResetsController < ApplicationController

  before_filter :load_user_using_perishable_token, :only => [:edit, :update]  

  layout "frontend"
  
  def new  
  end  
    
  def create
    if session[:proof_image][:text] != params[:valid_code]
      flash[:valid_code] = _("验证码错误")
      render :action => :new
      return
    end
    mail = params[:password_reset] ||= {}
    @user = User.find_by_email(mail[:email]) 
    if @user  
      @user.deliver_password_reset_instructions!  
      flash[:notice] = _("Instructions to reset your password have been emailed to you. ") +  
      _("Please check your email.")  
      render :action => :new  
    else  
      flash[:error] = _("No user was found with that email address")  
      render :action => :new  
    end  
  end  



  
  def edit  
  end  
    
  def update  
    @user.password = params[:user][:password]  
    @user.password_confirmation = params[:user][:password_confirmation]  
    if @user.save  
      flash[:notice] = "密码更新成功, 请登录"
      redirect_to login_path
    else  
      render :action => :edit  
    end  
  end  
    
private  

  def load_user_using_perishable_token  
    @user = User.find_using_perishable_token(params[:id])  
    unless @user  
      flash[:notice] = "对不起, 该链接已过期或被损坏. 您可以尝试从邮件内容里复制链接, 或者重新找回密码"
      redirect_to login_path
    end  
  end


end
