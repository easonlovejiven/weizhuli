# -*- encoding : utf-8 -*-

# DOC: https://www.paypal-biz.com/development/documentation/PayPal_NVP_Guide_V1.0.pdf
# example : http://www.codyfauser.com/2008/1/17/paypal-express-payments-with-activemerchant


class Pays::PaypalController < PayController
  include ActiveMerchant::Billing::Integrations
  include ActiveMerchant::Billing
  
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

=begin      
      pay = Alipay.new
      pay_params = {'out_trade_no' => @payment.id,'price' => (@payment.amount).to_s}
      # if use selected default bank, use "bankPay" method
      if(!params[:payBank].blank?)
        pay_params[:defaultbank] = params[:payBank]
        pay_params[:paymethod] = "bankPay"
      end
      @pay_params = pay.pay_params(pay_params)
      
      redirect_to APP_CONFIG[]+"?"+@pay_params.to_query
=end      
      
      
      # paypal payment page
      amount = (@payment.amount*100).to_i
      setup_response = gateway.setup_purchase(amount,
        :ip                => request.remote_ip,
        :return_url        => APP_CONFIG[:paypal_confirm_url],
        :cancel_return_url => APP_CONFIG[:paypal_cancel_return_url],
        :description       => _("活动报名费用")+" #{@payment.amount} #{@order.currency}",
        :currency          => @order.currency,
        :order_id => @payment.id
      )
      redirect_to gateway.redirect_url_for(setup_response.token)

    end
    
    
  end

  
  def confirm
  
    redirect_to :action => 'index' unless params[:token]
    
    details_response = gateway.details_for(params[:token])
    
    if !details_response.success?
      @message = details_response.message
      render :action => 'error'
      return
    end
      
    @address = details_response.address
    
    @payment = Payment.find(details_response.params["InvoiceID"])
    
    redirect_to complete_pays_paypal_path(@payment, :token=>params[:token], :payer_id=>params[:PayerID])
  end
  
  
  def complete

    @payment = Payment.find(params[:id])

    purchase = gateway.purchase((@payment.amount*100).to_i,
      :currency          => @payment.order.currency,
      :ip       => request.remote_ip,
      :payer_id => params[:payer_id],
      :token    => params[:token],
      :notify_url => APP_CONFIG[:paypal_notify_url]
    )
    
#    if !purchase.success?
#    end

    redirect_to   pay_frontpage_pays_paypal_path(@payment)
  end
  
  
  def server_return

    notify = Paypal::Notification.new(request.raw_post)

    payment = Payment.find(notify.invoice)

    if notify.acknowledge
      begin

        if notify.complete?
          payment.pay_success
        else
          logger.error("Failed to verify Paypal's notification, please investigate")
        end

      rescue => e
        payment.pay_failed
        raise
      ensure
      end
    end

    render :nothing=>true


  end
  
  
  
  def pay_frontpage
    @payment = Payment.find(params[:id])
    redirect_to pay_path(@payment)
  end




private
def gateway
  @gateway ||= PaypalExpressGateway.new(
    :login => APP_CONFIG[:paypal_email],
    :password => APP_CONFIG[:paypal_secret],
    :signature => APP_CONFIG[:paypal_cert_id]
  )
end
  
end
  


