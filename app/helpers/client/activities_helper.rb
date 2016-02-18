# -*- encoding : utf-8 -*-
module Client::ActivitiesHelper


  def activity_time(date)
    d = DateTime.now
    
    if date < Date.today
      I18n.l(date,:format=>:all_time)
    else
      interval = d.to_i - date.to_i
      if interval > 3600
        "#{I18n.t("date.today")} #{I18n.l(date,:format=>:time_short)}"
      else
        times = [[60, :seconds], [60, :minutes]].map{ |count, name|
          if interval > 0
            interval, n = interval.divmod(count)
            "#{n.to_i} #{I18n.t("date."+name.to_s)}"
          end
        }.compact.reverse
        times = ["1 #{I18n.t("date.seconds")}"] if times.blank?
        times.join(' ')+I18n.t("date.ago")
      end
    end
    	
    
  end

  def activity_content(content)
	b = "[a-zA-z]+:\/\/[^\\s]*"
	url = content.match(b)
        link = link_to(url.to_s,url.to_s, :target=>"_blank")
	result = content.gsub(/#{b}/m, link)
	result = result.gsub("&lt;",'<')
  end

end
