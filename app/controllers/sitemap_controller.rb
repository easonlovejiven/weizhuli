# -*- encoding : utf-8 -*-
class SitemapController < ApplicationController

  # ref http://tonycode.com/wiki/index.php?title=Ruby_on_Rails_Sitemap_Generator
  # ref http://lukaszwrobel.pl/blog/generate-sitemap-in-rails
  def index
    @urls = [root_url]
    @urls += Event.available.all.map{|p| client_event_url(p)}
    headers["Content-Type"] = "text/xml"
    # set last modified header to the date of the latest entry.
    headers["Last-Modified"] = Time.now.httpdate    
    render :layout => false
  end

end
