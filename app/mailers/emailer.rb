# -*- encoding : utf-8 -*-
class Emailer < ActionMailer::Base
  default :from => "ye@cebexgroup.com"
  
  def test(opt)
    mail(opt)
  end



  def site_request_creation_email(site_request)
    @site_request = site_request
    mail(:to=>"ye@cebexgroup.com",:subject=>"[SITE_REQUEST]")
  end

  
end
