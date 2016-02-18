class Intel::KolsController < ApplicationController


  def index
    uid = params[:uid]
    @kol = Kol.find_by_uid uid
    render :json=>{:status=>@kol.nil?,:object=>@kol}
  end

end
