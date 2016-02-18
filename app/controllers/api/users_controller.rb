class Api::UsersController < Api::ApplicationController

  def index
    case @uid
    when '2295615873'
      render :json=>Intelbiz.user_updates(:start_time=>params[:start_time], :end_time=>params[:end_time])
    else
      render :json=>{status:"auth failed"}
    end
  end
end
