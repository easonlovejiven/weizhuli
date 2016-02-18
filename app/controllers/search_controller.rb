# -*- encoding : utf-8 -*-
class SearchController < ApplicationController

  layout "client/simple"

  def index
    @industries = Industry.publish.order("followed desc").limit(15)
    @search = params[:search] || {}
    
    # get query keyword 
    key = @search[:q]
    redirect_back if key.blank?
    # get search classes
    classes = []
    begin; classes << @search[:classes].constantize if !@search[:classes].blank?;   rescue;  end;
    
    # get sorting
    order = params[:orderby] || :hot
    sort_model = params[:order] || :desc
    
    # useing thinking_sphinx search 
    
    @results = ThinkingSphinx.search(key,:classes=>classes,:order=>order,:sort_mode=>sort_model,
                              :page=>params[:page],:per_page=>20)
    
  end

end
