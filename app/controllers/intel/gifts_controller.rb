# -*- encoding : utf-8 -*-
class Intel::GiftsController < ApplicationController
  layout "client"

  def index
    @intel_gifts = IntelGift.paginate(:page=>params[:page], :per_page=>20)
  end

  def show
    @intel_gift = IntelGift.find(params[:id])
  end


  def new
    @gift_categories =IntelGift.select("distinct category").map(&:category)
    @intel_gift = IntelGift.new
  end

  def create
    @intel_gift = IntelGift.new(params[:intel_gift])
    if @intel_gift.save
      redirect_to intel_gifts_path
    else
      render :action=>:new
    end
  end

  def edit
    @gift_categories =IntelGift.select("distinct category").map(&:category)
    @intel_gift = IntelGift.find(params[:id])
  end

  def update
    @intel_gift = IntelGift.find(params[:id])
    @intel_gift.update_attributes(params[:intel_gift])
    redirect_to intel_gifts_path

  end

  def destroy
    @intel_gift = IntelGift.find(params[:id])
    @intel_gift.destroy
    redirect_to intel_gifts_path
  end
end
