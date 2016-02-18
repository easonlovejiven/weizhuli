# -*- encoding : utf-8 -*-
class Client::UsersController < Client::ApplicationController

  layout  'client/user'
  before_filter :right_users_recommend

  def index

    if request.xhr?
      @users = User.ts_search(params[:q]+"*", :per_page=>30)
    else
      #search industry users begin
      @hot_industry_users = []
      @industry_tags = []
      industries = Industry.includes(:business_cards).group("industries.id").order("COUNT( industries.id ) DESC").where("business_cards.industry_id IS NOT NULL")
      industries.each do |industry|
			  industry_users = []
			  industry_users = User.profile_complished.actived.has_avatar.belongs_industry(industry.id).limit(4)
			  @industry_tags << Industry.find(industry.id)
			  if industry_users.size < 4
          industry_users += User.profile_complished.actived.belongs_industry(industry.id).limit(10-industry_users.size)
        end
        industry_users = industry_users.uniq_by {|user| user.id} 
		    @hot_industry_users << industry_users
	    end
	    #search industry users end
      @user_tags = Tag.get_tags_by_content(BusinessCard,:limit=>21)
	    @hot_events = []
	    hot_events = Event.includes(:event_follows).group("event_follows.event_id").order("COUNT( event_follows.event_id ) DESC").limit(6)
	    hot_events.each do |event|
        @hot_events << Event.find(event.id)
      end

    end
    respond_to do |format|
      format.html
      format.json{
        render  :json=>@users.to_json(:only=>[:id], :methods=>[:displayable_name])
      }
    end
     @html_title = _("用户广场")
  end

  def activities
    @user_tags = Tag.get_tags_by_content(BusinessCard,:limit=>21)
    @activity = Activity.new
    scope = Activity.grouped.filter_card_active.includes(:links)
    scope = scope.after(Time.at(params[:t].to_i)).where(["activities.user_id != ?",current_user.id]) if !params[:t].blank?
    @activities = scope.
                    order("activities.id desc").
                    paginate(:page=>params[:page],:per_page=>20)
    @industry_tags = []
    industries = Industry.includes(:business_cards).group("industries.id").order("COUNT( industries.id ) DESC").where("business_cards.industry_id IS NOT NULL")
    industries.each do |industry|
			  @industry_tags << Industry.find(industry.id)
	  end
    @html_title = _("用户动态")
  end

  def list
    search = params[:search]
    if search.blank?
      @users = User.profile_complished.actived.includes([:profiles,:avatar,{:business_card=>:locales}]).order('users.id desc').paginate(:page=>params[:page],:per_page=>20)
      @industry_groups = User.profile_complished.actived.includes([:profiles,:avatar,{:business_card=>:locales}]).order('users.id desc')
    else
      @users = User.ts_search((search[:key].blank? ? nil : search[:key]+"*"),:conditions=>search[:conditions],:with=>search[:with], :page=>params[:page], :per_page=>20)
      @industry_groups = User.profile_complished.actived.includes([:profiles,:avatar,{:business_card=>:locales}]).order('users.id desc').ts_search((search[:key].blank? ? nil : search[:key]+"*"),:conditions=>search[:conditions],:with=>search[:with], :group_by=>"industry_id", :group_function => :attr)
    end
    @html_title = _("用户列表")
  end
  
  
  protected
  
  def right_users_recommend
      # industry select list
      @industries_h = Industry.order("weight").map{|x| {:id => x.id, :industry_name => x.name, :industry_followed => x.followed} }
      #recommend user and no exchange card with me
      @user_infomation = User.profile_complished.actived.includes([:profiles,:avatar,{:business_card=>:locales}]).no_exchange_cards(current_user).has_avatar
      @icon_users = @user_infomation.role_eq("industry_icon").order("users.created_at desc").limit(4)
      @latest_users = @user_infomation.role_noteq("industry_icon").order("users.created_at desc").limit(4)
  end


end

