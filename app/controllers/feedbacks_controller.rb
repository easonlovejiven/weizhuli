# -*- encoding : utf-8 -*-
class FeedbacksController < ApplicationController

  layout "client/simple"
  # GET /feedbacks
  # GET /feedbacks.xml
  def index
    @feedback = Feedback.new
    if current_user
      if current_user.business_card && current_user.business_card.mobile
        @feedback.email = current_user.business_card.mobile
      else
        @feedback.email = current_user.login
      end
    end

    respond_to do |format|
      format.html { render :layout=>!request.xhr?} # new.html.erb
      format.xml  { render :xml => @feedback }
    end
  end

  # GET /feedbacks/1
  # GET /feedbacks/1.xml
  def show
    @feedback = Feedback.find(params[:id])

    respond_to do |format|
      format.html # show.html.erb
      format.xml  { render :xml => @feedback }
    end
  end

  # GET /feedbacks/1/edit
  def edit
    @feedback = Feedback.find(params[:id])
  end

  # POST /feedbacks
  # POST /feedbacks.xml
  def create
    @feedback = Feedback.new(params[:feedback])

    @feedback.check_verification_code = true
    @feedback.inputed_verification_code = params[:valid_code]
    @feedback.verification_code = session[:proof_image][:text]
    respond_to do |format|
      if @feedback.save
        format.html { redirect_to( feedbacks_path, :notice => _('提交成功，感谢您的建议。')) }
        format.xml  { render :xml => @feedback, :status => :created, :location => @feedback }
        format.js { render :json=>{:status=>"success", :object=>@feedback}}
      else
        format.html { render :action => "index" }
        format.xml  { render :xml => @feedback.errors, :status => :unprocessable_entity }
        format.js { render :json=>{:status=>"error", :errors=>@feedback.errors}}
      end
    end
  end

  # PUT /feedbacks/1
  # PUT /feedbacks/1.xml
  def update
    @feedback = Feedback.find(params[:id])

    respond_to do |format|
      if @feedback.update_attributes(params[:feedback])
        format.html { redirect_to(@feedback, :notice => 'Feedback was successfully updated.') }
        format.xml  { head :ok }
      else
        format.html { render :action => "edit" }
        format.xml  { render :xml => @feedback.errors, :status => :unprocessable_entity }
      end
    end
  end

  # DELETE /feedbacks/1
  # DELETE /feedbacks/1.xml
  def destroy
    @feedback = Feedback.find(params[:id])
    @feedback.destroy

    respond_to do |format|
      format.html { redirect_to(feedbacks_url) }
      format.xml  { head :ok }
    end
  end
end

