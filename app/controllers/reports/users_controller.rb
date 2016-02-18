# -*- encoding : utf-8 -*-
class Reports::UsersController < Reports::ApplicationController

  layout "mobile"

  # 用户点击了 注册 链接时
  # 如果 是从微信点击, 参数应该有 openid 
  def new
    weixin_openid = params[:weixin_openid]


    # 微信界面
    if false   #weixin_openid.present?

      # # 不需要注册 用户的情况
      # #   直接 创建 用户, 跳转到微博绑定页面
      # session[:weixin_openid] = weixin_openid


      # # check user profile by weixin_openid
      # user_profile = UserProfile.find_by_weixin_openid(weixin_openid)
      # if user_profile
      #   @user = user_profile.user
      #   @user_session = UserSession.create(@user)
      #   #render :text=>"用户已经注册过了"

      #   # 如果还没有授权过
      #   if @user.authentications.weibo.blank?
      #     # 转向授权页面
      #     redirect_to auth_path(:weibo,return:reports_create_authentications_path)
      #   else
      #     # 否则转向日报页面
      #     redirect_to reports_dailies_path
      #   end

      # else
      #   @user = User.create(:login=>"weixin_#{weixin_openid}",:status=>1, :password=>"123123", :password_confirmation=>"123123", :email=>"unknow",
      #         profile_attributes:{weixin_openid:weixin_openid}
      #     )
      #   @user.roles << Role.find_by_name("report_client")
      #   @user_session = UserSession.create(@user)
      #   redirect_to auth_path(:weibo,return:reports_create_authentications_path,display:'mobile',forcelogin:true)
      # end
    else

      # 
      # 显示注册界面

      session[:weixin_openid] = weixin_openid


      # check user profile by weixin_openid
      user_profile = UserProfile.find_by_weixin_openid(weixin_openid)
      if user_profile
        @user = user_profile.user
        @user_session = UserSession.create(@user)
        #render :text=>"用户已经注册过了"

        # 可以绑定多个微博， 总是增加新的授权
        if true || @user.authentications.weibo.blank?
          # 转向授权页面
          redirect_to auth_path(:weibo,return:reports_create_authentications_path,display:'mobile',forcelogin:true)
        else
          # 否则转向日报页面
          redirect_to reports_dailies_path
        end

      else
        @user = User.new(:login=>"weixin_#{weixin_openid}")
        @user.build_profile


      end

    end


  end
  
  def create
    @user = User.new(params[:user])
    @user.status = 1
    @user.password = '123123'
    @user.password_confirmation = '123123'
    @user.profile.weixin_openid = session[:weixin_openid]
    @user.valid_sms_code = true
    @user.sms_code = params[:sms_code]

    if @user.save
      @user.roles << Role.find_by_name("report_client")
      @user_session = UserSession.create(@user)

      redirect_to auth_path(:weibo,return:reports_create_authentications_path)
    else
      render :action=>"new"
    end
  end
  

  def agreements
  end

end
