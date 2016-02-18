# -*- encoding : utf-8 -*-
class UsersController < ApplicationController

    layout 'login_signin'

  def new
  	if current_user
  		redirect_to client_root_path
  	else
		  @user = User.new(:email=>params[:email])
		  respond_to do |wants|
		    wants.html 
		  end
    end
  end
  
  def init_organization
    @user.build_organization
    @user.organization.locales.build(:locale=>I18n.locale)
  end
  
  def new_organization
  	if current_user
  		redirect_to client_events_path
  	else
		  @user = User.new(:email=>params[:email])
		  init_organization
		  respond_to do |wants|
		    wants.html 
		  end
    end
  end
  
  def create
    params[:user][:email] = params[:user][:email].strip if params[:user][:email]
    role = Role.find_by_name :client
    @user = User.new(params[:user])
    @user.status = 2
    @user.login = @user.email
    @user.roles << role
    if params[:card_register].blank?
      @user.default_user_token = @user.set_user_token
      @user.check_verification_code = true
      @user.inputed_verification_code = params[:valid_code]
      @user.verification_code = session[:proof_image][:text]
    end
    if @user.save
       @user.reload
       flash[:notice] = _("您的帐户已注册成功, 您可以选择您要购买的套餐")
       flash[:user_mail] = @user.login
#       if request.xhr?
#          render  :json=>{:status=>"success"}
#       else
#       end
         respond_to do |format|
        
          format.html{
            redirect_to client_root_path
          }
          
          format.json{
            render  :json=>{:status=>"success"}
          }
          format.js{
            render  :json=>{:status=>"success"}
          }
        
         end
    else
       if request.xhr?
           render  :json=>{:status=>"error", :errors=>@user.errors}
       else
        respond_to do |format|
          format.html{
            flash[:user] = @user
	          render :action => :new 
          }
          format.json{
            render  :json=>{:status=>"error", :errors=>@user.errors}
          }
          format.js{
            render  :json=>{:status=>"error", :errors=>@user.errors}
          }
        end
      end
    end
  end
  
  def create_organization
    role = Role.find_by_name :client
    @user = User.new(params[:user])
    @user.status = 2
    @user.login = @user.email
    @user.roles << role
    
    @user.default_user_token = @user.set_user_token
    @user.check_verification_code = true
    @user.inputed_verification_code = params[:valid_code]
    @user.verification_code = session[:proof_image][:text]
    
    if @user.save
      @user.property.user_type = 'organization'
      @user.save
      flash[:notice] = _("A confirmation email has been sent to your mailbox!")
      flash[:user_mail] = @user.login
      respond_to do |format|
        format.html{
          redirect_to success_path
        }
        format.json{
          render  :json=>{:status=>"success"}
        }
        format.js{
          render  :json=>{:status=>"success"}
        }
      end
    else
    end
    
  end

  def forgot_password
    
  end
  
 def success
	@user = User.new
 end
 
 def comingsoon
    render :layout=>"front_page"
 end

end
