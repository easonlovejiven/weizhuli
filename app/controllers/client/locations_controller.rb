# -*- encoding : utf-8 -*-
class Client::LocationsController < ApplicationController
  
  def index
    @locations = Location.search(params[:search]).all
    render :json=>@locations.map{|l| {:id=>l.id, :name=>l.name, :parent_id=>l.parent_id}}
  end
end
