# -*- encoding : utf-8 -*-
class GeneralController < ApplicationController

  layout 'frontend'

  def index
      @html_title = _('首页')
      @user_session = UserSession.new

  end
  
  # 浏览
  def browse
    sms = Sms.new

    mobile = params[:m] || "18600578412"
    text = params[:t] || "微博互动频率提醒：微博互动达到 警告 !!! 【微助力】"

    sms.send_sms mobile, text
    render :text=>"ok"
  end
  
  def browse2
    
  end

  def order
      @html_title = ""
  end
  
  def method_name
    
  end
  
  def contact
      @html_title = ""
      @old_css =true # use the old css before we get new pages
  end
  
  
  def about_us
      @html_title = ""
      @old_css =true
  end
  
  
  def faq
      @html_title = ""
      @old_css =true
  end
  
  
  def help
  #  render  :partial=>"client/common/buy_now"
		render	:action=>"help_"+I18n.locale.to_s
  end
  
  def agreement_basic
    
  end


  def proof_image
    proof_image = ProofImage.new
    session[:proof_image] ||= {}
    # session[:proof_image][:image]= proof_image.image
    session[:proof_image][:text]= proof_image.text
    send_data proof_image.image, :type => 'image/jpeg', :disposition => 'inline'
  end


  def language
    session[:locale] = params[:id]
    
    if request.xhr?
      render  :update do |f|
        f.redirect_to request.env['HTTP_REFERER']
      end
    else
      redirect_back
    end
    current_user.property.update_attribute(:language, session[:locale]) if current_user
  end



  def omniauth
    session[:omniauth_return_path] = params.delete :return
    redirect_to "/auth/#{params[:provider]}?#{params.to_query}"
    #redirect_to create_authentications_path(:test=>"haha")
  end


  def omniauth_callback
    # session[:omniauth_return_path] 用于 auth 回直接 跳转
    # session[:auth_return_url] 用于 AuthenticationsController#create 后跳转
    return_to = session[:omniauth_return_path]
    return_to = create_authentications_path if return_to.blank?
    session["omniauth.auth"] = request.env["omniauth.auth"]
    redirect_to return_to+"?"+params.to_params
  end




  def weibo_user_keywords
    @name = params[:screen_name]
    if @name
      @uid = ReportUtils.names_to_uids([@name],true).first
      if @uid
        @res = Net::HTTP.get URI.parse("http://www.tfengyun.com/user.php?action=keywords&userid=#{@uid}")
        @res = JSON.parse @res
      end
    end

    render :layout=>false
  end

end
