# -*- encoding : utf-8 -*-
class DownloadController < ApplicationController

  def index
    file_path = params[:file_path]
    type = params[:type]
    if type == 'data'
      send_file Rails.root.join('data', file_path), :type => 'text/html', :disposition => 'attachment'
    else
      send_file Rails.root.join('public', file_path), :type => 'text/html', :disposition => 'attachment'
    end

  end

end
