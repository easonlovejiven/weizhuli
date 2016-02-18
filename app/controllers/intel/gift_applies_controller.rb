# -*- encoding : utf-8 -*-
class Intel::GiftAppliesController < ApplicationController
  layout "client"
  
  def index
    if has_role?(:gift_admin)
      @intel_gift_applies = IntelGiftApply.mysearch(params[:search]).paginate(:page=>params[:page],:per_page=>20)
    else
      @intel_gift_applies = IntelGiftApply.where(applyer_id:current_user.id).mysearch(params[:search]).paginate(:page=>params[:page],:per_page=>20)
    end
  end

  def new
    @intel_gift_apply = IntelGiftApply.new
    @intel_gift_apply.items.build(:number=>1)
  end


  def show
    @intel_gift_apply = IntelGiftApply.find(params[:id])
  end

  def create
    @intel_gift_apply = IntelGiftApply.new(params[:intel_gift_apply])
    @intel_gift_apply.applyer = current_user
    @intel_gift_apply.gen_approve_code
    @intel_gift_apply.status = 0
    if @intel_gift_apply.save
      redirect_to intel_gift_applies_path
    else
      render  :action=>:new
    end
  end

  def edit
    @intel_gift_apply = IntelGiftApply.find(params[:id])

  end

  def update
    @intel_gift_apply = IntelGiftApply.find(params[:id])
    if params[:ac].present?
      case params[:ac]
      when "reject"
        @intel_gift_apply.status = 2
        @intel_gift_apply.approver = current_user.login
        @intel_gift_apply.gen_approve_code
      when "approve"
        @intel_gift_apply.status = 1
        @intel_gift_apply.approver = current_user.login
        @intel_gift_apply.gen_approve_code
      end
      @intel_gift_apply.save!
    end
    redirect_to intel_gift_apply_path(@intel_gift_apply)
  end

  def destroy
    @intel_gift_apply = IntelGiftApply.find(params[:id])
    @intel_gift_apply.destroy
    redirect_to intel_gift_applies_path
  end



end
