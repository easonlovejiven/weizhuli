# -*- encoding : utf-8 -*-
class Pinganbeijing::ApplicationController < ActionController::Base
  protect_from_forgery

  include FastGettext::Translation

  helper  :all

  
  before_filter :set_locale # we do not need locale right now
  before_filter :set_current_user,  :set_user
  #before_filter :check_user_profile_status

  filter_access_to :all

  helper_method :current_user_session, :current_user

  protected



  def compute_summary
    @uid = 1288915263
    if @uid
      @last_account_snap = WeiboAccountSnapDaily.where("uid = ?",@uid).last
      @last_content_snap = WeiboContentCountSnapDaily.where("uid = ?",@uid).last

      # @last_account_snap = nil if @last_account_snap && @last_account_snap.date < Date.yesterday
      # @last_content_snap = nil if @last_content_snap && @last_content_snap.date < Date.yesterday

      @interactions_count = nil
      @mentions_count = WeiboMention.where(uid:@uid).count
      
      if @last_account_snap
        @followers_count = @last_account_snap.followers_count
        @followers_increase = @last_account_snap.fans_increase || 0
        @new_followers_count = @last_account_snap.new_fans_count || 0
        @followers_decrease = @new_followers_count - @followers_increase
      end

      if @last_content_snap
        @statuses_count = @last_content_snap.statuses_count
        @yesterday_statuses_count = @last_content_snap.new_statuses_count
        @yesterday_origin_statuses_count = @last_content_snap.origin_count
        @yesterday_origin_statuses_ratio = @last_content_snap.new_statuses_count == 0 ? 0 : @last_content_snap.origin_count.to_f / @last_content_snap.new_statuses_count.to_f
        @forwards_count = @last_content_snap.be_forwarded_count
        @comments_count = @last_content_snap.be_commented_count

        @interactions_count =  @forwards_count + @comments_count


      end
    end
    
  end












  def set_current_user
    Authorization.current_user = current_user
  end

  def permission_denied
    flash[:error] = "Sorry, you are not allowed to access that page."
    if !request.xhr? && request.method == "GET"
      return_url = request.url
    elsif !request.env['HTTP_REFERER'].blank?
      url = URI.parse(request.env['HTTP_REFERER'])
      if (url.host == request.env['SERVER_NAME'] || url.host == request.env['HTTP_HOST'])
        if (!request.env['HTTP_REFERER'].blank?)  
          return_url = request.env['REQUEST_URI']
        else
          return_url = request.env['HTTP_REFERER']
        end
      
      else
        return_url = request.env['REQUEST_URI']
      end
    else
        return_url = ''  
    end
    redirect_to login_url(:return=>return_url)
  end


  def valid_code?(code)
    return true if session[:proof_image] && session[:proof_image][:text] == code
    @valid_code_error = flash[:valid_code_error] = "验证码错误"
    
    return false
  end


  def ajax_layout
    ((params[:f] == "ajax" || request.xhr?) ? "client/dialog" : true)
  end

  def set_user
    @user = current_user
    @uid = 1288915263
    if @user.authentications.weibo.first
      @uid = @user.authentications.weibo.first.uid
      @user_weibo = WeiboAccount.find_by_uid(@uid)
    end
  end






  def redirect_back(options = {})
    if request.env['HTTP_REFERER'].blank?
      redirect_to root_path, options
    else
      redirect_to :back, options
    end
  end




  # set source referer from params[:source] in session
  # when a user regist, use this source
  def set_source_referer
    if !params[:source].blank?
      session[:source] = params[:source]
    end
  end




  def set_prev_link(link, title)
    session[:last_link] = link
    session[:last_link_title] = title
  end


private

  def set_locale
    FastGettext.locale = ["zh_CN", "en"].delete(params[:l]) || session[:locale] || 'zh_CN'
    I18n.locale = ["zh_CN", "en"].delete(params[:l]) || session[:locale] || "zh_CN"
  end

  def current_user_session
    return @current_user_session if defined?(@current_user_session)
    @current_user_session = UserSession.find
  end

  def current_user
    return @current_user if defined?(@current_user)
    @current_user = current_user_session && current_user_session.user
  end

  def check_user_profile_status
    if !request.xhr? && current_user && !current_user.profile_complished? && controller_name != "guides"
      redirect_to full_profile_client_guides_path
      return false
    end
  end


end

