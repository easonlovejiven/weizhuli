# -*- encoding : utf-8 -*-
module SearchFormHelper

  def search_form_city_groups
    py = Pinyin.new
    # cities group by 拼音首字母
    cities = City.available
    cities_group = {}
    cities.each{|city|
      (cities_group[py.to_pinyin(city.name).first] ||=[]) << city
    }
    cities_group.to_a.sort!{|a,b|a[0]<=>b[0]}
    cities_group
  end


  def search_form_auto_branches
    AutoBrand.includes(:autos).order("auto_brands.name").where("autos.id is not null")
  end


end
