# -*- encoding : utf-8 -*-
class Reports::AuthenticationsController < Reports::ApplicationController
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
    uid = omniauth["uid"]

    authentication = Authentication.find_by_provider_and_uid(omniauth['provider'], uid)
    if authentication
      if authentication.user.id == current_user.id
        flash[:notice] = "Signed in successfully."
        flash[:authentication_user] = authentication.user
        if UserSession.create(authentication.user).valid?
          redirect_to reports_root_path
        else
          redirect_to login_path(:login_failed=>"")
        end
      else
        render :text=>"该微博已经被其它帐户绑定了"

      end
    elsif current_user
      current_user.authentications.create!(:provider => omniauth['provider'], :uid => uid)

      # create monit weibo account for user
      monit_account = MonitWeiboAccount.where(uid:uid).first_or_create(status:1)

      flash[:notice] = "Authentication successful."
      redirect_to reports_root_path
    else

      @user = User.create(:login=>"weixin_#{session['weixin_openid']}",:status=>1, :password=>"123123", :password_confirmation=>"123123", :email=>"unknow",
            profile_attributes:{weixin_openid:session[:weixin_openid]}
        )
      @user.roles << Role.find_by_name("report_client")
      @user.authentications.create!(:provider => omniauth['provider'], :uid => uid)
      @user_session = UserSession.create(@user)

      redirect_to reports_root_path
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
