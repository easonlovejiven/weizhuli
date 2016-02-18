# -*- encoding : utf-8 -*-
class NewsCategory < ActiveRecord::Base

  validates_presence_of :name, :message => "名称不能为空"
  validates_presence_of :internal_name, :message => "内部名称不能为空"


  GENERAL_NEWS_CATEGORY = "general"
  
end



