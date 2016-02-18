# -*- encoding : utf-8 -*-
class MTqqWeiboContent
  include MongoMapper::Document

  belongs_to  :source,  :class=>"MTqqSourceStatus"
end

