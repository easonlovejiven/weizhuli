module Client::PostsHelper
  def with_geo
    current_user.settings[:enable_posting_geo]
  end
end
