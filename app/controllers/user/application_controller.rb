# -*- encoding : utf-8 -*-
class User::ApplicationController < ActionController::Base
  include FastGettext::Translation
  filter_access_to :all
  layout 'admin'

  helper  :all

  before_filter :set_locale
  before_filter :set_current_user, :set_user
  before_filter :set_industry_icon_infos
  helper_method :current_user_session, :current_user

  protected

  def set_user
    # don't do this any more
    # redirect_to client_root_path if params[:user_id].to_i == current_user.id
    @user = User.actived.profile_complished.find(params[:user_id])
  end

  def set_industry_icon_infos
    if @user.is_industry_icon?
       @industry_icon_attend_event_ids = Event.find_by_sql ["SELECT DISTINCT es.event_id as eid
                                          FROM people p
                                          LEFT JOIN speakers sp ON sp.person_id = p.id
                                          LEFT JOIN event_sessions_speakers esp ON esp.speaker_id = sp.id
                                          LEFT JOIN event_sessions es ON es.id = esp.event_session_id
                                          LEFT JOIN events e ON e.id = es.event_id
                                          WHERE p.user_id ="+@user.id.to_s+"
                                          ORDER BY e.start_time DESC limit 2"]
       @followed_icon_users = @user.followed_users.profile_complished.limit(2)     
      end
  end

  def user_layout
    @user.is_industry_icon? ? 'client/speaker' : "client/public"
  end

  # for authlogic
  
  def set_current_user
    Authorization.current_user = current_user
  end

  def permission_denied
    flash[:error] = "Sorry, you are not allowed to access that page."
    redirect_to login_url
  end


  def valid_code?(code)
    return true if session[:proof_image] && session[:proof_image][:text] == code
    @valid_code_error = flash[:valid_code_error] = "验证码错误"
    
    return false
  end





private
  def current_user_session
    return @current_user_session if defined?(@current_user_session)
    @current_user_session = UserSession.find
  end

  def current_user
    return @current_user if defined?(@current_user)
    @current_user = current_user_session && current_user_session.user
  end
  
  def set_locale
    FastGettext.locale = session[:locale] || 'zh_CN'
    I18n.locale = session[:locale] || "zh_CN"
  end


  def with_format(format, &block)
    old_formats = formats
    self.formats = [format]
    block.call
    self.formats = old_formats
    nil
  end



end
