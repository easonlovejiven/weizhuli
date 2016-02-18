# -*- encoding : utf-8 -*-
class IntelbizUserComplitWorker

  include Sidekiq::Worker
  sidekiq_options :queue => :init_scripts, :backtrace => true
  
  def perform
    client = Savon.client(wsdl: "http://intelscrm.wmwebpro.cn/webservice/usersservice.asmx?WSDL")
    res = client.call :get_users
    uids = res.body[:get_users_response][:get_users_result][:intel_users][:user].map{|h| h[:wei_bo_uid]}.compact
    names = res.body[:get_users_response][:get_users_result][:intel_users][:user].map{|h| h[:wei_bo_nick_name]}.compact

    res = ReportUtils.names_to_uids(names,true,with_bad_names:true)
    uids2 = res[:uids]
    bad_names = res[:bad_names]
    uids += uids2
    uids.uniq!

    bad_uids = []

    task = GetUserTagsTask.new

    good_uids = []
    uids.each{|uid|
      begin
        a = task.api.users.show(uid:uid)
        ma = a
        task.save_weibo_user(a)
        good_uids << uid
        
      rescue Exception => e
        bad_uids << uid
      end
    }

    good_uids.each{|uid|
      next if uid.blank?
      IntelbizUpdateUser.create(uid:uid,status:1)
    }
    bad_names.each{|name|
      next if name.blank?
      IntelbizUpdateUser.create(name:name,status:-1)
    }
    bad_uids.each{|uid|
      next if uid.blank?
      IntelbizUpdateUser.create(uid:uid,status:-1)
    }

  end
end




