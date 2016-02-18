# -*- encoding : utf-8 -*-
class UserSession < Authlogic::Session::Base

  allow_http_basic_auth false

  find_by_login_method :find_by_login_method

end
