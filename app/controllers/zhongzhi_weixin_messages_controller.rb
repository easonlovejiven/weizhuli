# -*- encoding : utf-8 -*-
class ZhongzhiWeixinMessagesController < ApplicationController
  skip_before_filter :verify_authenticity_token

  def index
    if params[:echostr].present?
      render :text=>params[:echostr]
    else
      render :text=>"ok"
    end
  end


  def create
    weixin = WeixinApi.new(:zhongzhi)
    case params[:xml][:MsgType]
    when 'text'
      user_said = params[:xml][:Content]
      keyword_res = [
        {
          :keywords => /^DX.{4}/,
          :process => ->{
            code = MZhongzhiPrizeCode.find_by_code(user_said.upcase)
            if code
              return weixin.response_text(params[:xml][:FromUserName],code.text)
            else
              return nil
            end
          },
        },
        {
          :keywords => %w{测试},
          :res => weixin.response_text(params[:xml][:FromUserName],'测试一下！！！')
        },
        {
          :keywords => %w{CD cd},
          :res => weixin.response_text(params[:xml][:FromUserName],'亲，你好聪明啊，你答对了。如果你是第一个到车长处领奖的，你将获得水晶笔2支。')
        },
        {
          :keywords => %w{真相大白},
          :res => weixin.response_text(params[:xml][:FromUserName],'亲，你好聪明啊，你答对了。如果你是第一个到车长处领奖的，你将获得星巴克咖啡券1张。')
        },
        {
          :keywords => %w{海豹},
          :res => weixin.response_text(params[:xml][:FromUserName],'亲，你好聪明啊，你答对了。现在小智请你为大家唱一首包含“春天”元素的歌曲吧，唱的好小智有大奖哦～')
        },
        {
          :keywords => %w{巧克力棒},
          :res => weixin.response_text(params[:xml][:FromUserName],'亲，你好聪明啊，你答对了。如果你是第一个到车长处领奖的，你将获得水晶笔2支。')
        },
        {
          :keywords => %w{电路},
          :res => weixin.response_text(params[:xml][:FromUserName],'亲，你好聪明啊，你答对了。如果你是第一个到车长处领奖的，你将获得星巴克咖啡券1张。')
        },
        {
          :keywords => %w{羊},
          :res => weixin.response_text(params[:xml][:FromUserName],'亲，你好聪明啊，你答对了。如果你是第一个到车长处领奖的，你将获得水晶笔2支。')
        },
        {
          :keywords => %w{柬埔寨},
          :res => weixin.response_text(params[:xml][:FromUserName],'亲，你好聪明啊，你答对了。现在小智请你为大家唱一首包含“春天”元素的歌曲吧，唱的好小智有大奖哦～')
        },
        {
          :keywords => %w{杨桃},
          :res => weixin.response_text(params[:xml][:FromUserName],'亲，你好聪明啊，你答对了。如果你是第一个到车长处领奖的，你将获得星巴克咖啡券1张。')
        },
        {
          :keywords => %w{巴黎},
          :res => weixin.response_text(params[:xml][:FromUserName],'亲，你好聪明啊，你答对了。如果你是第一个到车长处领奖的，你将获得中智纪念笔记本1本。')
        },
        {
          :keywords => %w{炸弹},
          :res => weixin.response_text(params[:xml][:FromUserName],'亲，你好聪明啊，你答对了。如果你是第一个到车长处领奖的，你将获得水晶笔2支。')
        },
        {
          :keywords => %w{A06 a06},
          :res => weixin.response_text(params[:xml][:FromUserName],'学会接受不完美，你在职场上给人和善的印象，不太会参与利益争夺的纠纷当中，与同事的关系通常能够维持在客气但不疏远的状态，可实际上你十分相信自己的能力，当你遇到一些不够完美的事情的时候，会执着于修改到完美，从而不断挑战领导的权威，或不断挑剔同事的工作成果。你在职场上最需要学习的，是接受不完美和平庸，尤其是不需要你承担结果的事情。')
        },
        {
          :keywords => %w{B06 b06},
          :res => weixin.response_text(params[:xml][:FromUserName],'学会吃点小亏，你虽然是一个具有浪漫情怀的人，但职场上却是精明的。不但善于察言观色，避重就轻，更加善于权衡利弊，但是在职场上太过精明并不是件好事。虽然你在职场上表现的无害，容易让别人对你卸下防备，一次两次也许还没人察觉，多了大家就会发现你的小算盘了。你在职场上最需要学习的，是不要把得失计算得太清楚，其实有时候吃亏未必不是福气。')
        },
        {
          :keywords => %w{C06 c06},
          :res => weixin.response_text(params[:xml][:FromUserName],'学会闭紧嘴巴，职场是个利益关系复杂的地方，虽然你善于对某人察言观色，却通常对大局缺乏清晰的认识。也许你以为看准了领导的脸色、讲对了话，可是却无意中得罪了其他的人。职场上要捧一个人也许很难，但要坑一个人那就真的容易多了。而且你火大的时候不容易控制自己的嘴巴，把不该讲的也讲了。你在职场上要学会能沉默的时候尽量沉默。')
        },
        {
          :keywords => %w{D06 d06},
          :res => weixin.response_text(params[:xml][:FromUserName],'学会请示领导，你在职场上从来不吝于表现自己的能力、表达自己的意见，也乐于自己承担责任。如果你是领导，你会是受员工喜爱的领导。但如果你不是，还是要低调一些得好。这无关你的能力，而是你的领导有他身为领导的权威。当你觉得自己的能力得不到肯定的时候，学会在重大事项方面，先向你的领导请示。')
        },
        {
          :keywords => %w{A05 a05},
          :res => weixin.response_text(params[:xml][:FromUserName],'你与踏实勤恳的同事最来电。你喜欢老实稳重的人，尽管你对投机家也十分钦佩，但你还是更愿意跟老实的人来往。办公室里，假如有那种每天都埋头干活，从不讲人闲话，从不对工作进行挑三拣四的选择，从不畏惧困难，不抱怨，不懒惰的同事，你一定会跟对方十分合拍，甚至有来电的感觉。')
        },
        {
          :keywords => %w{B05 b05},
          :res => weixin.response_text(params[:xml][:FromUserName],'你与乐观上进的同事最来电。你最讨厌成天拉长脸，遇到一点点事就怨言连天，就跟天塌下来一样痛苦，看问题只会朝悲观的一面看，有事没事就爱搬弄是非，唯恐天下不乱的人。相反，个性乐观，积极上进，遇到困难敢于迎上去，以自信和勇气接受挑战的人是最令你感到欣赏的。办公室里，你跟乐观勇敢的同事是最来电的。')
        },
        {
          :keywords => %w{C05 c05},
          :res => weixin.response_text(params[:xml][:FromUserName],'你与聪明伶俐的同事最来电。你讨厌跟木讷呆滞的人合作，你认为能办事的人都是眼疾手快的，至少要有基本的眼力见。职场上，你最看好聪明机灵的同事，你欣赏对方的办事能力，你觉得头脑灵活度与是否能成功有很大的关系，如果一个人不够聪明，光凭吃苦耐劳获得成功，速度真的比乌龟还慢。')
        },
        {
          :keywords => %w{D05 d05},
          :res => weixin.response_text(params[:xml][:FromUserName],'你与能言善辩的同事最来电。你不喜欢嘴巴笨拙的人。你讨厌听到丧气话，不会说话的人交际能力差，或者说根本不具备交际能力。你喜欢跟口舌伶俐的人来往，这样能锻炼自己的口才，而且听对方说话，也会觉得很舒服，能学到很多，职场中遇到这种同事，你会觉得很来电。')
        },
        {
          :keywords => %w{A03 a03},
          :res => weixin.response_text(params[:xml][:FromUserName],'选择【靠窗口的位置】：你是个个性独立的人，注重个人空间，喜欢有一定的时间和空间独处 ;内心有着较强的表现欲，只不过这种欲望并不一定表现出来;有时候做事有些冲动，热情来了会先行动后思考')
        },
        {
          :keywords => %w{B03 b03},
          :res => weixin.response_text(params[:xml][:FromUserName],'选择【靠过道的位置】：你是个自我保护意识很强的人，做事比较谨慎小心;不愿意受到外界过多的约束，喜欢自由自在的感觉;对个人空间的要求比较高。')
        },
        {
          :keywords => %w{C03 c03},
          :res => weixin.response_text(params[:xml][:FromUserName],'选择【靠门的位置】：你是个喜好自由的人，对自己的事业比较热衷，但不会只有事业而没有生活。这种类型的人，讲究生活品质，不会为金钱卖命。')
        },
        {
          :keywords => %w{D03 d03},
          :res => weixin.response_text(params[:xml][:FromUserName],'选择【中间的位置】：你是个喜欢顺其自然的人，希望过优哉游哉的日子，没有压力，没有伤害，只要平平安安，心灵宁静就好了。虽然说也有对新生事物的好奇心，但一旦感觉到对自己不利，往往就不会参与，在这一点上十分理智。')
        },
        {
          :keywords => %w{123},
          :res => weixin.response_text(params[:xml][:FromUserName],'您好，请点击： http://t.cn/RPnENcn ，进入中智HR沙龙评估表。')
        },
        {
          :keywords => %w{3},
          :process => ->{create_member(params[:xml][:FromUserName])},
          :res => weixin.response_text(params[:xml][:FromUserName],"恭喜您获得了我们赠送的中智大礼包，包括HR沙龙会员卡，及沙龙课程代金券，详情请点击: #{shorten_url("http://ciicbj.weizhuli.com/ciic/members?wxopenid=#{params[:xml][:FromUserName]}")}")
        },
        {
          :keywords => %w{1},
          :res => weixin.response_text(params[:xml][:FromUserName],"请点击链接查看最新沙龙 #{shorten_url("http://www.ciicbj.com/template/EmailIndex.aspx?EmailId=1641")}")
        },
        {
          :keywords => %w{2},
          :res => weixin.response_text(params[:xml][:FromUserName],"请点击链接查看最新文娱活动 #{shorten_url("http://www.ciicbj.com/YGFW/YGSH/default.aspx")}")
        },
        {
          :keywords => %w{工作居住证 买房 购车摇号 购房 住房 居住证 买车 购车 摇号},
          :res => weixin.response_news(params[:xml][:FromUserName],[
            {
              title:"工作居住证的申请资格",
              description:"",
              picurl:"http://ciicbj.weizhuli.com/test3/img/单位居住证.jpg",
              #url:"http://mp.weixin.qq.com/mp/appmsg/show?__biz=MzA5MjA1NjQxNQ==&appmsgid=10000012&itemidx=1&sign=3709ebd913316d96c5792b4eeb82ce27",
              url:"http://ciicbj.weizhuli.com/test3/index.html#one"
            }
          ])
        },
        {
          :keywords => %w{公积金 购房支取 租房支取 装修支取},
          :res => weixin.response_news(params[:xml][:FromUserName],[
            {
              title:"公积金支取所需的材料与办理流程",
              description:"",
              picurl:"http://ciicbj.weizhuli.com/test3/img/员工首次提取公积金.jpg",
              #url:"http://mp.weixin.qq.com/mp/appmsg/show?__biz=MzA5MjA1NjQxNQ==&appmsgid=10000012&itemidx=1&sign=3709ebd913316d96c5792b4eeb82ce27",
              url:"http://ciicbj.weizhuli.com/test3/index.html#two"
            }
          ])
        },
        {
          :keywords => %w{医疗报销  医保卡 医疗保险  变更医院 医保 保险},
          :res => weixin.response_news(params[:xml][:FromUserName],[
            {
              title:"医疗报销指南所需的材料与说明",
              description:"",
              picurl:"http://ciicbj.weizhuli.com/test3/img/基本医疗保险.jpg",
              #url:"http://mp.weixin.qq.com/mp/appmsg/show?__biz=MzA5MjA1NjQxNQ==&appmsgid=10000012&itemidx=1&sign=3709ebd913316d96c5792b4eeb82ce27",
              url:"http://ciicbj.weizhuli.com/test3/index.html#three"
            }
          ])
        },
        {
          :keywords => %w{生育服务证  准生证 独生子女  生育二胎  计划生育 生育 二胎},
          :res => weixin.response_news(params[:xml][:FromUserName],[
            {
              title:"生育服务证的办理资料",
              description:"",
              picurl:"http://ciicbj.weizhuli.com/test3/img/一胎生育服务证.jpg",
              #url:"http://mp.weixin.qq.com/mp/appmsg/show?__biz=MzA5MjA1NjQxNQ==&appmsgid=10000012&itemidx=1&sign=3709ebd913316d96c5792b4eeb82ce27",
              url:"http://ciicbj.weizhuli.com/test3/index.html#four"
            }
          ])
        },
        {
          :keywords => %w{生育津贴  生育报销  生育保险 报销},
          :res => weixin.response_news(params[:xml][:FromUserName],[
            {
              title:"生育津贴所需材料",
              description:"",
              picurl:"http://ciicbj.weizhuli.com/test3/img/生育津贴.jpg",
              #url:"http://mp.weixin.qq.com/mp/appmsg/show?__biz=MzA5MjA1NjQxNQ==&appmsgid=10000012&itemidx=1&sign=3709ebd913316d96c5792b4eeb82ce27",
              url:"http://ciicbj.weizhuli.com/test3/pages/p5.html"
            }
          ])
        },
        {
          :keywords => %w{公休  假日  放假安排 法定假期 节假日},
          :res => weixin.response_news(params[:xml][:FromUserName],[
            {
              title:"公休假期安排查询",
              description:"",
              picurl:"http://ciicbj.weizhuli.com/test3/img/公休假日安排.jpg",
              #url:"http://mp.weixin.qq.com/mp/appmsg/show?__biz=MzA5MjA1NjQxNQ==&appmsgid=10000012&itemidx=1&sign=3709ebd913316d96c5792b4eeb82ce27",
              url:"http://ciicbj.weizhuli.com/test3/pages/p5.html"
            }
          ])
        },
        {
          :keywords => %w{定点医疗  医疗机构 社保  指定医院报销  医疗保险 看病 医保},
          :res => weixin.response_news(params[:xml][:FromUserName],[
            {
              title:"定点医疗机构指南",
              description:"",
              picurl:"http://ciicbj.weizhuli.com/test3/img/定点医疗机构.jpg",
              #url:"http://mp.weixin.qq.com/mp/appmsg/show?__biz=MzA5MjA1NjQxNQ==&appmsgid=10000012&itemidx=1&sign=3709ebd913316d96c5792b4eeb82ce27",
              url:"http://ciicbj.weizhuli.com/test3/pages/p7.html"
            }
          ])
        },
        {
          :keywords => %w{社保  养老保险金  社保缴费基数 退休金 农民工养老保险 工伤保险  医疗保险 社保标准  养老保险},
          :res => weixin.response_news(params[:xml][:FromUserName],[
            {
              title:"社保标准的查询",
              description:"",
              picurl:"http://ciicbj.weizhuli.com/test3/img/社保标准.jpg",
              #url:"http://mp.weixin.qq.com/mp/appmsg/show?__biz=MzA5MjA1NjQxNQ==&appmsgid=10000012&itemidx=1&sign=3709ebd913316d96c5792b4eeb82ce27",
              url:"http://ciicbj.weizhuli.com/test3/pages/p8.html"
            }
          ])
        },
        {
          :keywords => %w{个税 计算},
          :res => weixin.response_news(params[:xml][:FromUserName],[
            {
              title:"个税计算与查询",
              description:"",
              picurl:"http://ciicbj.weizhuli.com/test3/img/个税计算器.jpg",
              #url:"http://mp.weixin.qq.com/mp/appmsg/show?__biz=MzA5MjA1NjQxNQ==&appmsgid=10000012&itemidx=1&sign=3709ebd913316d96c5792b4eeb82ce27",
              url:"http://ciicbj.weizhuli.com/test3/zhongzhi-tax.html"
            }
          ])
        },
        {
          :keywords => %w{年终奖 奖金},
          :res => weixin.response_news(params[:xml][:FromUserName],[
            {
              title:"年终奖的计算与查询",
              description:"",
              picurl:"http://ciicbj.weizhuli.com/test3/img/年终奖计算器.jpg",
              #url:"http://mp.weixin.qq.com/mp/appmsg/show?__biz=MzA5MjA1NjQxNQ==&appmsgid=10000012&itemidx=1&sign=3709ebd913316d96c5792b4eeb82ce27",
              url:"http://ciicbj.weizhuli.com/test3/zhongzhi-bonus.html"
            }
          ])
        },
        {
          :keywords => %w{公司介绍 介绍},
          :res => weixin.response_news(params[:xml][:FromUserName],[
            {
              title:"中智北京公司介绍",
              description:"",
              picurl:"http://ciicbj.weizhuli.com/test3/img/公司介绍.jpg",
              #url:"http://mp.weixin.qq.com/mp/appmsg/show?__biz=MzA5MjA1NjQxNQ==&appmsgid=10000012&itemidx=1&sign=3709ebd913316d96c5792b4eeb82ce27",
              url:"http://ciicbj.weizhuli.com/test3/pages/p9.html"
            }
          ])
        },
        {
          :keywords => %w{解决方案},
          :res => weixin.response_news(params[:xml][:FromUserName],[
            {
              title:"周律师课堂解决方案",
              description:"",
              picurl:"http://ciicbj.weizhuli.com/test3/img/解决方案.jpg",
              #url:"http://mp.weixin.qq.com/mp/appmsg/show?__biz=MzA5MjA1NjQxNQ==&appmsgid=10000012&itemidx=1&sign=3709ebd913316d96c5792b4eeb82ce27",
              url:"http://ciicbj.weizhuli.com/test3/index.html"
            }
          ])
        },
        {
          :keywords => %w{招聘 职位},
          :res => weixin.response_news(params[:xml][:FromUserName],[
            {
              title:"欢迎加入中智北京",
              description:"",
              picurl:"http://ciicbj.weizhuli.com/test3/img/欢迎加入中智.jpg",
              url:"http://ciicbj.weizhuli.com/test3/pages/p120.html"
            },
            {
              title:"高端招聘最新信息",
              description:"",
              picurl:"http://ciicbj.weizhuli.com/test3/img/高端招聘.jpg",
              url:"http://ciicbj.weizhuli.com/test3/pages/p121.html"
            },
            {
              title:"外包招聘最新信息",
              description:"",
              picurl:"http://ciicbj.weizhuli.com/test3/img/外包招聘.jpg",
              url:"http://ciicbj.weizhuli.com/test3/pages/p122.html"
            },
          ])
        },
        {
          :keywords => %w{地址 电话 邮箱 乘车路线},
          :res => weixin.response_news(params[:xml][:FromUserName],[
            {
              title:"联系我们",
              description:"",
              picurl:"http://ciicbj.weizhuli.com/test3/img/联系我们.jpg",
              #url:"http://mp.weixin.qq.com/mp/appmsg/show?__biz=MzA5MjA1NjQxNQ==&appmsgid=10000012&itemidx=1&sign=3709ebd913316d96c5792b4eeb82ce27",
              url:"http://ciicbj.weizhuli.com/test3/map.html"
            }
          ])
        },
        {
          :keywords => %w{微博},
          :res => weixin.response_news(params[:xml][:FromUserName],[
            {
              title:"中智北京官方微博",
              description:"",
              picurl:"http://ciicbj.weizhuli.com/test3/img/官方微博.jpg",
              #url:"http://mp.weixin.qq.com/mp/appmsg/show?__biz=MzA5MjA1NjQxNQ==&appmsgid=10000012&itemidx=1&sign=3709ebd913316d96c5792b4eeb82ce27",
              url:"http://weibo.com/bjciic"
            }
          ])
        },
      ]

      reses = keyword_res.map{|conf|
        if conf[:keywords].is_a? Array
          conf[:keywords].include?(user_said) ? conf : nil
        elsif conf[:keywords].is_a? Regexp
          user_said.upcase =~ conf[:keywords] ? conf : nil
        end
      }.compact.first

      if reses
        num = 0
        res = reses[:process] && reses[:process].call
        res = reses[:res] if !reses[:res].nil?
      end
      

    when 'event'

      if params[:xml][:Event] == "subscribe"
        res = weixin.response_text(params[:xml][:FromUserName], <<-EOF
您好，我是小智，感谢您关注中智北京！
进入【中智北京】订阅号并点击左上角的LOGO，进入【查看历史信息】就可以看到当日或者更早的资讯~
输入序号查看相应的内容：
1.  最新沙龙活动
2.  最新文娱活动
3.  免费赠送大礼包
EOF
)
        
      end

      params[:xml][:Event] == "CLICK" && case params[:xml][:EventKey]
      when "btn_jobs"
        res = weixin.response_news(params[:xml][:FromUserName],[
            {
              title:"欢迎加入中智北京",
              description:"",
              picurl:"http://ciicbj.weizhuli.com/test3/img/欢迎加入中智.jpg",
              url:"http://ciicbj.weizhuli.com/test3/pages/p120.html"
            },
            {
              title:"高端招聘最新信息",
              description:"",
              picurl:"http://ciicbj.weizhuli.com/test3/img/高端招聘.jpg",
              url:"http://ciicbj.weizhuli.com/test3/pages/p121.html"
            },
            {
              title:"外包招聘最新信息",
              description:"",
              picurl:"http://ciicbj.weizhuli.com/test3/img/外包招聘.jpg",
              url:"http://ciicbj.weizhuli.com/test3/pages/p122.html"
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


  def create_member(openid)
    member = MZhongzhiMember.create(openid:openid)
    member.gen_member_id
  end


  def shorten_url(path)
    if path =~ /^http/
      url = path
    else
      url = "http://pb.weizhuli.com"+path
    end
    shorten_res = JSON.parse(URI.parse("https://api.weibo.com/2/short_url/shorten.json?source=3778658839&url_long=#{url}").read)
    url = shorten_res['urls'][0]['url_short']
  end


  def weixin_res_report_link(from_user_name)

    weixin = WeixinApi.new(:zhongzhi)

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
      weixin = WeixinApi.new(:zhongzhi)

      url = shorten_url new_reports_user_path(weixin_openid:from_user_name)
      res = WeixinApi.new(:zhongzhi).response_text(from_user_name,"注册并绑定您的微博帐户: #{url}")
    # end

  end

end

