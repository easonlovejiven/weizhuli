# -*- encoding : utf-8 -*-
class Admin::ApplicationController < ActionController::Base
  layout 'admin'

  include FastGettext::Translation
  before_filter :set_locale

  before_filter :set_current_user

  helper_method :current_user_session, :current_user

  filter_access_to :all
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
    @valid_code_error = flash[:valid_code_error] = "Validation code error."
    
    return false
  end


  def redirect_back(options = {})
    if request.env['HTTP_REFERER'].blank?
      redirect_to root_path, options
    else
      redirect_to :back, options
    end
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
    FastGettext.locale = ["zh_CN", "en"].delete(params[:l]) || session[:locale] || 'zh_CN'
    I18n.locale = ["zh_CN", "en"].delete(params[:l]) || session[:locale] || "zh_CN"
  end



end
