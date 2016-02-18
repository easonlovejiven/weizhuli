# -*- encoding : utf-8 -*-
class WeixinApi

  @@token = nil

  CONFIG = {
    :weizhuli=>{
      # 商户号 1220783601
      account:"bjweizhuli",
      appid:"wxfe23e5d17282085b",
      secret:"17b7c1d188a9e29b9fe7cd7d09f1ab02",
    },
    :zhongzhi=>{
      account:"ciicbj",
      appid:"wxbe03db7ddbe92f67",
      secret:"d31fe502f6478e1575f13687440f77f2",
    },
    :test=>{
      account:"gh_7a10b5456500",
      appid:"wx8cb5802b14e5fef1",
      secret:"58bca39f59d68ab8fa2b7ee744411bdd",
    },
    :yipin=>{
      account:"gh_a0d89584209c",
      appid:"wx42f2cb4b439f1851",
      secret:"e6fefb789153b1aac152f0b76fa9d29f",
    },
    :eason=>{
      account:"gh_848c90a8082a",
      appid:"wx95597340cc0dafa2",
      secret:"81f6b61da41c6b46762a13f54bbc740c",
    }
  }

  def initialize(site)
    @site = site
    @config = CONFIG[site]
    if @config.nil?
      raise "WeixinApi don't support site #{site}, supportted sites : #{CONFIG.keys}"
    end
  end

  def update_menu
    token = get_token
    menu = {
      button:[
        {
          type:"click",
          name:"发现",
          sub_button:[
            {
              type:"click",
              name:"产品介绍",
              key:"btn_introduce",
            },
            {
              type:"click",
              name:"服务内容",
              key:"btn_services",
            },
            {
              type:"click",
              name:"新闻资讯",
              key:"btn_news",
            },
            {
              type:"click",
              name:"案例解析",
              key:"btn_cases",
            },
          ]
        },

        {
          type:"click",
          name:"帮助",
          sub_button:[
            {
              type:"click",
              name:"我的客服",
              key:"btn_customer_service",
            },
            {
              type:"click",
              name:"数据定义",
              key:"btn_data_definition",
            },
            {
              type:"click",
              name:"关于我们",
              key:"btn_about_us",
            },
            {
              type:"click",
              name:"使用帮助",
              key:"btn_help",
            },
          ]
        },

        {
          name:"我的日报",
          sub_button:[
            {
              type:"click",
              name:"绑定帐号",
              key:"btn_member_reg",
            },
            {
              type:"click",
              name:"发送日报",
              key:"btn_member_send_report",
            },
            {
              type:"click",
              name:"查看日报",
              key:"btn_daily_report",
            },
          ]
        }
      ]
    }



    menu = {
      button:[
        {
          type:"click",
          name:"智服务",
          sub_button:[
            {
              type:"view",
              name:"员工入职篇",
              url:"http://www.ciicbj.com/Mobile/PersonalEdition/EmployeeServices/default.aspx?tagIndex=0",
            },
            {
              type:"view",
              name:"员工在职篇",
              url:"http://www.ciicbj.com/Mobile/PersonalEdition/EmployeeServices/default.aspx?tagIndex=1",
            },
            {
              type:"view",
              name:"员工离职篇",
              url:"http://www.ciicbj.com/Mobile/PersonalEdition/EmployeeServices/default.aspx?tagIndex=2",
            }
          ]
        },

        {
          type:"click",
          name:"智查询",
          sub_button:[
            {
              type:"view",
              name:"自助查询（个人版）",
              url:"http://www.ciicbj.com/Mobile/PersonalEdition/grcx/default.aspx",
            },
            {
              type:"view",
              name:"自助查询（企业版）",
              url:"http://www.ciicbj.com/Mobile/EnterpriseEdition/qycx/default.aspx",
            },
            {
              type:"view",
              name:"个税计算器",
              url:"http://www.ciicbj.com/Mobile/PersonalEdition/sygj/default.aspx?tagIndex=0",
            },
            {
              type:"view",
              name:"年终奖计算器",
              # key:"btn_tax_cal"
              url:"http://www.ciicbj.com/Mobile/PersonalEdition/sygj/default.aspx?tagIndex=1",
            },
          ]
        },

        {
          name:"中智北京",
          sub_button:[
            {
              type:"view",
              name:"公司介绍",
              url:"http://www.ciicbj.com/Mobile/EnterpriseEdition/AboutUs/3540.aspx",
            },
            {
              type:"view",
              name:"解决方案",
              url:"http://www.ciicbj.com/Mobile/EnterpriseEdition/ServiceSolutions/default.aspx",
            },
            {
              type:"view",
              name:"招聘速递",
              url:"http://www.ciicbj.com/Mobile/PersonalEdition/RecruitmentCourier/default.aspx",
            },
            {
              type:"view",
              name:"会议站",
              url:"http://zz.jazzad.cn/",
            },
            
            # {
            #   type:"view",
            #   name:"资讯中心",
            #   url:"http://www.ciicbj.com/Mobile/EnterpriseEdition/News/default.aspx",
            # },
            {
              type:"view",
              name:"联系我们",
              url:"http://www.ciicbj.com/Mobile/EnterpriseEdition/AboutUs/13520.aspx",
            },
          ]
        }
      ]
    }




    menu = {
      button:[
        {
          name:"J.P. Morgan",
          sub_button:[
            {
              type:"view",
              name:"Registration",
              url:"http://ciicbj.weizhuli.com/test3/pages/p9.html",
            },
            {
              type:"view",
              name:"Teams",
              url:"http://ciicbj.weizhuli.com/test3/solutions.html#five",
            },
            {
              type:"view",
              name:"About Us",
              url:"http://ciicbj.weizhuli.com/test3/solutions.html#five",
            },
            {
              type:"view",
              name:"Series Review",
              url:"http://ciicbj.weizhuli.com/test3/solutions.html#five",
            },
          ]
        },

        {
          type:"click",
          name:"Guide",
          sub_button:[
            {
              type:"view",
              name:"Routes",
              url:"http://ciicbj.weizhuli.com/test3/pages/p6.html",
            },
          ]
        },


        {
          type:"click",
          name:"Rewards",
          sub_button:[
            {
              type:"view",
              name:"Earn",
              url:"http://ciicbj.weizhuli.com/test3/index.html#one",
            },
            {
              type:"view",
              name:"My Points",
              url:"http://ciicbj.weizhuli.com/test3/index.html#two",
            },
            {
              type:"view",
              name:"Redeem",
              url:"http://ciicbj.weizhuli.com/test3/index.html#three",
            },
            {
              type:"view",
              name:"Rules",
              url:"http://ciicbj.weizhuli.com/test3/index.html#four",
            },
          ]
        },


      ]

    }


    http = Net::HTTP.new("api.weixin.qq.com",443)
    http.use_ssl = true
    str_menu = URI.decode(encode_menu(menu).to_json)
    res = http.post("/cgi-bin/menu/create?access_token=#{token}",str_menu)

    puts res, res.body
  end


  def delete_menu
    token = get_token
    http = Net::HTTP.new("api.weixin.qq.com",443)
    http.use_ssl = true
    res = http.get("/cgi-bin/menu/delete?access_token=#{token}")
    puts res, res.body
  end

  def encode_menu(menu)
    menu[:button].each{|btn|
      btn[:name] = URI.encode(btn[:name])
      btn[:sub_button] && btn[:sub_button].each{|sbtn|
        sbtn[:name] = URI.encode(sbtn[:name])
      }
    }


    menu
  end


  def get_token
    # get : https://api.weixin.qq.com/cgi-bin/token?grant_type=client_credential&appid=wxfe23e5d17282085b&secret=17b7c1d188a9e29b9fe7cd7d09f1ab02
    if @@token.nil? || @@token[@site].nil? || ( @@token[@site]['created_at'] && @@token[@site]['created_at'] < Time.now-1.5.hour)
      @@token ||= {@site=>{}}
      puts "Weixin Token reloading..."
      http = Net::HTTP.new("api.weixin.qq.com",443)
      http.use_ssl = true
      res = http.get("https://api.weixin.qq.com/cgi-bin/token?grant_type=client_credential&appid=#{@config[:appid]}&secret=#{@config[:secret]}")
      @@token[@site] = JSON.parse(res.body)
      @@token[@site]['created_at'] = Time.now
    end
    @@token[@site]["access_token"]
  end


  def response_transfer_customer_service(to_openid)
    {
        ToUserName:to_openid,
        FromUserName:sender_account,
        CreateTime:Time.now.to_i,
        MsgType:"transfer_customer_service",
    }.to_xml(:root=>"xml",:skip_instruct => true)

  end

  def response_text(to_openid,text)
    {
        ToUserName:to_openid,
        FromUserName:sender_account,
        CreateTime:Time.now.to_i,
        MsgType:"text",
        Content:text
    }.to_xml(:root=>"xml",:skip_instruct => true)
  end



  def response_image(to_openid,media_id)
    {
        ToUserName:to_openid,
        FromUserName:sender_account,
        CreateTime:Time.now.to_i,
        MsgType:"image",
        Image:{
          MediaId:media_id
        }
    }.to_xml(:root=>"xml",:skip_instruct => true)

  end


  def response_voice(to_openid,media_id)
    {
        ToUserName:to_openid,
        FromUserName:sender_account,
        CreateTime:Time.now.to_i,
        MsgType:"voice",
        Voice:{
          MediaId:media_id
        }
    }.to_xml(:root=>"xml",:skip_instruct => true)
  end


  def response_vedio(to_openid,media_id,thumb_media_id)
    {
        ToUserName:to_openid,
        FromUserName:sender_account,
        CreateTime:Time.now.to_i,
        MsgType:"text",
        Video:{
          MediaId:media_id,
          ThumbMediaId:thumb_media_id,
        }
    }.to_xml(:root=>"xml",:skip_instruct => true)
  end


  def response_music(to_openid,title,description,url,hq_url,thumb_media_id)
    {
        ToUserName:to_openid,
        FromUserName:sender_account,
        CreateTime:Time.now.to_i,
        MsgType:"music",
        Music:{
          Title:title,
          Description:description,
          MusicUrl:url,
          HQMusicUrl:hq_url,
          ThumbMediaId:thumb_media_id,
        }
    }.to_xml(:root=>"xml",:skip_instruct => true)
  end


  # messages : [
  #   {
  #     item:{
  #       Title:"",
  #       Description:"",
  #       PicUrl:"",
  #       Url:"",
  #     },
  #     item:{
  #       ...
  #     }
  #   }
  # ]
  def response_news(to_openid,messages)
    xml = {
        ToUserName:to_openid,
        FromUserName:sender_account,
        CreateTime:Time.now.to_i,
        MsgType:"news",
        ArticleCount:messages.size,
        Articles:'#{messages}'
    }.to_xml(:root=>"xml",:skip_instruct => true)
    messages_xml = messages.map{|m|
        s = <<EOF
  <item>
    <Title>#{m[:title]}</Title>
    <Description>#{m[:description]}</Description>
    <PicUrl>#{URI.encode(m[:picurl])}</PicUrl>
    <Url>#{m[:url]}</Url>
  </item>

EOF

    }
    xml.gsub('#{messages}',messages_xml*"")
  end




  def sender_account
    @config[:account]
  end



  def generate_qrcode(perm=false, ids)
    token = get_token
    http = Net::HTTP.new("api.weixin.qq.com",443)
    http.use_ssl = true
    

    reses = []

    ids.each{|id|
      if perm
        json = %Q{{"action_name": "QR_LIMIT_SCENE", "action_info": {"scene": {"scene_id": #{id}}}}}
      else
        json = %Q{{"expire_seconds": 1800, "action_name": "QR_SCENE", "action_info": {"scene": {"scene_id": #{id}}}}}
      end

      res = http.post("/cgi-bin/qrcode/create?access_token=#{token}",json)
      res = JSON.parse(res.body)
      reses << res
    }

    reses

  end


  def send_group_message()

    json = {
      "touser"=>[
        "oXwlNuIQ0cd_Zx9SOqL8otrSABbE"
      ],
      "mpnews"=>{
        "media_id"=>"IwcBIiUN2VpjRLvyy6xR2lOCWSJZxWRADESN0H_4pSTMMgOlVdabvuGE0ghdVLwQ"
      },
      "msgtype"=>"mpnews"
    }

    res = post("/cgi-bin/message/mass/send",json.to_json)
  end


  def send_48h_message()
    json = {
        "touser"=>"oXwlNuIQ0cd_Zx9SOqL8otrSABbE",
        "msgtype"=>"news",
        "news"=>{
            "articles"=> [
             {
                 "title"=>"Happy Day",
                 "description"=>"Is Really A Happy Day",
                 "url"=>"http://www.baidu.com",
                 "picurl"=>""
             },
             {
                 "title"=>"Happy Day",
                 "description"=>"Is Really A Happy Day",
                 "url"=>"URL",
                 "picurl"=>"PIC_URL"
             }
             ]
        }
    }

    res = post("/customservice/kfaccount/add",json.to_json)
  end


  def upload_news

content = <<EOF
<section style="color: rgb(51, 51, 51); font-family: 微软雅黑; font-size: 12px; white-space: normal; max-width: 100%; word-wrap: break-word !important; box-sizing: border-box !important;">
    <section style="max-width: 100%; word-wrap: break-word !important; box-sizing: border-box !important;">
        <section style="max-width: 100%; word-wrap: break-word !important; box-sizing: border-box !important;">
            <section style="max-width: 100%; color: rgb(34, 34, 34); font-family: 微软雅黑, arial, sans-serif; font-size: 14px; height: 75px; word-wrap: break-word !important; box-sizing: border-box !important; background-color: rgb(255, 255, 255);">
                <section class="main" style="max-width: 100%; border-radius: 50px; padding: 5px; border: 2px solid rgb(0, 187, 236); margin: 0px; word-wrap: break-word !important; box-sizing: border-box !important;">
                    <section style="max-width: 100%; display: inline-block; float: left; height: 60px; width: 60px; word-wrap: break-word !important; box-sizing: border-box !important;">
                        <img class="awb_avatar" data-src="http://h.hiphotos.baidu.com/image/pic/item/b7003af33a87e950ba400ba312385343faf2b4ae.jpg" data-ratio="1" data-w="60" _width="60px" src="http://mmbiz.qpic.cn/mmbiz/6xsuhALdNEoFB5eapCqeuia18ObeXj6K3Ie7veWsvQvLRhGXYmxMwvJG77fNvXcDW8qKRGnEWpNibKEBxfeaHRyw/0" style="border: 0px; max-width: 100%; border-radius: 30px; float: left; word-wrap: break-word !important; box-sizing: border-box !important; height: auto !important; width: 60px !important; visibility: visible !important;"/><img data-src="http://mmbiz.qpic.cn/mmbiz/6xsuhALdNEr4HZ3cZd0MRCkfxXIick5qdcE61QpbRBPVU0gWLpXXQz0eiaEDV4CP37gJoecYWwpKbbia6mn4yZa0g/0" data-ratio="1" data-w="20" src="http://mmbiz.qpic.cn/mmbiz/6xsuhALdNEr4HZ3cZd0MRCkfxXIick5qdcE61QpbRBPVU0gWLpXXQz0eiaEDV4CP37gJoecYWwpKbbia6mn4yZa0g/0" style="border: 0px; max-width: 100%; float: right; margin-top: -60px; word-wrap: break-word !important; box-sizing: border-box !important; height: auto !important; width: auto !important; visibility: visible !important;"/>
                    </section>
                    <section style="max-width: 100%; display: inline-block; height: 60px; padding: 0px 10px; line-height: 30px; word-wrap: break-word !important; box-sizing: border-box !important;">
                        <section style="max-width: 100%; border-bottom-width: 1px; border-bottom-color: rgb(118, 118, 118); border-bottom-style: dashed; word-wrap: break-word !important; box-sizing: border-box !important;">
                            <span style="max-width: 100%; color: rgb(0, 0, 0); font-weight: bold; word-wrap: break-word !important; box-sizing: border-box !important;">点击「<span style="max-width: 100%; color: rgb(22, 179, 255); word-wrap: break-word !important; box-sizing: border-box !important;">箭头所指处</span>」可快速关注</span>
                        </section>
                        <section style="max-width: 100%; word-wrap: break-word !important; box-sizing: border-box !important;">
                            <span style="max-width: 100%; color: rgb(0, 0, 0); word-wrap: break-word !important; box-sizing: border-box !important;">微信号：<span class="awb_wxwechatid" style="max-width: 100%; color: rgb(187, 0, 0); word-wrap: break-word !important; box-sizing: border-box !important;">iweizhuli</span></span>
                        </section>
                    </section>
                </section>
                <section style="max-width: 100%; margin: -98px 0px 0px 80px; word-wrap: break-word !important; box-sizing: border-box !important;">
                    <p class="main" style="padding: 0px; margin-top: 0px; margin-bottom: 0px; max-width: 100%; word-wrap: normal; min-height: 1em; white-space: pre-wrap; width: 0px; height: 0px; border-width: 12px; border-style: solid; border-color: transparent transparent rgb(0, 187, 236); float: none; box-sizing: border-box !important;">
                        <br style="max-width: 100%; word-wrap: break-word !important; box-sizing: border-box !important;"/>
                    </p>
                    <p style="padding: 0px; margin-top: -21px; margin-bottom: 0px; max-width: 100%; word-wrap: normal; min-height: 1em; white-space: pre-wrap; width: 0px; height: 0px; border-width: 12px; border-style: solid; border-color: transparent transparent rgb(255, 255, 255); float: none; box-sizing: border-box !important;">
                        <br style="max-width: 100%; word-wrap: break-word !important; box-sizing: border-box !important;"/>
                    </p>
                </section>
            </section>
        </section>
    </section>
</section>
<p style="padding: 0px; margin-top: 0px; margin-bottom: 0px; color: rgb(51, 51, 51); font-family: 微软雅黑; font-size: 12px; white-space: normal;">
    <br/>
</p>
<p style="padding: 0px; margin-top: 0px; margin-bottom: 0px; color: rgb(51, 51, 51); font-family: 微软雅黑; font-size: 12px; white-space: normal;">
    <br/>
</p>
<p style="padding: 0px; margin-top: 0px; margin-bottom: 0px; color: rgb(51, 51, 51); font-family: 微软雅黑; font-size: 12px; white-space: normal;">
    <br/>
</p>
<p>
    <br/>
</p>
<p>
    <img src="http://www.weixingate.com/test/weixin_img.php" style="float: left;"/>
</p>


EOF

    data = {
      "articles"=> [
        {
          # resource : curl -F media=@50yuan.jpg "http://file.api.weixin.qq.com/cgi-bin/media/upload?access_token=TOKEN&type=image
          "thumb_media_id"=>"58x92JRaeqh985EUob6tCf-q63PdgH6of4IPJP8S4DguSxm8pU43b_krPobKCztS",
          "author"=>"test",
          "title"=>"Happy Day",
          "content_source_url"=>"www.qq.com",
          "content"=>content,
          "digest"=>"digest",
          "show_cover_pic"=>"1"
        }
      ]
    }

    res = post("/cgi-bin/media/uploadnews", data.to_json)
  end

  def upload_media

  end



  def get(path,params)

    token = get_token
    http = Net::HTTP.new("api.weixin.qq.com",443)
    http.use_ssl = true


    params = {access_token:token}.merge(params).to_query
    res = http.get("#{path}?#{params}")

  end


  def post(path,data)
    token = get_token
    http = Net::HTTP.new("api.weixin.qq.com",443)
    http.use_ssl = true
    
    params = {access_token:token}.to_query
    res = http.post("#{path}?#{params}",data)

  end

end






