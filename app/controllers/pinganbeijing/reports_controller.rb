class Pinganbeijing::ReportsController < Pinganbeijing::ApplicationController

  layout "client"

  def index
    compute_summary

    # @account_snaps = WeiboAccountSnapDaily.where(uid:@uid).where("date > ? ", Date.today-7.day).order("date asc").all
    # @content_snaps = WeiboContentCountSnapDaily.where(uid:@uid).where("date > ? ", Date.today-7.day).order("date asc").all

    @account_snaps = WeiboAccountSnapDaily.where(uid:@uid).order("date desc").limit(7).all.sort{1}
    @content_snaps = WeiboContentCountSnapDaily.where(uid:@uid).order("date desc").limit(7).all.sort{1}
  end
end
