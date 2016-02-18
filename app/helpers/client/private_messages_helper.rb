# -*- encoding : utf-8 -*-
module Client::PrivateMessagesHelper


  def private_message_content(content)
	b = "[a-zA-z]+:\/\/[^\\s]*"
	url = content.match(b)
        link = link_to(url.to_s,url.to_s, :target=>"_blank")
	result = content.gsub(/#{b}/m, link)
	result = result.gsub("&lt;",'<')
  end




end
