# -*- encoding : utf-8 -*-
class WeixinUserApiExportor < ExportorBase

  description <<EOF
    根据 openId 提取微信基本信息
EOF
  title "微信-提取微信基本信息(根据openId)"


  before do |this,opts|
    #TODO:
    @openid = case 
            when opts[:uids].is_a?(String)
              opts[:uids].split("\r\n").map{|line| line.blank? ? nil : line.strip}.compact
            when opts[:uids].is_a?(Array)
              opts[:uids]
            else
            end
    @uid = opts[:uid]
  end

  export name:"用户列表" do |ins,opts|
    ins.check_relations(@openid)
  end


  def check_relations(source_openids)
      require 'net/http'
      require 'open-uri'
      url = "http://intelweixin.buzzopt.com/index.php/wechat/getUserInfoByOpenId/openid/"
        rows << %w{subscribe openid nickname sex language city province country headimgurl subscribe_time}
        source_openids.each do|line|
            openid = line
            puts openid
            urlp = url+openid.to_s
            host = urlp.match(".+\:\/\/([^\/]+)")[1]
            path = urlp.partition(host)[2] || "/"
            begin
              res = Net::HTTP.get host, path
              keyword = JSON.parse(res)
              if keyword['errmsg'] == "invalid openid"
                rows << [openid]
                next
              end 
              subscribe_time = Time.at(keyword['subscribe_time'].to_i)
              rows <<  [keyword['subscribe'],keyword['openid'],keyword['nickname'],keyword['sex'],keyword['language'],keyword['city'],keyword['province'],keyword['country'],keyword['headimgurl'],subscribe_time]
            rescue Exception=>e
              rows << [openid]
              next
            end
        end

  end


end
