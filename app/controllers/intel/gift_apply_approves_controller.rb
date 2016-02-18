# -*- encoding : utf-8 -*-
class Intel::GiftApplyApprovesController < ApplicationController

  layout 'frontend'

  def show
    @email = IntelGiftApply::APPROVERS.clone.delete params[:approver]
    @intel_gift_apply = IntelGiftApply.find_by_approve_code(params[:id])
  end

  def update
    @intel_gift_apply = IntelGiftApply.find_by_approve_code(params[:id])
    @intel_gift_apply.approver = params[:approver]
    @intel_gift_apply.approve_description = params[:approve_description]
    @intel_gift_apply.status = 1
    @intel_gift_apply.gen_approve_code
    @intel_gift_apply.save!
  end

  def destroy
    @intel_gift_apply = IntelGiftApply.find_by_approve_code(params[:id])
    @intel_gift_apply.approver = params[:approver]
    @intel_gift_apply.approve_description = params[:approve_description]
    @intel_gift_apply.status = 2
    @intel_gift_apply.gen_approve_code
    @intel_gift_apply.save!
  end

end
