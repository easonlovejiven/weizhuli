# -*- encoding : utf-8 -*-

class PayController < ApplicationController
  
  layout  "frontend"
  
  PAY_TYPE={
    "1"=>100,
    "2"=>300,
    "3"=>500,
  }
  
  PAY_TYPE_MAP={
    '100'=>140,
    '300'=>500,
    '500'=>1240,
  }
  
  PAY_ERRORS = {
    '102' => "订单号重复",
    '104' => "序列号，密码简单验证失败",
    '105' => "密码正在处理中",
    '106' => "系统繁忙，暂停提交",
    '107' => "多次支付时卡内余额不足",
  }
  
  
  PAY_METHOD_MAP = {
    'alipay' => "alipay",
    'telephone_card' => "telephone_card",
    'wire' => "wire",
  }
  
  
  
  def new
    @order = Order.find params[:order_id]
  end
  
  
  def create
    @order = Order.find params[:order_id]
    #amount = params[:amount]
    amount = @order.need_pay
    pay_method = params[:pay_method]
    payment = Payment.create(:order=>@order, :amount=>amount, :payment_type=>pay_method, :status=>Payment::STATUS_NEW)
    
    respond_to do |format|

      case pay_method
        when "alipay" then
          format.html{redirect_to pays_alipay_path(payment, :payBank=>params[:payBank])}
          format.json{render :json=>{:pay_url=>pays_alipay_path(payment, :payBank=>params[:payBank]), :payment_id=>payment.id}}
        when "paypal" then
          format.html{redirect_to pays_paypal_path(payment)}
          format.json{render :json=>{:pay_url=>pays_paypal_path(payment), :payment_id=>payment.id}}
      end

    end
      
    
  end



  def show
    @payment = Payment.find(params[:id])
    @order = @payment.order

    if @payment.successed?
      if current_user
#        render  :action=>:pay_successed
      else
        session[:last_order] = @order.id
      end

      case @order.class.to_s
      when "EventOrder"
        redirect_to client_event_order_complete_path(@order)
      when "ChargeOrder"
        redirect_to client_charge_order_complete_path(@order)
      end
    elsif @payment.failed?
      render  :action=>:pay_failed
    end
  end



  def update
    @payment = Payment.find params[:id]
    amount = params[:amount]
    pay_method = params[:pay_method]
    #payment = Payment.create(:order=>@order, :amount=>amount, :payment_type=>pay_method, :status=>Payment::STATUS_NEW)
    

    case pay_method
      when "alipay" then
        redirect_to pays_alipay_path(@payment, :payBank=>params[:payBank])
      when "paypal" then
        redirect_to pays_paypal_path(@payment)
    end

      
  end





    #### OLD CODES , DON'T USE #####


  def pay_method
    @type = params[:id]
  end
  
  def select_pay_method
    @type = params[:id]
    @method = PAY_METHOD_MAP[params[:method]]
    if @method.nil?
      redirect_to :action=>:pay_method,:id=>@type
    else
      ctr = "/pays/"+@method
      redirect_to :controller=>ctr,:action=>:pay_form,:id=>@type
    end
  end
  
  
  ##############
  # pay methods
  ##############

  def pay_form
    @pay_type=PAY_TYPE[params[:id]]
    @uid = generate_uuid
  end
  

  
  def pay_method_alipay
    
  end
  
  def pay_method_telephone_card
    @pay_type=PAY_TYPE[params[:id]]
    @uid = generate_uuid
  end
  
  
  def pre_pay
    @phone_number = params[:phoneNumber]
    @card_type = params[:cardTypeCombine]
    @card_number = params[:cardNumber]
    @card_passwd = params[:cardPasswd]
    @card_passwd_check = params[:cardPasswdCheck]
    @card_value = params[:cardValue]
    @pay_money = params[:cardValue]
    
    # validation
    
    @errors = []
    
    @uid = params[:uid]
    if @uid.blank?
      @errors << "您提交的数据非法"
    end
    if !@errors.blank?
      pay_form
      render :action=>:pay_form
      return
    end
    
    
    # check if the UUID exists. if exists, means user re-post the page.
    rec = Recharge.find_all_by_uid @uid
    if !rec.blank?
      @errors << "请忽重复提交订单"
    end

    if !@errors.blank?
      pay_form
      render :action=>:pay_form
      return
    end
    

    
    if @phone_number.blank?
      @errors << "手机号码不能为空"
    else
      if !(@phone_number =~ /^1\d{10}$/)
        @errors << "手机号码格式不正确"
      end
    end
    
    if @card_type.blank?
      @errors << "请选择充值卡类型"
    end
    if @card_number.blank?
      @errors << "充值卡号不能为空"
    end
    if @card_passwd.blank?
      @errors << "充值卡密码不能为空"
    end
    if @card_passwd_check.blank?
      @errors << "请输入确认密码"
    end
    
    if !(@card_passwd.blank? || @card_passwd_check.blank?) && @card_passwd != @card_passwd_check
      @errors << "两次输入的密码不一样,请确认并重新输入"
    end
    
    
    if @card_value.blank?
      @errors << "请选择充值卡面值"
    end
    
    if @pay_money.blank?
      @errors << "请输入充值的金额"
    else
      if !(@pay_money =~ /^\d+\.?\d{0,2}$/)
        @errors << "充值金额只能为整数或小数,并且最多充许两位小数"
      else
        if @pay_money.to_i<1
          @errors << "充值金额不能为0"
        end
      end
    end
    
    
    if !@errors.blank?
      pay_form
      render :action=>:pay_form
      return
    end
    
    # check if the phone number exists
    bind = Recharge.find_by_sql "select t_account.acctid,balance from t_bindcalled left join t_account on t_account.acctid=t_bindcalled.acctid where bindcalled = '0#{@phone_number}'"
    if bind.blank?
      @errors << "对不起,你要充值的电话号码未找到"
    end

    if !@errors.blank?
      pay_form
      render :action=>:pay_form
      return
    end
    
    bind = bind.first # find_by_sql 得到的是一个array
    @before_balance = bind.balance
    
    
    
    
    # save order
    
    @title = "充值"
    @order = Recharge.new
    @order.money = (@pay_money.to_f*100).to_i
    @order.phone_number = @phone_number
    @order.getway = ShenZhouPay::GETWAY_ID
    @order.card_type = @card_type.to_i
    @order.card_number = @card_number
    @order.card_passwd = @card_passwd
    @order.card_value = @card_value
    @order.blance_before = @before_balance
    @order.status = Recharge::STATUS_ACTIVE
    @order.uid = @uid
    @order.save!
    
    
    
    redirect_to :action=>:goto_direct_pay,:id=>@uid
    
  end
  
  
  
  def goto_direct_pay
    uid = params[:id]
    
    @order = Recharge.find_by_uid(uid)
    
    if @order.blank?
      render :text=>"非法的请求 <a href='/'>返回</a>"
      return
    end
    
    if @order.status==Recharge::STATUS_SUCCESS
      redirect_to :action=>:pay_successed,:id=>uid
    elsif @order.status==Recharge::STATUS_FAILED
      redirect_to :action=>:pay_failed,:id=>uid
    elsif @order.server_response == 200
      # if pay response is 200 (OK), but status is not Success, means waiting...
      pay_processing
