# -*- encoding : utf-8 -*-
class Admin::UsersController < Admin::ApplicationController
  layout "admin"
  def index
    @users = User.includes([:profiles, :roles]).search(params[:search]).order("users.id desc").paginate(:page=>params[:page], :per_page=>20)
  end
  def show
    @user = User.find(params[:id])
  end
  def edit
    @user = User.find(params[:id])
  end

  def update
    @user = User.find(params[:id])
    @user.update_attributes(params[:user])
    redirect_to admin_user_path(@user)
  end

  def destroy
    @user = User.find(params[:id])
    @user.destroy
    redirect_to(admin_users_url)
  end

  def new
    @user = User.new
  end


  # modify user roles
  def change_roles
    @user = User.find(params[:id])
  end

  def create_speaker
    user = User.find(params[:id])
    person = Person.new(:gender => user.business_card.gender)
    user.business_card.locales.each do |card|
      if card.locale == "en"
        first_name = card.first_name
        last_name =   card.last_name
      else
        first_name = card.name.first
        last_name = card.name[0,200]
      end
      person.locales << PersonLocale.new(
        :locale => card.locale,
        :biography => user.profiles.where(:locale=>card.locale).first.description,
        :first_name => first_name,
        :last_name => last_name
      )
    end
    user.person = person
    speaker = Speaker.new(:weight=>0)
    person.speaker = speaker
    if user.person.errors.blank? && user.save!
      flash[:notice] =  _("操作成功，此用户已成为演讲嘉宾")
      redirect_to admin_users_path
    else
      flash[:error] = _("出错了！检查用户信息是否完整（如：性别，姓名等）")
      redirect_to admin_users_path
    end
  end

  def remove_speaker
    user = User.find(params[:id])
    if user.person.destroy
      flash[:notice] =  _("操作成功，此用户已变为普通用户")
      redirect_to admin_users_path
    else
      flash[:error] =  _("出错了！请联系管理员")
      redirect_to admin_users_path
    end
  end

end

