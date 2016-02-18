class Pinganbeijing::ForwardsController < Pinganbeijing::ApplicationController
  layout "client"

  def index
    compute_summary
    @forwards = WeiboForward.where("uid = ?",@uid)
    @forwards = @forwards.where("forward_at between ? and ?",Date.yesterday, Date.today)
    @forwards = @forwards.order("forward_at desc").paginate(:page=>params[:page],:per_page=>20)
  end
end