#      render :action=>:pay_processing
    else
      @phone_number = @order.phone_number
      @card_number = @order.card_number
      @card_value = @order.card_value
      @card_type = @order.card_type
      @pay_money = @order.money.to_i/100
      @finally_paied = PAY_TYPE_MAP[(@order.money.to_i/100).to_s] || @order.money.to_i/100
#      pay = ShenZhouPay.new
#      @pay_params = pay.varify_code_direct(@order.money,@order.order_id,@order.card_number,@order.card_passwd,@order.card_type,@order.card_value,"")
    end
    
  end
  
  
  def direct_pay
    uid = params[:id]
    
    @order = Recharge.find_by_uid(uid)
    
    if @order.blank?
      render :text=>"非法的请求 <a href='/'>返回</a>"
      return
    end
    
    pay = ShenZhouPay.new
    @pay_params = pay.varify_code_direct(@order,"")
    res = Net::HTTP.post_form(URI.parse(ShenZhouPay::DIRECT_GATEWAY_URL),@pay_params)
    res_code = res.body.strip
    
    @order.server_response = res_code.to_i
    @order.save!
    
    if(res_code.to_i!=200)
      @order.pay_fail
    end


    redirect_to :action=>"goto_direct_pay",:id=>@order.uid

  end
  
  def goto_pay
    uid = params[:id]
    
    @order = Recharge.find_by_uid(uid)
    
    if @order.blank?
      render :text=>"非法的请求 <a href='/'>返回</a>"
      return
    end
    
    if @order.status==Recharge::STATUS_SUCCESS
      redirect_to :action=>:pay_successed,:id=>uid
    elsif @order.status==Recharge::STATUS_FAILED
      redirect_to :action=>:pay_failed,:id=>uid
    else
      @phone_number = @order.phone_number
      item = "话费充值"
      desc = ""
      
      pay = ShenZhouPay.new
      @pay_params = pay.varify_code(@order.money,@order.order_id,item,desc,@order.getway,@order.card_type,"")
    end
    
  end
  
  def pay_successed
    uid = params[:id]
    
    @order = Recharge.find_by_uid(uid)
    acct  = Recharge.find_by_sql("select t_account.balance from t_bindcalled left join t_account on t_account.acctid=t_bindcalled.acctid where bindcalled = '0#{@order.phone_number}'").first
    
    @balance = acct.balance
    if @order.blank?
      render :text=>"非法的请求"
      return
    end
    
    
  end
  
  
  def pay_failed
    uid = params[:id]
    
    @order = Recharge.find_by_uid(uid)
    @error_msg = PAY_ERRORS[@order.server_response.to_s] || "内部错误，请联系服务人员"
    acct  = Recharge.find_by_sql("select t_account.balance from t_bindcalled left join t_account on t_account.acctid=t_bindcalled.acctid where bindcalled = '0#{@order.phone_number}'").first
    
    @balance = acct.balance
    if @order.blank?
      render :text=>"非法的请求"
      return
    end
    
    
  end
  
  
  def pay_processing
    render :text=>"支付进行中,稍请<a href='javascript:location.reload();'>刷新</a>重新查看结果"
  end
  
  
  def pay_background
    @order = Recharge.find_by_order_id(params[:orderId])
    
    params[:payMoney] = @order.money.to_s
    params[:orderId] = @order.order_id.to_s
    
    
    pay = ShenZhouPay.new
    if !@order.nil? && 
        @order.status == Recharge::STATUS_ACTIVE
        
      if params[:payResult]=="1" && pay.verify_return(params)
        @order.pay_success
      else
        @order.pay_fail
      end
    end
    render :text=>@order.order_id.to_s
  end
  
  
  def pay_frontpage
    @order = Recharge.find_by_order_id params[:orderId]
    if !@order.nil? 
      if params[:payResult]=="1"
        render :text=>"支付成功! 支付金额：#{params[:payMoney]}分"
      else
        render :text=>"支付失败！"
      end
    end
    
  end
  
  
  
  def pay_pass_wire
    
  end
  
end
