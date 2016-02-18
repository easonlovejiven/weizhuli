# -*- encoding : utf-8 -*-
class Admin::NewsController < Admin::ApplicationController
  include ActionView::Helpers::SanitizeHelper

  layout 'admin'
  require 'will_paginate/array'

  # GET /news
  # GET /news.xml
  def index

		@news = News.search(params[:search]).paginate(:order=>"id desc",:page=>params[:page],:per_page=>20)

    @industries_id = Industry.all.map{|x| [x.name, x.id]}
    @html_title = _('News admin index')

    respond_to do |format|
      format.html # index.html.erb
      format.xml  { render :xml => @news }
    end
  end

  # GET /news/1
  # GET /news/1.xml
  def show
    @news = News.find(params[:id])
    @html_title = @news.title

    respond_to do |format|
      format.html # show.html.erb
      format.xml  { render :xml => @news }
    end
  end

  # GET /news/new
  # GET /news/new.xml
  def new
    @news = News.new
    @news.build_image_reference
    @news.image_references.build
    @news.image_references.build
#    @news.image_references_attributes = [{:content_type=>"news"}]

    respond_to do |format|
      format.html # new.html.erb
      format.xml  { render :xml => @news }
    end
  end

  # GET /news/1/edit
  def edit
    @news = News.find(params[:id])
    @news.build_image_reference if @news.image_reference.nil?
    @news.image_references.build if @news.image_references.blank?
    @html_title = _('Edit') + ' ' + @news.title
  end

  # POST /news
  # POST /news.xml
  def create
    @news = News.new(params[:news])
    @news.status = News::INACTIVE_STATUS
    if !params[:news][:content].blank?
      params[:news][:content] =  sanitize(params[:news][:content])
    end

    respond_to do |format|
      if @news.save
        format.html { redirect_to([:admin,@news], :notice => 'News was successfully created.') }
        format.xml  { render :xml => @news, :status => :created, :location => @news }
      else
        format.html { render :action => "new" }
        format.xml  { render :xml => @news.errors, :status => :unprocessable_entity }
      end
    end
  end

  # PUT /news/1
  # PUT /news/1.xml
  def update
    @news = News.find(params[:id])
    
    if !params[:news][:content].blank?
      params[:news][:content] =  sanitize(params[:news][:content])
    end
    respond_to do |format|
      if @news.update_attributes(params[:news])
        format.html { redirect_to([:admin,@news], :notice => 'News was successfully updated.') }
        format.xml  { head :ok }
      else
        format.html { render :action => "edit" }
        format.xml  { render :xml => @news.errors, :status => :unprocessable_entity }
      end
    end
  end

  # DELETE /news/1
  # DELETE /news/1.xml
  def destroy
    @news = News.find(params[:id])
    @news.destroy

    respond_to do |format|
      format.html { redirect_to(admin_news_index_url) }
      format.xml  { head :ok }
    end
  end

  def active_news
    @news= News.find(params[:id])
    @news.status = News::ACTIVE_STATUS
    respond_to do |format|
      if @news.save
        format.html { redirect_back :notice => 'News was successfully Actived.' }
        format.xml  { render :xml => @news, :status => :created, :location => @news }
      else
        format.html { redirect_back :notice => 'News was not successfully Actived.'  }
        format.xml  { render :xml => @news.errors, :status => :unprocessable_entity }
      end
    end
  end

  def inactive_news
    @news= News.find(params[:id])
    @news.status = News::INACTIVE_STATUS
    respond_to do |format|
      if @news.save
        format.html { redirect_back :notice => 'News was successfully Inactived.' }
        format.xml  { render :xml => @news, :status => :created, :location => @news }
      else
        format.html { redirect_back :notice => 'News was not successfully Inactived.'  }
        format.xml  { render :xml => @news.errors, :status => :unprocessable_entity }
      end
    end
  end
end
