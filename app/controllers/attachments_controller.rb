# -*- encoding : utf-8 -*-
class AttachmentsController < ApplicationController
  skip_before_filter :verify_authenticity_token, :only => :create

  def manage
    @attachments = "tiny_#{params[:media]}".classify.constantize.where(["user_id = ?",current_user.id]).paginate :page => params[:page], :order => 'created_at DESC', :per_page => 10
    render :update do |page|
      page.replace_html :dynamic_images_list, :partial => 'show_attachment_list'
    end
  end



  def create
    @attachment = "tiny_#{params[:media]}".classify.constantize.new params[params[:media]]
    @attachment.user_id = current_user.id
    if @attachment.save
      GC.start
      responds_to_parent do
        render :update do |page|
          page << "upload_callback();"
        end
      end
    else
      responds_to_parent do
        render :update do |page|
          page.alert('Sorry, there was an error uploading the photo.')
        end
      end
    end
  end
end

