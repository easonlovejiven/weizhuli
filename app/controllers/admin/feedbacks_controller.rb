# -*- encoding : utf-8 -*-
class Admin::FeedbacksController < ApplicationController


  layout 'admin'

  # GET /feedbacks
  # GET /feedbacks.xml
  def index
    @feedbacks = Feedback.search(params[:search]).order("id desc").paginate(:page=>params[:page], :per_page=>20)

    respond_to do |format|
      format.html # index.html.erb
      format.xml  { render :xml => @feedbacks }
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

  # GET /feedbacks/new
  # GET /feedbacks/new.xml
  def new
    @feedback = Feedback.new

    respond_to do |format|
      format.html # new.html.erb
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

    respond_to do |format|
      if @feedback.save
        flash[:notice] = 'Feedback was successfully created.'
        format.html { redirect_to([:admin,@feedback]) }
        format.xml  { render :xml => @feedback, :status => :created, :location => [:admin,@feedback] }
      else
        format.html { render :action => "new" }
        format.xml  { render :xml => @feedback.errors, :status => :unprocessable_entity }
      end
    end
  end

  # PUT /feedbacks/1
  # PUT /feedbacks/1.xml
  def update
    @feedback = Feedback.find(params[:id])

    respond_to do |format|
      if @feedback.update_attributes(params[:feedback])
        flash[:notice] = 'Feedback was successfully updated.'
        format.html { redirect_to(edit_admin_feedback_path(@feedback)) }
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

