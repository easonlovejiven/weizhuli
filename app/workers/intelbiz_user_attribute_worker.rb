# -*- encoding : utf-8 -*-
class IntelbizUserAttributeWorker

  include Sidekiq::Worker
  sidekiq_options :queue => :update_user_attributes, :backtrace => true
  

  def self.schedule
    yesterday = Date.today.yesterday
    self.perform_async(start_at:yesterday.to_s)
  end



  def perform(opts={})
    opts ||= {}

    intelbiz = 2295615873
    intel = 2637370927

    uid = opts[:uid] || intelbiz
    start_at  = opts[:start_at]



    user_id = 1 # for intelbiz
    keyword_category = KeywordCategory.where(category:"用户偏好",user_id:user_id).first
    # 从互动的 微博 中取出 类别
    # 直接更新  UserAttribute




    per_page = 1000

=begin

# disable forwards and comments
  
    # forwards
    puts "Starting forwards..."
    page = 1
    while true
      forwards = WeiboForward.where(uid:uid)
      forwards = forwards.where("forward_at >= ?", start_at) if !start_at.blank?
      forwards = forwards.order("forward_at asc").paginate(per_page:per_page,page:page)
      print "page #{page}/#{forwards.total_pages}...\t"
      forwards.each{|forward|
        post = Post.where("weibo_id"=>forward.weibo_id.to_s).first
        next if post.nil?
        keyword = Keyword.where(category_id:keyword_category.id, name:post.category).first_or_create(user_id:user_id)

        WeiboUserAttribute.where(user_id:user_id,uid:forward.forward_uid,keyword_id:keyword.id).first_or_create
      }  && nil
      puts "done."
      break if page == forwards.total_pages
      page += 1
    end

    # comments
    puts "Starting comments..."
    page = 1
    while true
      comments = WeiboComment.where(uid:uid)
      comments = comments.where("comment_at >= ?", start_at) if !start_at.blank?
      comments = comments.order("comment_at asc").paginate(per_page:per_page,page:page)
      print "page #{page}/#{comments.total_pages}...\t"
      comments.each{|comment|
        post = Post.where(weibo_id:comment.weibo_id).first
        next if post.nil?
        keyword = Keyword.where(category_id:keyword_category.id, name:post.category).first_or_create(user_id:user_id)
        WeiboUserAttribute.where(user_id:user_id,uid:comment.comment_uid,keyword_id:keyword.id).first_or_create

      }
      puts "done."
      break if page == comments.total_pages

      page += 1
    end

=end


    # mentions
    # 获取每种偏号 及其对应的多个 关键词

    puts "Starting mentions..."
    categories = keyword_category.children
    keywords = Keyword.where(category_id:keyword_category.child_ids)


    page = 1
    while true
      mentions = WeiboMention.where(uid:uid)
      mentions = mentions.where("mention_at >= ?", start_at) if !start_at.blank?
      mentions = mentions.order("mention_at asc").paginate(per_page:per_page,page:page)
      print "page #{page}/#{mentions.total_pages}...\t"

      mentions.each{|mention|
        weibo = MMention.find(mention.mention_id)
        next if weibo.nil?
        ks = []
        keywords.each{|keyword| 
          if(weibo.text=~/#{keyword.name}/)
            final_keyword = Keyword.where(category_id:keyword_category.id, name:keyword.category.category).first_or_create(user_id:user_id)
#            WeiboUserAttribute.where(user_id:user_id,uid:mention.mention_uid,keyword_id:final_keyword.id).first_or_create
            ks << final_keyword.name  if !ks.include?(final_keyword.name)
          end
        }
        if !ks.blank?
          weibo[:categories] = ks
          weibo.save
        end
      } && nil
      puts "done."

      break if page == mentions.total_pages

      page += 1
    end






    # 从  mention 的 内容中读取关键词，
    # 得出 标签后 更新 UserAttribute



  end
end

