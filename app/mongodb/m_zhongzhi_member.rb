# -*- encoding : utf-8 -*-
class MZhongzhiMember
  # 中智会员信息

  include MongoMapper::Document


  key :openid, String
  key :member_id, String
  key :cards, Array
  key :card, String

  key :name,  String
  key :phone, String
  key :company, String
  key :title, String
  key :wxname, String
  


  timestamps!



  # 生成会员卡ID 和 100×5代金券
  def gen_member_id


    mid = (1..4).to_a.map{|i|(rand*10).to_i}.join

    self.member_id = "AC"+mid
    cards = []
    1.upto(5){|i|
      cards << "D1141231"+mid+i.to_s
    }
    self.cards = cards
    self.save
  end

  # 生成 500元代金券
  def gen_card
    self.card = "D5141231"+self.member_id.gsub("AC","")+(rand*10).to_i.to_s
    self.save
  end
end
