# -*- encoding : utf-8 -*-
class WeiboList
  
  def tongji(start_time,end_time,z_uid)
    wds = WeiboDetail.where("uid = ? and post_at between ? and ?",z_uid,start_time,end_time)
    if !wds.blank?
      wds.each{|wd|
        if !wd.blank?
          weibo_id = wd.weibo_id
          WeiboList.get_weibo(weibo_id)
          WeiboList.get_buzz(weibo_id)
        end
      }      
    end
  end
  
  #得到微博的有效性分析

  def get_weibo(weibo_id)
    comments = WeiboForward.where("weibo_id = ?",weibo_id)
    comments.each do |comment|
      mc = MComment.find(comment.comment_id)
      if !mc.blank? #如果不等于空的话(这块儿做了个非空的判断)
        #微博连接
        url = "http://weibo.com/"+2637370247.to_s+"/"+WeiboMidUtil.mid_to_str(wd.weibo_id.to_s)
        #微博发布时间
        comment_date = comment.comment_at.strftime("%Y-%m-%d %H:%S")
        content = mc.text #内容
        #情感分析
        result = content != "转发微博" && !content.gsub(/\[[^\]]+\]/,"").blank?
      end
    end
    forwards = comments = WeiboComment.where("weibo_id = ?",weibo_id)
    forwards.each do |forward|
      fc = MForward.find(forward.forward_id)
      if !fc.blank? #如果不等于空的话(这块儿做了个非空的判断)
        #微博连接
        url = "http://weibo.com/"+2637370247.to_s+"/"+WeiboMidUtil.mid_to_str(wd.weibo_id.to_s)
        #微博发布时间
        forward_date = forward.forward_at.strftime("%Y-%m-%d %H:%S")
        content = fc.text #内容
        #情感分析
        result = content != "转发微博" && !content.gsub(/\[[^\]]+\]/,"").blank?
      end
    end
  end

  #关键词统计

  def get_buzz(weibo_id,keywords)
    url = "http://weibo.com/"+2637370247.to_s+"/"+WeiboMidUtil.mid_to_str(weibo_id.to_s) #微博路径
    forwards = WeiboForward.where("weibo_id = ?",weibo_id) #带来的转发量
    comments = WeiboComment.where("weibo_id = ?",weibo_id) #带来的评论量
    if !forwards.blank?
      forwards.each do |forward|
        forward_text = MForward.find_by_id(forward.forward_id)
        if !forward_text.blank?
          ftext = forward_text.text.strip #微博内容
          str = ""
          keywords.each{|w|
            key = w.strip
            if ftext.include?(key)
              str += key
              str = str += ","
              words_stats[key] += 1 #出现的次数
            end
          }
          str = str[0,str.length-1] #关键词
        end
      end
    end
    if !comments.blank?
      comments.each do |comment|
        #得到一个用户信息对象
        comment_text = MComment.find_by_id(comment.comment_id)
        if !comment_text.blank?
          str = ""
          ctext = comment_text.text.strip
            keywords.each{|w|
              key = w.strip
              if ctext.include?(key)
                str += key
                str = str += ","
                words_stats[key] += 1 
              end
            }
          str = str[0,str.length-1]
        end
      end
    end
  end

end
