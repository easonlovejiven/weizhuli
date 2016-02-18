# -*- encoding : utf-8 -*-
class Client::UserController < Client::ApplicationController

  layout  "client"

  before_filter :set_user

  # dashboard index page
  def index
    @html_title = _("我的帐户首页")
  end

  def active_reload
    @activities = Activity.can_see(current_user).order("activities.id desc").limit(6)
    respond_to do |format|
        format.html {
          render :partial=>"/client/user/user_active_info",:locals => {:activities=>@activities}
        }
    end
  end

  def modify_password
  end

  def active_mail
  end

  def update_email
      if !@user.valid_password?(params[:old_password])
        @user.errors[:base] << _("对不起, 您输入的旧密码不正确")

        respond_to do |format|
          format.html {
            redirect_to active_mail_client_user_path
          }
          format.js {
            render :json=>{:errors=>@user.errors}
          }
        end
       return
      end

     @user.email = params[:user][:email]
     @user.login = @user.email
     @user.email_verify!
    if @user.save
      @user.deliver_activation_instructions!
      respond_to do |format|
        format.html {
          flash[:notice] = _("邮件修改成功")
          redirect_to active_mail_client_user_path
        }
        format.js {
          render :json=>{:status=>"success"}
        }
      end
    else
      respond_to do |format|
        format.html {
          render :action=>"active_mail"
        }
        format.js {
          render :json=>{:errors=>@user.errors}
        }
      end
    end
    @html_title = _("邮件修改")
  end

  def update_password
    if !@user.valid_password?(params[:old_password])
      @user.errors[:base] << _("对不起, 您输入的旧密码不正确")

      respond_to do |format|
        format.html {
          redirect_to client_modify_password_path
        }
        format.js {
          render :json=>{:errors=>@user.errors}
        }
      end

      return
    end

    @user.password = params[:user][:password]
    @user.password_confirmation = params[:user][:password_confirmation]

    if @user.save
      respond_to do |format|
        format.html {
          flash[:notice] = _("密码修改成功")
          redirect_to client_modify_password_path
        }
        format.js {
          render :json=>{:status=>"success"}
        }
      end
    else
      respond_to do |format|
        format.html {
          render :action=>"modify_password"
        }
        format.js {
          render :json=>{:errors=>@user.errors}
        }
      end
    end
      @html_title = _("密码修改")
  end


  def show
  end

  def edit
    build_user_profile_form
  end

  def update

    if @user.update_attributes(params[:user])
      respond_to do |format|
        format.html {
          current_user.reload
          flash[:success] = _("个人信息更新成功")
          redirect_to client_user_path
        }
        format.js {
          render :json=>{:status=>"success"}
        }
      end


    else
      respond_to do |format|
        format.html {
          render :action=>:edit
        }
        format.js {
          render :json=>{:error=>@user.errors}
        }
      end
    end
  end


  def upload_avatar

  end


  def crop_avatar
    @image = Image.find params[:avatar_image_id]
    @image.crop_x = params[:avatar_crop_left]
    @image.crop_y = params[:avatar_crop_top]
    @image.crop_w = params[:avatar_crop_width]
    @image.crop_h = params[:avatar_crop_height]

    @image.attachment.reprocess!
    @image.attachment_width = params[:avatar_crop_width]
    @image.attachment_height = params[:avatar_crop_width]
    @image.save
    current_user.avatar = @image
    current_user.save!
    
    if request.xhr?
      render :text=> @image.file_path[:thumb]+rand(100000).to_s
    else
      flash[:notice] = "success"
      redirect_back
    end

  end


  def edit_basic_profile
    build_user_profile_form
  end


  def edit_edu_profile
    build_user_profile_form
  end



  def edit_company_profile
    build_user_profile_form
  end




  # after pay a order, ask user input informations
  def order_complete
    @order = Order.find(params[:id])
    if current_user
      redirect_to client_order_path(@order)
    else
      @order.build_user
      @order.user.build_business_card
      @order.user.build_business_card.locales.build(:locale=>I18n.locale)
      render    :layout=>"client/event"
    end
  end




  def save_attendee
    @order = Order.find(params[:id])

    if current_user
    	current_user.update_attributes(params[:charge_order][:user_attributes])
    	u = current_user
    else
		  pass = (0...8).map{ ('a'..'z').to_a[rand(26)] }.join

		  params[:charge_order][:user_attributes][:login] = params[:charge_order][:user_attributes][:business_card_attributes][:locales_attributes]["0"][:email]
		  params[:charge_order][:user_attributes][:email] = params[:charge_order][:user_attributes][:business_card_attributes][:locales_attributes]["0"][:email]

		  params[:charge_order][:user_attributes][:password] = pass
		  params[:charge_order][:user_attributes][:password_confirmation] = pass

			business_card = BusinessCard.new(:gender => params[:charge_order][:user_attributes][:business_card_attributes][:gender])
			business_card.locales << BusinessCardLocale.new(params[:charge_order][:user_attributes][:business_card_attributes][:locales_attributes]["0"])

			params[:charge_order][:user_attributes].delete("business_card_attributes")
			u = User.new(params[:charge_order][:user_attributes])
			u.status = 1
			begin
				u.save!
			rescue
				flash[:notice] = _("用户已存在，请登录后报名")
				redirect_back
				return
			end
			u.business_card = business_card unless business_card.locales.blank?
			role_client = Role.find_by_name :client
			u.roles << role_client
			u.save!


      @order.user = u
      @order.creator = u
      @order.save!


			Notifier.delay.send_name_pass(u.displayable_name, u.login, pass, I18n.locale)
    	@user_session = UserSession.new(
    		:password => pass,
    		:login => u.login,
    		:check => ''
    	)
    	@user_session.save

		end
    @order.user = u

    flash[:login] = u.login
    flash[:pass] = pass

    respond_to do |format|

      #current_user.events << @event if @event.users.id_eq(current_user.id).blank?
#      Notifier.attendees_to_sales(current_user,session[:locale]).deliver
      format.html {
        redirect_to  client_order_path(@order)
        #redirect_to new_client_order_path(:event_id=>@event.id, :price=>@event.discount_price, :number=>@order.number)
      }
    end
  end

  def my_documents
    @documents = current_user.downloads.paginate(:page=>params[:page],:per_page => 15)
  end



:private


  def build_user_profile_form
    @user.build_avatar_reference if @user.avatar_reference.nil?

    # build profiles
    # if a locale of profile always have company,edu, addition
    @user.profiles.each{|profile|
      profile.companies.build if profile.companies.blank?
      profile.edus.build if profile.edus.blank?
      profile.build_addition if profile.addition.nil?
    }
  end




end

