# -*- encoding : utf-8 -*-
class WeixinMessagesController < ApplicationController
  skip_before_filter :verify_authenticity_token

  def index
    if params[:echostr].present?
      render :text=>params[:echostr]
    else
      render :text=>"ok"
    end
  end

  def create1

    xml = params["xml"].to_xml(:root=>"xml")
    puts xml


    p = {timestamp:params[:timestamp], nonce:params[:nonce], signature:params[:signature]}
    http = Net::HTTP.new("weixin.weizhuli.com")
    res = http.post("/weixin_messages?"+p.to_query, xml, 
      {'Content-Type' => 'text/xml', 
        'Content-Length' => xml.length.to_s, 
        "Connection" => "keep-alive" })

    res = res.body
    puts res

    render :text=>res
  end

  def create
    weixin = WeixinApi.new(:weizhuli)
    case params[:xml][:MsgType]
    when 'text'
      user_said = params[:xml][:Content]
      keyword_res = [
        {
          :keywords => %w{1},
          :res => weixin.response_text(params[:xml][:FromUserName],"test")
        },
        {
          :keywords => %w{2},
          :res => weixin.response_text(params[:xml][:FromUserName],"test")
        },
        {
          :keywords => %w{工作居住证 买房 购车摇号 购房 住房 居住证 买车 购车 摇号},
          :res => weixin.response_news(params[:xml][:FromUserName],[
            {
              title:"工作居住证",
              description:"",
              picurl:"http://intel-pb.weizhuli.com/test3/img/单位居住证.jpg",
              #url:"http://mp.weixin.qq.com/mp/appmsg/show?__biz=MzA5MjA1NjQxNQ==&appmsgid=10000012&itemidx=1&sign=3709ebd913316d96c5792b4eeb82ce27",
              url:"http://intel-pb.weizhuli.com/test3/index.html#one"
            }
          ])
        },
        {
          :keywords => %w{公积金   购房支取 租房支取 装修支取},
          :res => weixin.response_news(params[:xml][:FromUserName],[
            {
              title:"公积金支取",
              description:"",
              picurl:"http://intel-pb.weizhuli.com/test3/img/员工首次提取公积金.jpg",
              #url:"http://mp.weixin.qq.com/mp/appmsg/show?__biz=MzA5MjA1NjQxNQ==&appmsgid=10000012&itemidx=1&sign=3709ebd913316d96c5792b4eeb82ce27",
              url:"http://intel-pb.weizhuli.com/test3/index.html#two"
            }
          ])
        },
        {
          :keywords => %w{医疗报销  医保卡 医疗保险  变更医院 医保 保险},
          :res => weixin.response_news(params[:xml][:FromUserName],[
            {
              title:"医疗报销指南",
              description:"",
              picurl:"http://intel-pb.weizhuli.com/test3/img/基本医疗保险.jpg",
              #url:"http://mp.weixin.qq.com/mp/appmsg/show?__biz=MzA5MjA1NjQxNQ==&appmsgid=10000012&itemidx=1&sign=3709ebd913316d96c5792b4eeb82ce27",
              url:"http://intel-pb.weizhuli.com/test3/index.html#three"
            }
          ])
        },
        {
          :keywords => %w{生育服务证  准生证 独生子女  生育二胎  计划生育 生育 二胎},
          :res => weixin.response_news(params[:xml][:FromUserName],[
            {
              title:"生育服务证",
              description:"",
              picurl:"http://intel-pb.weizhuli.com/test3/img/一胎生育服务证.jpg",
              #url:"http://mp.weixin.qq.com/mp/appmsg/show?__biz=MzA5MjA1NjQxNQ==&appmsgid=10000012&itemidx=1&sign=3709ebd913316d96c5792b4eeb82ce27",
              url:"http://intel-pb.weizhuli.com/test3/index.html#four"
            }
          ])
        },
        {
          :keywords => %w{生育津贴  生育报销  生育保险 报销},
          :res => weixin.response_news(params[:xml][:FromUserName],[
            {
              title:"生育津贴",
              description:"",
              picurl:"http://intel-pb.weizhuli.com/test3/img/生育津贴.jpg",
              #url:"http://mp.weixin.qq.com/mp/appmsg/show?__biz=MzA5MjA1NjQxNQ==&appmsgid=10000012&itemidx=1&sign=3709ebd913316d96c5792b4eeb82ce27",
              url:"http://intel-pb.weizhuli.com/test3/pages/p5.html"
            }
          ])
        },
        {
          :keywords => %w{公休  假日  放假安排 法定假期 节假日},
          :res => weixin.response_news(params[:xml][:FromUserName],[
            {
              title:"公休假日安排",
              description:"",
              picurl:"http://intel-pb.weizhuli.com/test3/img/公休假日安排.jpg",
              #url:"http://mp.weixin.qq.com/mp/appmsg/show?__biz=MzA5MjA1NjQxNQ==&appmsgid=10000012&itemidx=1&sign=3709ebd913316d96c5792b4eeb82ce27",
              url:"http://intel-pb.weizhuli.com/test3/pages/p5.html"
            }
          ])
        },
        {
          :keywords => %w{定点医疗  医疗机构 社保  指定医院报销  医疗保险 看病 医保},
          :res => weixin.response_news(params[:xml][:FromUserName],[
            {
              title:"定点医疗机构",
              description:"",
              picurl:"http://intel-pb.weizhuli.com/test3/img/定点医疗机构.jpg",
              #url:"http://mp.weixin.qq.com/mp/appmsg/show?__biz=MzA5MjA1NjQxNQ==&appmsgid=10000012&itemidx=1&sign=3709ebd913316d96c5792b4eeb82ce27",
              url:"http://intel-pb.weizhuli.com/test3/pages/p7.html"
            }
          ])
        },
        {
          :keywords => %w{社保  养老保险金  社保缴费基数 退休金 农民工养老保险 工伤保险  医疗保险 社保标准  养老保险},
          :res => weixin.response_news(params[:xml][:FromUserName],[
            {
              title:"社保标准",
              description:"",
              picurl:"http://intel-pb.weizhuli.com/test3/img/社保标准.jpg",
              #url:"http://mp.weixin.qq.com/mp/appmsg/show?__biz=MzA5MjA1NjQxNQ==&appmsgid=10000012&itemidx=1&sign=3709ebd913316d96c5792b4eeb82ce27",
              url:"http://intel-pb.weizhuli.com/test3/pages/p8.html"
            }
          ])
        },
        {
          :keywords => %w{个税 计算},
          :res => weixin.response_news(params[:xml][:FromUserName],[
            {
              title:"个税计算器",
              description:"",
              picurl:"http://intel-pb.weizhuli.com/test3/img/个税计算器.jpg",
              #url:"http://mp.weixin.qq.com/mp/appmsg/show?__biz=MzA5MjA1NjQxNQ==&appmsgid=10000012&itemidx=1&sign=3709ebd913316d96c5792b4eeb82ce27",
              url:"http://intel-pb.weizhuli.com/test3/zhongzhi-tax.html"
            }
          ])
        },
        {
          :keywords => %w{年终奖 奖金},
          :res => weixin.response_news(params[:xml][:FromUserName],[
            {
              title:"年终奖计算器",
              description:"",
              picurl:"http://intel-pb.weizhuli.com/test3/img/年终奖计算器.jpg",
              #url:"http://mp.weixin.qq.com/mp/appmsg/show?__biz=MzA5MjA1NjQxNQ==&appmsgid=10000012&itemidx=1&sign=3709ebd913316d96c5792b4eeb82ce27",
              url:"http://intel-pb.weizhuli.com/test3/zhongzhi-bonus.html"
            }
          ])
        },
        {
          :keywords => %w{公司介绍 介绍},
          :res => weixin.response_news(params[:xml][:FromUserName],[
            {
              title:"公司介绍",
              description:"",
              picurl:"http://intel-pb.weizhuli.com/test3/img/公司介绍.jpg",
              #url:"http://mp.weixin.qq.com/mp/appmsg/show?__biz=MzA5MjA1NjQxNQ==&appmsgid=10000012&itemidx=1&sign=3709ebd913316d96c5792b4eeb82ce27",
              url:"http://intel-pb.weizhuli.com/test3/pages/p9.html"
            }
          ])
        },
        {
          :keywords => %w{解决方案},
          :res => weixin.response_news(params[:xml][:FromUserName],[
            {
              title:"解决方案",
              description:"",
              picurl:"http://intel-pb.weizhuli.com/test3/img/解决方案.jpg",
              #url:"http://mp.weixin.qq.com/mp/appmsg/show?__biz=MzA5MjA1NjQxNQ==&appmsgid=10000012&itemidx=1&sign=3709ebd913316d96c5792b4eeb82ce27",
              url:"http://intel-pb.weizhuli.com/test3/index.html"
            }
          ])
        },
        {
          :keywords => %w{招聘 职位},
          :res => weixin.response_news(params[:xml][:FromUserName],[
            {
              title:"欢迎加入中智",
              description:"",
              picurl:"http://intel-pb.weizhuli.com/test3/img/欢迎加入中智.jpg",
              url:"http://intel-pb.weizhuli.com/test3/pages/p120.html"
            },
            {
              title:"高端招聘",
              description:"",
              picurl:"http://intel-pb.weizhuli.com/test3/img/高端招聘.jpg",
              url:"http://intel-pb.weizhuli.com/test3/pages/p121.html"
            },
            {
              title:"外包招聘",
              description:"",
              picurl:"http://intel-pb.weizhuli.com/test3/img/外包招聘.jpg",
              url:"http://intel-pb.weizhuli.com/test3/pages/p122.html"
            },
          ])
        },
        {
          :keywords => %w{地址 电话 邮箱 乘车路线},
          :res => weixin.response_news(params[:xml][:FromUserName],[
            {
              title:"联系我们",
              description:"",
              picurl:"http://intel-pb.weizhuli.com/test3/img/联系我们.jpg",
              #url:"http://mp.weixin.qq.com/mp/appmsg/show?__biz=MzA5MjA1NjQxNQ==&appmsgid=10000012&itemidx=1&sign=3709ebd913316d96c5792b4eeb82ce27",
              url:"http://intel-pb.weizhuli.com/test3/map.html"
            }
          ])
        },
        {
          :keywords => %w{微博},
          :res => weixin.response_news(params[:xml][:FromUserName],[
            {
              title:"官方微博",
              description:"",
              picurl:"http://intel-pb.weizhuli.com/test3/img/官方微博.jpg",
              #url:"http://mp.weixin.qq.com/mp/appmsg/show?__biz=MzA5MjA1NjQxNQ==&appmsgid=10000012&itemidx=1&sign=3709ebd913316d96c5792b4eeb82ce27",
              url:"http://weibo.com/bjciic"
            }
          ])
        },
      ]

      reses = keyword_res.map{|conf|
        conf[:keywords].include?(user_said) ? conf[:res] : nil
      }

      res = reses.compact.first

    when 'event'

      if params[:xml][:Event] == "subscribe"
        res = weixin.response_text(params[:xml][:FromUserName], <<-EOF
您好，我是小智，感谢您关注中智北京！
进入【中智北京订阅号订阅号】并点击左上角的LOGO，在进入【查看历史信息】就可以看到当日或者更早的咨询~
输入序号查看相应的内容：
1.  最新沙龙活动
2.  最新文娱活动
EOF
)
        
      end

      params[:xml][:Event] == "CLICK" && case params[:xml][:EventKey]
      when "btn_jobs"
        res = weixin.response_news(params[:xml][:FromUserName],[
            {
              title:"中智自有招聘",
              description:"",
              picurl:"http://intel-pb.weizhuli.com/test3/img/欢迎加入中智.jpg",
              url:"http://intel-pb.weizhuli.com/test3/pages/p120.html"
            },
            {
              title:"高端招聘",
              description:"",
              picurl:"http://intel-pb.weizhuli.com/test3/img/高端招聘.jpg",
              url:"http://intel-pb.weizhuli.com/test3/pages/p121.html"
            },
            {
              title:"外包招聘",
              description:"",
              picurl:"http://intel-pb.weizhuli.com/test3/img/外包招聘.jpg",
              url:"http://intel-pb.weizhuli.com/test3/pages/p122.html"
            },
          ])
      when "btn_test1"
        res = weixin.response_text(params[:xml][:FromUserName],"纯文本消息")
      when "btn_tax_cal"

        res = weixin.response_text(params[:xml][:FromUserName],"请选择您要使用的计算方式：\n1. 根据税前工资计算税后,点击\nhttp://t.cn/8sKDe9e  \n2.根据税后工资计算税前,点击\nhttp://t.cn/8sKDgPc")


      when "btn_introduce","btn_test2"
        res = weixin.response_news(params[:xml][:FromUserName],[
            {
              title:"微助力社会化媒体管理平台",
              description:"",
              picurl:"http://mmbiz.qpic.cn/mmbiz/ZM080ibPW5f1Rmk5b0YkM7ia0G1BahuM6mAROjP1sPIgc4KcVwNIfxOhuZeEZRRYDDiatrknOazEhe2iacHU8OW5tw/0",
              #url:"http://mp.weixin.qq.com/mp/appmsg/show?__biz=MzA5MjA1NjQxNQ==&appmsgid=10000012&itemidx=1&sign=3709ebd913316d96c5792b4eeb82ce27",
              url:"http://t.cn/8kyRkXX"
            },
            {
              title:"微日报，通过短信、微信免费订阅社交账号每日运营数据",
              description:"",
              picurl:"http://mmbiz.qpic.cn/mmbiz/ZM080ibPW5f1Rmk5b0YkM7ia0G1BahuM6mvGqpWcibaEIKb7YsgMEfdEicaNydCHjtmgnHfpmKmU2o6QsMDKPZJxJA/0",
              #url:"http://mp.weixin.qq.com/mp/appmsg/show?__biz=MzA5MjA1NjQxNQ==&appmsgid=10000012&itemidx=2&sign=ec7f4c0ccb9afa1b972c11c06ff4c3eb",
              url:"http://t.cn/8kyReFw"
            },
            {
              title:"微预警，短信与邮件提醒，实时监控社交网络舆情危机",
              description:"",
              picurl:"http://mmbiz.qpic.cn/mmbiz/ZM080ibPW5f1Rmk5b0YkM7ia0G1BahuM6mbhBpvJSQbhicWYyDKjSXibUjiboFGB7k06qV446F6LebpswWkGm2LeOZg/0",
              #url:"http://mp.weixin.qq.com/mp/appmsg/show?__biz=MzA5MjA1NjQxNQ==&appmsgid=10000012&itemidx=3&sign=1a55c6e8c23cb8d5da90f668f21482fe",
              url:"http://t.cn/8kLfMP2",
            },
          ])

      when "btn_cases"
        res = weixin.response_news(params[:xml][:FromUserName],[
            {
              title:"领先的数字营销媒体监测服务",
              description:"",
              picurl:"http://mmbiz.qpic.cn/mmbiz/ZM080ibPW5f1Rmk5b0YkM7ia0G1BahuM6mUFGicpI4KHLq1beMYUxyXibDPNoiaQ7p88zGPOQ7YLJ5pppMsviadWP0RA/0",
              #url:"http://mp.weixin.qq.com/mp/appmsg/show?__biz=MzA5MjA1NjQxNQ==&appmsgid=10001003&itemidx=1&sign=043131e783251487b88e4ebe5f1d3b28",
              url:"http://t.cn/8kyRFGp",
            },
            {
              title:"专注企业微博策略咨询及执行",
              description:"",
              picurl:"http://mmbiz.qpic.cn/mmbiz/ZM080ibPW5f1Rmk5b0YkM7ia0G1BahuM6mxAPicKyu1OicvVMAqY7fcialBIEk2aPRadBF0p5FzSrszLKS6Is9CErVQ/0",
              #url:"http://mp.weixin.qq.com/mp/appmsg/show?__biz=MzA5MjA1NjQxNQ==&appmsgid=10001003&itemidx=2&sign=41fe6cea48b8105d55b4ae1ee3432fdb",
              url:"http://t.cn/8kyRFFr",
            },
            {
              title:"企业级社交网络应用订制开发",
              description:"",
              picurl:"http://mmbiz.qpic.cn/mmbiz/ZM080ibPW5f1Rmk5b0YkM7ia0G1BahuM6moqk37Uwpyt2NX6ghQyMPNY5Oqsmd6VSLypuxpZT192FFIMeVoYs1gA/0",
              #url:"http://mp.weixin.qq.com/mp/appmsg/show?__biz=MzA5MjA1NjQxNQ==&appmsgid=10001003&itemidx=3&sign=98645fdbc83f50f9600ca01de1ee8bdd",
              url:"http://t.cn/8kyEvzk",
            },
            {
              title:"7年活动营销、战役推广经验",
              description:"",
              picurl:"http://mmbiz.qpic.cn/mmbiz/ZM080ibPW5f1Rmk5b0YkM7ia0G1BahuM6mZvicQKibxibf1JxMWUcrr0oEBicOQWicXgYjQX4e8vqGGH9Q4LlkMLaY41w/0",
              #url:"http://mp.weixin.qq.com/mp/appmsg/show?__biz=MzA5MjA1NjQxNQ==&appmsgid=10001003&itemidx=4&sign=0042feef6ce36958f6cc551b25d1be11",
              url:"http://t.cn/8kyEPh3",
            },
          ])

      when "btn_about_us"
        res = weixin.response_text(params[:xml][:FromUserName],"我们为您提供免费的微博数据分析日报服务")
      when "btn_help"
        res = weixin.response_text(params[:xml][:FromUserName],"建设中, 敬请关注...")
      when "btn_daily_report"
        res = weixin_res_report_link params[:xml][:FromUserName]

      when "btn_member_query"
        res = weixin.response_text(params[:xml][:FromUserName],"查询功能建设中, 敬请关注...")
      when "btn_member_reg"
        res = weixin_res_reg_link params[:xml][:FromUserName]

      when "btn_member_send_report"
      user_profile = UserProfile.where(weixin_openid:params[:xml][:FromUserName]).first
      if user_profile && user_profile.user.authentications.present?

        res = weixin.response_text(params[:xml][:FromUserName],"微日报邮件已发送到您的注册 邮箱中, 请查收.")

        WeixinReportMailWorker.new.perform(user_profile.user_id)
      else
        res = weixin.response_text(params[:xml][:FromUserName],"您还没有绑定过微博, 请先绑定微博")
      end
      else
        res = weixin.response_text(params[:xml][:FromUserName],"请查看帮助")
      end

    else  'voice'

      rec = params[:xml][:Recognition]
      case
      when [/[查|看].*日报/].map{|reg| reg.match(rec)}.compact.present?
        res = weixin_res_report_link params[:xml][:FromUserName]

      when [/注册/].map{|reg| reg.match(rec)}.compact.present?
        res = weixin_res_reg_link params[:xml][:FromUserName]
      else
        res = weixin.response_text(params[:xml][:FromUserName],"请查看帮助")
      end


    end
      
    puts res

    render :text=>res
  end







:private

  def shorten_url(path)
    url = "http://pb.weizhuli.com"+path
    shorten_res = JSON.parse(URI.parse("https://api.weibo.com/2/short_url/shorten.json?source=3778658839&url_long=#{url}").read)
    url = shorten_res['urls'][0]['url_short']
  end


  def weixin_res_report_link(from_user_name)

    weixin = WeixinApi.new(:weizhuli)

    url = shorten_url reports_dailies_path(weixin_openid:from_user_name)

    res = weixin.response_news(from_user_name,[
        {
          title:"查看您的日报",
          description:"desc",
          picurl:"",
          url:url,
        }
      ])


  end


  def weixin_res_reg_link(from_user_name)

    # user_profile = UserProfile.where(weixin_openid:from_user_name).first
    # if user_profile && user_profile.user.authentications.present?
    #   WeixinApi.new.response_text(from_user_name,"您已经绑定过帐号了")
    # else
      weixin = WeixinApi.new(:weizhuli)

      url = shorten_url new_reports_user_path(weixin_openid:from_user_name)
      res = WeixinApi.new(:weizhuli).response_text(from_user_name,"注册并绑定您的微博帐户: #{url}")
    # end

  end

end

