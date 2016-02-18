
  #某个帐号的某个时间段内发布的微博
  
  require 'rseg'
  Rseg.load
  filename = "娜娜xph-buzz声量.csv" #针对每条微博的关键词量
  #全局变量统计关键词数量
    keywords = open '/home/rails/Desktop/keywords-buzz'#文件的路径
    keywords = keywords.read
    keywords = keywords.strip.split("\n")
    words_stats = {}
    keyword.each{|word|
      word = word.strip
      words_stats[word] = 0
  }
  CSV.open filename,"wb" do |csv|
    csv << %w{URL 出现次数}
    urls = open "/home/rails/Desktop/xph-url"
    urls = urls.read
    urls = urls.strip.split("\n")
    urls.each do |url|
        weibo_id = WeiboMidUtil.str_to_mid URI.parse(url.strip).path.split("/").last
        forwards = WeiboForward.where("weibo_id = ?",weibo_id)
        comments = WeiboComment.where("weibo_id = ?",weibo_id)
         # 转发
        if !forwards.blank?
          forwards.each do |forward|
            #得到一个用户信息对象
            forward_text = MForward.find_by_id(forward.forward_id)
            if !forward_text.blank?
              ftext = forward_text.text.strip
              @str = ""
                @keyword.each{|w|
                  @key = w.strip
                  if ftext.include?(@key)
                    @str += @key
                    @str = @str += ","
                    words_stats[@key] += 1
                  end
                }
              @str = @str[0,@str.length-1]
            end
          end
        end
      
        # 评论
        if !comments.blank?
          comments.each do |comment|
            #得到一个用户信息对象
            comment_text = MComment.find_by_id(comment.comment_id)
            if !comment_text.blank?
              @str = ""
              ctext = comment_text.text.strip
                @keyword.each{|w|
                  @key = w.strip
                  if ctext.include?(@key)
                    @str += @key
                    @str = @str += ","
                    words_stats[@key] += 1 
                  end
                }
              @str = @str[0,@str.length-1]
            end
          end
        end
      csv << [url,words_stats]
    end
  end
  
  #intel
  {"安腾"=>0, "Itanium"=>0, "凌动"=>1, "Atom"=>0, "Xeon"=>0, "酷睿i3"=>0, "酷睿i5"=>0, "酷睿i7"=>0, "Core i3"=>0, "Core i5"=>0, "Core i7"=>0, "Intel"=>7, "英特尔"=>483, "Intel 平板"=>0, "英特尔 平板"=>0, "PC平板2合1"=>0, "PC平板二合一"=>0, "二合一超极本"=>0, "二合一电脑"=>0, "平板PC2合1"=>0, "平板PC二合一"=>0}

  filename = "xph关键词排行.csv"
  CSV.open filename,"wb" do |csv|
    csv << %w{关键词 数量}
    status = {"安腾"=>0, "Itanium"=>0, "凌动"=>0, "Atom"=>2, "Xeon"=>0, "酷睿i3"=>5, "酷睿i5"=>6, "酷睿i7"=>1, "Core i3"=>0, "Core i5"=>0, "Core i7"=>0, "Intel"=>17, "英特尔"=>77, "Intel 平板"=>0, "英特尔 平板"=>0, "PC平板2合1"=>0, "PC平板二合一"=>0, "二合一超极本"=>0, "二合一电脑"=>0, "平板PC2合1"=>0, "平板PC二合一"=>0}
    status.sort{|a,b| b[1]<=>a[1]}.each do |line|
        csv << line
      end 
  end
  #xph
  {"安腾"=>0, "Itanium"=>0, "凌动"=>0, "Atom"=>2, "Xeon"=>0, "酷睿i3"=>5, "酷睿i5"=>6, "酷睿i7"=>1, "Core i3"=>0, "Core i5"=>0, "Core i7"=>0, "Intel"=>17, "英特尔"=>77, "Intel 平板"=>0, "英特尔 平板"=>0, "PC平板2合1"=>0, "PC平板二合一"=>0, "二合一超极本"=>0, "二合一电脑"=>0, "平板PC2合1"=>0, "平板PC二合一"=>0}

  filename = "娜娜intel-BUZZ声量.csv"
  CSV.open filename,"wb" do |csv|
  keyword_status = {}
  csv << %w{url 关键词统计量}
  old_csv = CSV.open "娜娜intel-buzz声量.csv"
    sum = 0
    old_csv.each{|line|
      url = line[0].strip
      keyword_status = line[1]
      p h = eval(keyword_status)
      keyword_status = p h
      sum = keyword_status.values.sum
      csv << [url,sum]
    }
  end
