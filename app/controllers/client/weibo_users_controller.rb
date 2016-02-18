# -*- encoding : utf-8 -*-
class Client::WeiboUsersController < Client::ApplicationController

  layout "client"
  add_breadcrumb "Home", "/", title: "my link title"
  add_breadcrumb "粉丝管理", nil
  


  def index


    @mod = params[:mod]


    (charts; return) if @mod== 'charts'


    # before use mysearch, you must set WeiboHighLevelFans::current_uid && WeiboHighLevelFans::current_user_id
    WeiboHighLevelFans.current_uid = @uid
    WeiboHighLevelFans.current_user_id = current_user.id

    per_page = 50
    page = params[:page].to_i > 0 ? params[:page].to_i : 1
    offset = (page - 1) * per_page
    @q = params[:search] || {}
    # search method is customized method in WeiboHighLevelFans
    @rels = WeiboHighLevelFans.mysearch(@q).includes(:by_user).where(uid:@uid).
      where('level = ?', @mod== 'kol' ? 1 : 2)


    # sorting
    sort_cols = {"follow_time"=>"follow_time", "total_interactions"=>"total_interactions"}
    @sort_col = params[:sort_col] || "follow_time"
    @sort_type = params[:sort_type] || "0"
    operator = @sort_type == '1' ? "asc" : "desc"
    s = "#{sort_cols[@sort_col]} #{operator}"

    @rels = @rels.order(s)






    @next_page = @rels.offset(offset + per_page).limit(1).count > 0 ? page +1 : nil
    @prev_page = page > 1 ? page - 1 : nil

    @rels = @rels.offset(offset).limit(50) #paginate(:per_page=>50,:page=>params[:page])
    uids = @rels.map(&:by_uid)

    @remarks = {}
    WeiboUserRemark.includes(:group).where(user_id:current_user.id,uid:uids).each{|remark|
      @remarks[remark.uid] = remark
    }

    # @interactions = {}
    # WeiboUserInteractionSnapDaily.where("date between ? and ?",Date.today-30.day, Date.tomorrow).
    #   where(uid:@uid, from_uid:uids).group("from_uid").select("from_uid, sum(interacted_count) interacted_count").each{|inc|

    #   @interactions[inc.from_uid] = inc
    # }
  end


  def update
  end
  

  def charts
    @level1_fans_stats = IntelHighLevelFansStats.where(uid:@uid,category:IntelHighLevelFansStats::CATEGORY_KOLS).
      where("date between ? and ?", Date.today-6.month, Date.today).order("id asc")
    @level2_fans_stats = IntelHighLevelFansStats.where(uid:@uid,category:IntelHighLevelFansStats::CATEGORY_HIGH_LEVEL_FANS).
      where("date between ? and ?", Date.today-6.month, Date.today).order("id asc")
    @kol_interaction_stats = IntelHighLevelFansStats.where(uid:@uid,category:IntelHighLevelFansStats::CATEGORY_KOLS_AVERAGE_INTERACTION).
      where("date between ? and ?", Date.today-6.month, Date.today).order("id asc")
    @high_level_interaction_stats = IntelHighLevelFansStats.where(uid:@uid,category:IntelHighLevelFansStats::CATEGORY_HIGH_LEVEL_FANS_AVERAGE_INTERACTION).
      where("date between ? and ?", Date.today-6.month, Date.today).order("id asc")

    render :action=>'charts'
  end
end


