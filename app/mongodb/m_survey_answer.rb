# -*- encoding : utf-8 -*-
class MSurveyAnswer
  include MongoMapper::Document

  timestamps!

  def self.export
    records = []
    records << %w{
      id
      您希望在【中智北京】订阅号中看到那些内容信息
      --其它
      “智服务”栏目内的文章长度，您觉得是否合理
      “智服务”选取的流程文章，是您（您的客户）最常需要的吗
      --去掉或增加
      您对“智查询”栏目设置的“非交互式查询”内容的意见
      --去掉或增加
      您对“中智北京”栏目设置的意见
      --去掉或增加
      您对“自动回复”内容的意见
      --去掉或增加
      您是否愿意向朋友推荐并分享中智北京微信的内容
      意见或者建议
      姓名
      公司
      电话
      微信昵称
      提交时间
    }
    all_answers = self.all
    all_answers.each{|a|
      row = []
      row << a.id
      row << (a.answer ? (a.answer['s_1_1']||[])*"," : "")
      row << (a.answer ? a.answer['a_1_1'] : "")
      row << (a.answer ? a.answer['s_2_1'] : "")
      row << (a.answer ? a.answer['s_3_1'] : "")
      row << (a.answer ? a.answer['a_3_1'] : "")
      row << (a.answer ? a.answer['s_4_1'] : "")
      row << (a.answer ? a.answer['a_4_1'] : "")
      row << (a.answer ? a.answer['s_5_1'] : "")
      row << (a.answer ? a.answer['a_5_1'] : "")
      row << (a.answer ? a.answer['s_6_1'] : "")
      row << (a.answer ? a.answer['a_6_1'] : "")
      row << (a.answer ? a.answer['s_7_1'] : "")
      row << (a.answer ? a.answer['a_8_1'] : "")
      row << (a.info ? a.info["name"] : "")
      row << (a.info ? a.info["company"] : "")
      row << (a.info ? a.info["phone"] : "")
      row << (a.info ? a.info["weixin_name"] : "")
      row << (a.created_at ? a.created_at.strftime("%Y-%m-%d %H:%S") : "")
      records << row
    }

    records << []<< [] << ["多选汇总"]
    ms = all_answers.map{|a| a.answer['s_1_1']}.flatten.inject(Hash.new(0)) { |h, e| h[e] += 1 ; h }.to_a.sort{|a,b| b[1]<=>a[1]}
    ms.each{|l| records << l}    
    records
  end
end

