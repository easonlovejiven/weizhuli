# -*- encoding : utf-8 -*-
class User::UserController < User::ApplicationController

  layout :user_layout

  def index
    @activities = @user.activities.grouped.includes(:links).order("id desc").limit(10)
    @events = @user.events.available.order("start_time desc").limit(2)
    @icon_updates = @user.icon_updates.order("date desc").limit(10)               
    @html_title = _("公共主页")

    respond_to  {|format|
    
      format.html
      
      format.json{
        # with_format see controller : user/application.rb
        with_format :html do
          json = @user.to_json(:hash=>{:card_html=>render_to_string(:partial=>"/client/common/follow_user_card.html", :locals=>{:user=>@user})})
          render  :json=> json
        end
      }
    
    }
    
  end
  
end
