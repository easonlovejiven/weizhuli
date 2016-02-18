# -*- encoding : utf-8 -*-
class Client::WeiboSpreadsController < Client::ApplicationController
  layout "client"
  add_breadcrumb "Home", "/", title: "Home"
  add_breadcrumb "微博传播分析", nil
  

  def index

    @url = params[:url]


    if @url.present?
      show
    end
  end



  def show
    @url = params[:url]
    str = URI.parse(@url).path.split("/").last
    @weibo_id = WeiboMidUtil.str_to_mid(str)
    @weibo_detail = WeiboDetail.find_by_weibo_id @weibo_id
    if @weibo_detail.nil?
      render :action=>:index
    else
      @pure_forward_users = WeiboForward.find_by_sql("select count(distinct forward_uid) counts from weibo_forwards where weibo_id = #{@weibo_id}").first.counts
      render :action=>:show
    end
  end



  def status
  end

  def tree
    weibo_id= params[:weibo_id]
  end


  # 用于页面第一次查询 gexf 的状态，成功则返回 gexf ID，不成功间隔时间后重试
  def get_gexf_url
    weibo_id = params[:id]
    task = MForwardSpreadTask.where(weibo_id:weibo_id.to_i).first
    task = MForwardSpreadTask.create(weibo_id:weibo_id,status:0) if task.nil?
    (task.update_attribute(:status,0) ; task.create_task) if task.updated_at < Time.now - 12.hour

    if task.status == 1
      # 成功后 , 页面 js 直接抓取 /weibo_spreads/***.gexf
      render :json=>{status:"success"}
    else
      render :json=>{status:"waiting"}
    end

  end

end




