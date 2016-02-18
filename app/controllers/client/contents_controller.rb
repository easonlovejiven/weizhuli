class Client::ContentsController < Client::ApplicationController

  layout "client"
  def index


    @all_uids = {
        "2637370927"=>[2637370927,2637370247],
        "2295615873"=>[1721371132, 2192146241, 1408734653, 1586108233, 1642330703, 1644957487, 1406438584, 1481944214, 1648587064, 1244942385, 1931274014, 1052937860, 2208679277, 1657809832, 1494759712, 1422007951, 1541603965, 2074647471, 1400664642, 1764935500, 1900713001, 1988124285, 1644275102, 1497016407, 1495491885, 2498606105, 1689783023, 2251752833, 1415569554, 1179327887, 1285452502, 1841859455, 1618379060, 1941203001, 1646434045, 1649162343, 1655031725, 2410770103, 1401800753, 1210544092, 1856149323, 1968866921, 1784489563, 1496874104, 1711479641, 1424710994, 1298064414, 1642482194, 1662047260, 1728892794, 1642540892, 2126884617, 2841727664],
    }


    @mod = params[:mod]



    if @mod.nil?
        if @uid == "2637370927"
            render_intel_contents
        else
            render_posts
        end
    else
        render_stats
    end



  end


  def render_intel_contents
    uids = @all_uids[@uid]

    @accounts = WeiboAccount.where(uid:uids)

    @contents = MIntelContent.order(:mid=>:desc)
    @q = params[:search] || {}
    @contents = @contents.where(:interactions.gte=>@q[:interaction_egt].to_i) if @q[:interaction_egt].present?
    @contents = @contents.where(uid:@q[:uid].to_i) if @q[:uid].present?
    @contents = @contents.where(:post_at.gt=>Date.parse(@q[:start_time]).to_mongo) if @q[:start_time].present?
    @contents = @contents.where(:post_at.lte=>Date.parse(@q[:end_time]).to_mongo) if @q[:end_time].present?
    @contents = @contents.where(:is_image => true) if @q[:content_type] == 'image'
    @contents = @contents.where(:is_video => true) if @q[:content_type] == 'video'
    @contents = @contents.where(text:Regexp.new(@q[:keyword])) if @q[:keyword].present?
    @contents = @contents.where(tag1:@q[:tag1]) if @q[:tag1].present?
    @contents = @contents.where(tag2:@q[:tag2]) if @q[:tag2].present?
    @contents = @contents.where(tag3:@q[:tag3]) if @q[:tag3].present?
    @contents = @contents.where(tag4:@q[:tag4]) if @q[:tag4].present?
    @contents = @contents.where(tag5:@q[:tag5]) if @q[:tag5].present?
    @contents = @contents.where(tag6:@q[:tag6]) if @q[:tag6].present?
    @contents = @contents.paginate(page:params[:page],:per_page=>10)

    render :action=>"intel_contents"
  end

  def render_posts
        uids = @all_uids[@uid]



        @q = params[:search] || {}
        @accounts = WeiboAccount.where(uid:uids)

        uids = [@q[:uid]] if @q[:uid].present?
        m_posts_id = nil
        if @q[:keyword].present?
          keyword = Regexp.new(@q[:keyword])
          m_posts_id = MWeiboContent.where(text:keyword,uid:uids).map(&:id)
        end
        @posts = WeiboDetail.origins.where(uid:uids)
        @posts = @posts.where("reposts_count+comments_count > ?",@q[:interaction_egt]) if @q[:interaction_egt].present?
        @posts = @posts.where("post_at > ?", @q[:start_time]) if @q[:start_time].present?
        @posts = @posts.where("post_at <= ?", @q[:end_time]) if @q[:end_time].present?
        @posts = @posts.where("image = 1") if @q[:content_type] == 'image'
        @posts = @posts.where("video = 1") if @q[:content_type] == 'video'
        @posts = @posts.where("weibo_id in (?)",m_posts_id) if m_posts_id.present?


        sort_cols = {"interactions"=>"reposts_count+comments_count","post_at"=>"post_at"}
        @sort_col = params[:sort_col] || "post_at"
        @sort_type = params[:sort_type] || "0"
        operator = @sort_type == '1' ? "asc" : "desc"
        s = "#{sort_cols[@sort_col]} #{operator}"

        @posts = @posts.order(s).paginate(:page=>params[:page],:per_page=>20)

        render :action=>"posts"
  end



  def render_stats

    @q = {}
    # time range : this week, month, quarter

    @day_point = params[:point] ? Date.parse(params[:point]) : Date.today
    @year = @day_point.year
    @quarter = (@day_point.month - 1) / 3 + 1
    @quater_month = @day_point.month / 3 * 3 + 1
    @months = []
    0.upto(2){|i| @months << Date.new(@day_point.year, @quater_month,1)+i.month}


    start_date = Date.new(@day_point.year, @quater_month, 1)
    end_date = start_date + 3.month


    @prev_quarter = start_date - 3.month
    @next_quarter = start_date + 3.month
    @next_quarter = nil if @next_quarter > Date.today



    query = {:post_at.gte=>start_date.to_time.to_mongo,:post_at.lt=>end_date.to_time.to_mongo} #
    @contents = MIntelContent.order(:mid=>:desc).where(query).all
    render :action=>"stats"
  end


  def update
    @intel_content = MIntelContent.find(params[:id])
    if @intel_content.update_attributes(params[:content])
        render :json=>{status:"success", object:@intel_content}
    else
        render :json=>{status:"failed", errors:@intel_content.errors}
    end
  end
end
