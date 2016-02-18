# -*- encoding : utf-8 -*-
class MZhongzhiPrizeCode
  # 中智会员信息

  include MongoMapper::Document

  key :code,  String
  key :title, String
  key :text,  String

end

