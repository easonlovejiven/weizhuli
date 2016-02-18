# -*- encoding : utf-8 -*-
module Client::WeiboUsersHelper
  def sort_type(origin_col,sort_col,sort_type)
      case
      when sort_type.blank? then
        '0'
      when origin_col == sort_col && sort_type == '1' then
        '0'
      when origin_col == sort_col && sort_type == '0' then 
        '1'
      else
        '0'
      end

  end

  def sort_label(origin_col,sort_col,sort_type)
    if origin_col == sort_col
      if sort_type == '1'
        "↑"
      else
        "↓"
      end
    else
      ""
    end
  end
end
