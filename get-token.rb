filename = "get_user_token.csv"
CSV.open filename,"wb" do |csv|
old_csv = CSV.open "1000_weibo_accounts.csv"
old_csv.each do |line|
  begin
    key = "2751696217"
    secret = "3dbddd005fc1af2600f795806cc372bc"
    WeiboOAuth2::Config.api_key = key
    WeiboOAuth2::Config.api_secret = secret
    @client = WeiboOAuth2::Client.new
    uname = line[0]
    pwd = line[1]
    t = @client.auth_password.get_token(uname,pwd)
    csv << [t.token]
    rescue Exception=>e
      if e.message =~ /username or password error/
        csv << ["昵称或者密码不正确"]
      end
    end
  end
end
