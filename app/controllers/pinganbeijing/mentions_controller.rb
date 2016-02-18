class Pinganbeijing::MentionsController < Pinganbeijing::ApplicationController

  layout "client"

  def index


    @mod = params[:mod]

    @date_start = params[:start_date] || Date.yesterday
    @date_end = params[:end_date] || Date.yesterday



    if @mod == "interactions"
      @weibo_id = params[:weibo_id]
      @user_type = params[:user_type]
      @user_group = params[:user_group]




      if @weibo_id
        if params[:data_type] == "forwards"
          @forwards = WeiboForward.where(weibo_id:params[:weibo_id]).includes(:forward_user)
          @forwards = @forwards.where("weibo_accounts.verified_type >= 0") if @user_type == "verified"
          @forwards = @forwards.where("weibo_accounts.verified_type = 3") if @user_type == "media"
          @forwards = @forwards.where("weibo_accounts.verified_type = 4") if @user_type == "site"
          @forwards = @forwards.where("weibo_forwards.forward_uid in (?)",PinganbeijingAccountsLog::UIDS['1']+PinganbeijingAccountsLog::UIDS['2']) if @user_group == "company"
          @forwards = @forwards.where("weibo_forwards.forward_uid in (?)",PinganbeijingAccountsLog::UIDS['3']+PinganbeijingAccountsLog::UIDS['4']) if @user_group == "person"
          @forwards = @forwards.where("weibo_forwards.forward_uid in (?)",MPinganbeijingInternalMonitAccount::UIDS['1']) if @user_group == "internal"

          @forwards = @forwards.page(params[:page]).per_page(10) #paginate(:page=>params[:page], :per_page=>10)
          # @forwards = @forwards.map{|forward|
          #   forward
          # }.compact

          # @forwards = Kaminari.paginate_array(@forwards).page(params[:page]).per(10)
        end
        if params[:data_type] == "comments"
          @comments = WeiboComment.where(weibo_id:params[:weibo_id]).includes(:comment_user)

          @comments = @comments.where("weibo_accounts.verified_type >= 0") if @user_type == "verified"
          @comments = @comments.where("weibo_accounts.verified_type = 3") if @user_type == "media"
          @comments = @comments.where("weibo_accounts.verified_type = 4") if @user_type == "site"
          @comments = @comments.where("weibo_comments.forward_uid in (?)",PinganbeijingAccountsLog::UIDS['1']+PinganbeijingAccountsLog::UIDS['2']) if @user_group == "company"
          @comments = @comments.where("weibo_comments.forward_uid in (?)",PinganbeijingAccountsLog::UIDS['3']+PinganbeijingAccountsLog::UIDS['4']) if @user_group == "person"
          @comments = @comments.where("weibo_comments.forward_uid in (?)",MPinganbeijingInternalMonitAccount::UIDS['1']) if @user_group == "internal"

          @comments = @comments.page(params[:page]).per_page(10) #paginate(:page=>params[:page], :per_page=>10)
          # @comments = @comments.map{|comment|
          #   comment
          # }.compact

          # @comments = Kaminari.paginate_array(@comments).page(params[:page]).per(10)

        end
        render :partial=>params[:data_type]
      else
        @weibos = WeiboDetail.where(uid:1288915263).where("post_at between ? and ?+interval 1 day",@date_start, @date_end).order("weibo_id desc")
      end
    elsif @mod == "over_forward"


      @forward_weibo_id = params[:weibo_id]


      if @forward_weibo_id

        @mentions = WeiboMention.where(uid:@uid, forward_weibo_id:@forward_weibo_id).where("mention_at between ? and ?+interval 1 day",@date_start,@date_end).order("id desc").page(params[:page]).per_page(10)
        render :partial=>"mention_forwards"
      else
        # 转发
        @q = params[:search] || {}

        @q["over_forward"] = true

        @serch_key = params[:q]

        @mention_uid = params[:uid]

        @mentions = WeiboMention.mysearch(@q).where(uid:@uid).where("mention_at between ? and ?+interval 1 day",@date_start,@date_end).order("count(1) desc").group("forward_weibo_id").select("mention_id,forward_weibo_id,count(1) total").limit(50)
        @mms = {}
        MMention.find(@mentions.map(&:mention_id)).each{|mm|@mms[mm.id] = mm}

      end


    else
      # 直发
      @q = params[:search] || {}
      @weibo_id = params[:weibo_id]


      if @weibo_id



        task = GetUserTagsTask.new

        @page = params[:page] || 1
        @per_page = 20

        @pager = nil
        if params[:data_type] == "forwards"
          @forwards = task.api.statuses.repost_timeline(@weibo_id,{page:@page,count:@per_page})
          @total = (@forwards.total_number || 0) > 2000 ? 2000 : @forwards.total_number
        end
        if params[:data_type] == "comments"
          @comments = task.api.comments.show(@weibo_id,{page:@page,count:@per_page})
          @total = (@comments.total_number || 0) > 2000 ? 2000 : @comments.total_number
        end

        @pager = Kaminari.paginate_array((1..@total).to_a).page(params[:page]).per(@per_page)
        render :partial=>"online_"+params[:data_type]
      else

        @serch_key = params[:q]

        @mention_uid = params[:uid]
        if @serch_key.present?
          keyword = Regexp.new(@serch_key)
          m_mentions_id = MMention.where(text:keyword,to_user_id:@uid.to_i).map(&:id)
          @q["mention_id"] = m_mentions_id
        elsif @mention_uid.present?
          @mention_user = WeiboAccount.find_by_uid @mention_uid
          @q["mention_uid"] = @mention_uid
        end
        @mentions = WeiboMention.mysearch(@q).where(uid:@uid).where("mention_at between ? and ?+interval 1 day",@date_start, @date_end).order("mention_id desc").paginate(page:params[:page],per_page:20)

      end


    end


  end
  
end
