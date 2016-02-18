# -*- encoding : utf-8 -*-
# Filters added to this controller apply to all controllers in the application.
# Likewise, all the methods added will be available for all controllers.
class ApplicationController < ActionController::Base
  helper :all # include all helpers, all the time
  # protect_from_forgery # See ActionController::RequestForgeryProtection for details
  # Scrub sensitive parameters from your log
  # filter_parameter_logging :password

  include FastGettext::Translation

  # 在任何一个请求中, 如果 params 中有用户登录的参数, 就事先登录
  before_filter :in_time_login

  before_filter :set_locale
  before_filter :set_current_user
  before_filter :set_sources

  helper_method :current_user_session, :current_user

 # before_filter :init_layout_variables

  protected

  def set_current_user
    Authorization.current_user = current_user
  end

  def permission_denied
    flash[:error] = "Sorry, you are not allowed to access that page."
    redirect_to login_url(:return=>request.env['HTTP_REFERER'])
  end


  def valid_code?(code)
    return true if session[:proof_image] && session[:proof_image][:text] == code
    @valid_code_error = flash[:valid_code_error] = "验证码错误"
    return false
  end




  #### 从 cookies 里检测12小时内是否查看过  
  # cookies : http://stackoverflow.com/questions/1232174/rails-cookies-set-start-date-and-expire-date
  def check_accessed_from_cookies(name_space,id,expire = 12.hour.from_now, &block)
    c_name = "#{name_space}_#{id}".to_sym
    yield if cookies[c_name].blank?
    cookies[c_name] = { :value => "true", :expires => expire}
  end


  def redirect_back(options = {})
    if request.env['HTTP_REFERER'].blank?
      redirect_to root_path, options
    else
      redirect_to :back, options
    end
  end


private

  def set_locale
    FastGettext.text_domain = "weibo-marketing"
    FastGettext.locale = ["zh_CN", "en"].delete(params[:l]) || session[:locale] || 'zh_CN'
    I18n.locale = ["zh_CN", "en"].delete(params[:l]) || session[:locale] || "zh_CN"
  end


  # 在任何一个请求中, 如果 params 中有用户登录的参数, 就事先登录
  def in_time_login
    if params[:user_session]
      @user_session = UserSession.new(params[:user_session])
      @user_session.save
    end
    return true
  end


  def current_user_session
    return @current_user_session if defined?(@current_user_session)
    @current_user_session = UserSession.find
  end

  def current_user
    return @current_user if defined?(@current_user)
    @current_user = current_user_session && current_user_session.user
  end

  def set_sources
    # discount code
    if !params[:dc].blank?
      session[:discount_code] = params[:dc]
    end
  end

end
