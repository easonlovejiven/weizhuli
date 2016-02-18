class Intel::GiftPurchasesController < ApplicationController
  layout "client"

  def index
    @intel_gift_purchases = IntelGiftPurchase.scoped
    @intel_gift_purchases = @intel_gift_purchases.where(intel_gift_id:params[:intel_gift_id]) if params[:intel_gift_id]
    @intel_gift_purchases = @intel_gift_purchases.paginate(:page=>params[:page], :per_page=>20)
  end

  def show
    @intel_gift_purchase = IntelGiftPurchase.find(params[:id])
  end


  def new
    @intel_gift_purchase = IntelGiftPurchase.new(intel_gift_id:params[:intel_gift_id])
  end

  def create
    @intel_gift_purchase = IntelGiftPurchase.new(params[:intel_gift_purchase])
    if @intel_gift_purchase.save
      redirect_to intel_gifts_path
    else
      render :action=>:new
    end
  end

  def edit
    @intel_gift_purchase = IntelGiftPurchase.find(params[:id])
  end

  def update
    @intel_gift_purchase = IntelGiftPurchase.find(params[:id])
  end

  def destroy
    @intel_gift_purchase = IntelGiftPurchase.find(params[:id])
  end
end
