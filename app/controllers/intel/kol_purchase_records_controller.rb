# -*- encoding : utf-8 -*-
class Intel::KolPurchaseRecordsController < ApplicationController

  layout  "client"

  def index
    @purchases = KolPurchase.mysearch(params[:search]||{}).order("use_time asc").paginate(:per_page=>20,:page=>params[:page])
    @total_price = KolPurchase.mysearch(params[:search]||{}).sum("price")
  end

  def show
    @purchase = KolPurchase.find(params[:id])
  end

  def new
    @purchase = KolPurchase.new
    @purchase.build_kol
  end

  def create

    if params[:kol_purchase][:kol_attributes][:id].present?
      kol_attributes = params[:kol_purchase].delete(:kol_attributes)
      @kol = Kol.find(kol_attributes[:id])
      @kol.attributes = kol_attributes
    end
    @purchase = KolPurchase.new(params[:kol_purchase])
    @purchase.kol = @kol if @kol
    if @purchase.valid?
      @purchase.use_times.to_i.times{|i|
        purchase = KolPurchase.new(params[:kol_purchase])
        purchase.kol = @kol if @kol 
        purchase.save!       
      }
      redirect_to intel_kol_purchase_records_path
    else
      render :new
    end
  end

  def edit
    @purchase = KolPurchase.find(params[:id])
    render :action=> params[:use] == 'true' ? 'use' : "edit"
  end

  def update
    @purchase = KolPurchase.find(params[:id])
    @purchase.attributes = (params[:kol_purchase])
    if @purchase.update_attributes(params[:kol_purchase])
      redirect_to intel_kol_purchase_records_path
    else
      render :edit
    end
  end

  def destroy
    @purchase = KolPurchase.find(params[:id])
    @purchase.destroy
    redirect_to intel_kol_purchase_records_path
  end

end
