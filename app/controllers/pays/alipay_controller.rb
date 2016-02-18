# -*- encoding : utf-8 -*-
class Pays::AlipayController < PayController


  def show
    @payment = Payment.find params[:id]
    
    @order = @payment.order
    
    if @order.blank?
      render :text=>"非法的请求 <a href='/'>返回</a>"
      return
    end
    
    if @order.status==Payment::STATUS_SUCCESSED
      redirect_to pay_path(@payment)
    elsif @order.status==Payment::STATUS_FAILED
      redirect_to pay_path(@payment)
    else
      
      pay = Alipay.new
      pay_params = {'out_trade_no' => @payment.id,'price' => (@payment.amount).to_s}
      # if use selected default bank, use "bankPay" method
      if(!params[:payBank].blank?)
        pay_params[:defaultbank] = params[:payBank]
        pay_params[:paymethod] = "bankPay"
      end
      pay_params['subject'] = "ANDY(安迪)订制手机壳"
      @pay_params = pay.pay_params(pay_params)
      
      redirect_to Alipay::PAY_URL+"?"+@pay_params.to_query
    end
    
    
  end

  
  def server_return
    payment_id = params['out_trade_no']
    payment = Payment.find(payment_id)
    if(!payment.nil?)
      price = "%0.2f"%[payment.amount.to_f]
      params['price']=price
      params.delete "controller"
      params.delete "action"
    end
    
    # 验证返回通知
    pay = Alipay.new
    verified = pay.verify_return(params)
    
    if verified
      trade_status = params['trade_status']
      if trade_status == 'TRADE_SUCCESS'
        payment.pay_success
      end
      render :text=>"success"
    else
      render :text=>"failed"
      
    end
    

  end
  
  
  
  def pay_frontpage
    @payment = Payment.find params[:out_trade_no]
    if @payment.order.done?
      flash[:order_done] = true
    end
    redirect_to client_order_path(@payment.order)
  end
  
end
  


