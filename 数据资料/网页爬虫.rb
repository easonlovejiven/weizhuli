#抓取列子
  
  require 'open-uri'
  filename = "URL.csv"
  CSV.open filename,"wb" do |csv|
    csv << %w{URL}
    url = "https://ruby-china.org/"
    open(url) do |page|
      page_content = page.read()
      links = page_content.scan(/<a href=\"(.*?)\"/).flatten
      links.each {|link|
        csv << [link]
      }
    end
  end
