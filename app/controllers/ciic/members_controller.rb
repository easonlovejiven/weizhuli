# -*- encoding : utf-8 -*-
class Ciic::MembersController < ApplicationController

  layout false

  def index
    wxopenid=params[:wxopenid]
    session[:wxopenid] = wxopenid

    @member = MZhongzhiMember.where(openid:wxopenid).first
    if @member.nil?
      render :text=>"请先关注中智微信"
    end


  end

  def update
    @member = MZhongzhiMember.find(params[:id])
    @member.update_attributes(params[:m_zhongzhi_member])

    @member.gen_card

    redirect_to ciic_members_path(wxopenid:@member.openid)
  end



end
