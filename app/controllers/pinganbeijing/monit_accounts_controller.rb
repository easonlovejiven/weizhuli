class Pinganbeijing::MonitAccountsController < ApplicationController
  layout "client"

  before_filter :set_monit_account, :set_site

  def index
    @monit_accounts = MPinganbeijingOtherMonitAccount.where(site:@site).order(:date=>1).paginate(:per_page=>20,:page=>params[:page])
  end

  def new
    @monit_account = MPinganbeijingOtherMonitAccount.new
    @monit_account.date = Date.yesterday
    @monit_account.site = @site
  end

  def create
    @monit_account = MPinganbeijingOtherMonitAccount.new(params[:m_pinganbeijing_other_monit_account])
    if @monit_account.save
      redirect_to pinganbeijing_monit_accounts_path(site:@site)
    else
      render  :action=>:new
    end
  end

  def show
  end

  def edit
  end

  def update
    @monit_account.update_attributes(params[:m_pinganbeijing_other_monit_account])
    redirect_to pinganbeijing_monit_accounts_path(site:@site)
  end

  def destroy
    @monit_account.destroy
    redirect_to pinganbeijing_monit_accounts_path(site:@site)
  end

private

  def set_monit_account
    @monit_account = MPinganbeijingOtherMonitAccount.find_by_id(params[:id]) if params[:id].present?
  end

  def set_site
    @site = params[:site]
    @site = @monit_account.site if @site.blank? && @monit_account
    @site = "sohu" if @site.blank?
  end

end
