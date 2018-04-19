# 提现审核处理相关操作接口
class Admin::Trade::WithdrawsController < Admin::ApplicationController
  before_action :set_withdraw, only: [:show]
  
  def index
    withdraws = ::Trade::Withdraw.by_state(params[:state])
                  .by_type(params[:type])
                  .includes(target: [:account, :bank])
    withdraws = withdraws.like_search(params[:user_name], {attributes: ["user_name"]}) if params[:user_name].present?
    withdraws = withdraws.page(params[:page]).per(params[:per_page])
    render json: {withdraws: withdraws, meta: meta_attributes(withdraws)}
  end
  
  def show
    render json: @withdraw
  end
  
  def pass
    pass_deal(params[:id], 1, 0)
  end
  
  def success
    pass_deal(params[:id], 2, 1)
  end
  
  def refuse
    refuse_deal(params[:id], -1, 0, params[:reason], 5, '审核拒绝')
  end
  
  def fail
    refuse_deal(params[:id], -2, 1, params[:reason], 6, '提现失败')
  end
  
  def export_csv
    withdraws = ::Trade::Withdraw.includes(target: [:account])
    withdraws = params[:ids].blank? ? withdraws.all : withdraws.where(id: params[:ids])
    
    csv_data = "\xEF\xBB\xBF" << export_csv_data(withdraws)
    
    respond_to do |format|
      format.json { render json: {csv_data: csv_data, name: "提现记录-#{Date.current}.csv"} }
      format.all { send_data csv_data, filename: "提现记录-#{Date.current}.csv" }
    end
  end
  
  private
  
  def deal_request
    flag = database_transaction do
      yield
    end
    if flag
      render json: {status: 200, msg: '处理成功'}
    else
      api_error(status: 422, error: "数据不存在或已经处理")
    end
  end
  
  def pass_deal(id, state, state_before)
    deal_request do
      withdraw = ::Trade::Withdraw.lock.find_by(id: id, state: state_before)
      withdraw.update(state: state)

      # 提现通知用户
      attrs = {title: '富熊源创', content: '您的提现成功，请点击查看', optype: 10}
      Core::Notification.send_withdraw_by_user(withdraw.target_id, {parameters: attrs.merge({page: 'Withdraws'})}.merge(attrs))
    end
  end
  
  def refuse_deal(id, state, state_before, reason, optype, description)
    deal_request do
      @withdraw = ::Trade::Withdraw.lock.find_by(id: params[:id], state: state_before)
      @withdraw.update(state: state, refuse_reason: params[:reason])
      @withdraw.target.withdraw_refuse!(@withdraw.amount, 5, '审核拒绝')
      
      # 提现通知用户
      content = @withdraw.state == -1 ? '您的提现审核已被拒绝，请点击查看' : '您的提现申请已失败，请点击查看'
      attrs   = {title: '富熊源创', content: content, reason: reason, optype: 10}
      Core::Notification.send_withdraw_by_user(user, {parameters: attrs.merge({page: 'Withdraws'})}.merge(attrs))
    end
  end
  
  def set_withdraw
    @withdraw = ::Trade::Withdraw.find(params[:id]) rescue nil
    api_error(status: 404, error: "数据不存在") unless @withdraw
  end
  
  # encoding: 'GB18030'
  def export_csv_data(withdraws, encoding = 'UTF-8')
    ::CSV.generate(encoding: encoding) do |csv|
      csv << %w[ID 提现用户类型 提现时间 手机 姓名 开户行账号	 开户名称 提现金额 提现状态]
      
      withdraws.each do |withdraw|
        csv << [
          withdraw.id,
          withdraw.user_type,
          withdraw.created_at.strftime('%F %T'),
          withdraw.target.phone,
          withdraw.user_name,
          "\t#{withdraw.bank_account}",
          withdraw.bank_name,
          withdraw.amount,
          withdraw.status
        ]
      end
    end
  end

end
