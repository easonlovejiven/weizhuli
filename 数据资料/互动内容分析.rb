
  #所有互动内容
    
  require 'rseg' #有效性判断/正负面判断
  Rseg.load
  
  filename = "intel-关键词统计.csv"
  CSV.open filename,"wb" do |csv|
  csv << %w{UID URL 互动内容 有效性 动作 正负面 关键词}
  
  start_time = '2014-10-18'
  end_time = '2014-11-03'
  
  uids = open "uids"
  uids = uids.read
  uids = uids.strip.split("\n")
  uids = uids.uniq
  
  uids.each do |uid|
    page = 1
    while true
      comments = WeiboComment.where("uid = ? and comment_uid = ? comment_at between ? and ?",z_uid,uid,start_time,end_time).paginate(per_page:1000, page:page)
      break if comments.blank?
      comments.each do |comment|
        comment_date = comment.comment_at  
        url = "http://weibo.com/"+uid.to_s+"/"+WeiboMidUtil.mid_to_str(comment.weibo_id.to_s)
        mc = MComment.find(comment.comment_id)
        if !mc.blank? #如果不等于空的话(这块儿做了个非空的判断)
          content = mc.text #内容
          #情感分析
          te = TextEvaluate.new 
          eva,eva_word = te.evaluate(content)
          #情感分析
          fake_content = content == "转发微博" || content.gsub(/\[[^\]]+\]/,"").blank? #有效性
            csv << [uid,url,content,fake_content,'评论',eva,eva_word]
        end
       end
      page+=1
     end
      page = 1
     while true
      forwards = WeiboForward.where("uid = ? and forward_uid = ? and forward_at between ? and ?",z_uid,uid,start_time,end_time).paginate(per_page:1000, page:page)
      break if forwards.blank?
      forwards.each do |forward|
        forward_date = forward.forward_at
        url = "http://weibo.com/"+uid.to_s+"/"+WeiboMidUtil.mid_to_str(forward.weibo_id.to_s)
        fc = MForward.find(forward.forward_id)
        if !fc.blank? #如果不等于空的话(这块儿做了个非空的判断)
          content = fc.text
          #情感分析
          te = TextEvaluate.new 
          eva,eva_word = te.evaluate(content)
          #情感分析
          fake_content = content == "转发微博" || content.gsub(/\[[^\]]+\]/,"").blank?
            csv << [uid,url,content,fake_content,'转发',eva,eva_word]
        end
       end
    page+=1
   end
  end
  
  
  #英特尔芯品汇:2637370247
  #英特尔中国:2637370927
  #查看有( 回复@英特尔中国)的互动内容（重点分页）所有的
  #指定时间指定用户与监控帐号的互动内容和方式以及原微薄连接
  start_time = '2014-07-01'
  end_time = '2014-11-30'
  filename = '体育互动方式.csv'
  z_uid = 
  CSV.open filename,"wb" do |csv|
    csv << %w{UID URL 内容 动作 内容有效性} #参数
    uids = open 'play-uid'
    uids = uids.read
    uids = uids.strip.split("\n")
    uids = uids.uniq
    uids.each do |uid|
      uid = uid.strip
      comments = WeiboComment.where("uid = ? and comment_uid = ? and comment_at between ? and ?",z_uid,uid,start_time,end_time)
        if !comments.blank?
          comments.each do |comment|
            url = "http://weibo.com/"+2637370927.to_s+"/"+WeiboMidUtil.mid_to_str(comment.weibo_id.to_s)
            mc = MComment.find(comment.comment_id)
            if !mc.blank? #如果不等于空的话(这块儿做了个非空的判断)
              content = mc.text
              csv << [uid,url,content,'评论']
            end
          end
      forwards = WeiboForward.where("uid = ? and forward_uid = ? and forward_at between ? and ?",z_uid,uid,start_time,end_time)
      if !forwards.blank?
        forwards.each do |forward|
          fc = MForward.find(forward.forward_id)
          url = "http://weibo.com/"+2637370927.to_s+"/"+WeiboMidUtil.mid_to_str(forward.weibo_id.to_s)
          if !fc.blank? #如果不等于空的话(这块儿做了个非空的判断)
            content = fc.text
            csv << [uid,url,content,'转发']
          end
        end
      end
    end
  end
end

#接口分析互动的内容

