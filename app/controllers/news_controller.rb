# -*- encoding : utf-8 -*-
class NewsController < ApplicationController

  layout  "frontend"

  # GET /news
  # GET /news.xml
  def index
    @news = News.order("online_time desc").paginate(:page=>params[:page],:per_page=>20)
  end

  # GET /news/1
  # GET /news/1.xml
  def show
    @news = News.find(params[:id])
    @next = News.next(@news).first
    @previous = News.previous(@news).first

    respond_to do |format|
      format.html # show.html.erb
      format.xml  { render :xml => @news }
    end
  end

end
