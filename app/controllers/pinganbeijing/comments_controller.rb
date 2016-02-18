class Pinganbeijing::CommentsController < Pinganbeijing::ApplicationController
  layout "client"

  def index
    compute_summary
    @comments = WeiboComment.where("uid = ?",@uid)
    @comments = @comments.where("comment_at between ? and ?",Date.yesterday, Date.today)
    @comments = @comments.order("comment_at desc").paginate(:page=>params[:page],:per_page=>20)
  end
end
