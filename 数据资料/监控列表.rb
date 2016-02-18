
  #监控的主帐号
  
  filename = "监控的主帐号.csv"
  CSV.open filename,"wb" do |csv|
    csv << %w{UID 昵称 目前监控状态 个人/企业 监控时间 帐号信息更新时间}
    mwas = MonitWeiboAccount.find_by_sql <<-EOF
      select * from monit_weibo_accounts;
    EOF
    mwas.each{|mwa|
      created_at = mwa.created_at.strftime("%Y-%m-%d %H:%S")
      updated_at = mwa.updated_at.strftime("%Y-%m-%d %H:%S")
      csv << [mwa.uid,mwa.screen_name,mwa.status,mwa.analyse_status,created_at,updated_at]
    }
  end
