# -*- encoding : utf-8 -*-
# archive user relations each hour
# NOTE : BEFORE this task, mast run get_my_weibo_task to load all weibo
class GetTqqForwardsCommentsTask < TqqTaskBase

  #  this task supported interval
  SUPPORT_INTERVAL = [:hourly]
  ONLY_TOKEN_USER = false
  SUPPORT_MULTI_USERS = false

  def run
    info("loading forwards for user #{@openid}")
    # check all weibo forwards & comments
    
    # compute pages for data loading

    # save weibo id separatly for reposts and comments
    reposts_ids = []
    comments_ids = []
    
    all_weibos = []
    all_openids = []


    page = 1
    posts = nil
    
    # loop { get all weibo detail record from db} by page
    begin
      # get count records of weibo for last time
      posts = TqqWeiboDetail.where(:openid=>@openid).order("weibo_id desc").paginate(:page=>page,:per_page=>30)
      
      debug("checking weibo forwards & comments for page #{page}, total #{posts.total_pages} pages, #{posts.total_entries} entries")
      
      # loop to get all weibo ids, and store count data
      old_counts = {}
      ids = []
      posts.each{|post|
        next if !post.is_origin
        all_weibos << post
        ids << post['weibo_id']
        old_counts[post['weibo_id']] = {:reposts_count=>post.count, :comments_count=>post.mcount, :object=>post}
      }
      # get new count data from API
      counts = stable{api.t.re_count(ids*",", flag:2)}.data
      # compare new data with old data
      (counts||[]).each{|weibo_id, count|
        old = old_counts[weibo_id.to_i]
        weibo_detail = old[:object]

        weibo_detail.update_attributes(:count=>count[:count], :mcount=>count.mcount)
        mweibo = MTqqWeiboContent.find(weibo_id.to_i)
        # if last forward record is null, means this is the first time load the forwards
        last_forward = TqqForward.where(:openid=>@openid, :weibo_id=>weibo_id).order("forward_id desc").first
        reposts_ids << [weibo_id,weibo_detail,mweibo,last_forward,count] if count[:count].to_i > 0 && (last_forward.nil? || old[:reposts_count].to_i != count[:count].to_i)
        
        # if last forward record is null, means this is the first time load the forwards
        last_comment = TqqComment.where(:openid=>@openid, :weibo_id=>weibo_id).order("comment_id desc").first
        comments_ids << [weibo_id,weibo_detail,mweibo,last_comment,count] if count.mcount.to_i > 0 && (last_comment.nil? || old[:comments_count].to_i != count.mcount.to_i)
        
      }
    
      page += 1
      
    end while page <= posts.total_pages

    debug("#{reposts_ids.size} weibo has new forwards")
    debug("#{comments_ids.size} weibo has new comments")
    
    
    # loop all weibo which have new forwards
    reposts_ids.each{|id,weibo_detail,mweibo, last_forward,new_count|
      
      per_page = 100
        weibo_count = WeiboInteractionCount.tqq.find_or_create_by_weibo_id(id)
        old_reposts = weibo_count.reposts
        
        debug("load new weibo forwards for #{id}, last_forward id : [#{last_forward ? last_forward.forward_id : ''}]")
        
        last_forward = TqqForward.where(weibo_id:id).order("forward_at desc").first
        
        while true
          # get new reposts from server
          reposts_results = stable{api.t.re_list({pageflag:2, flag:0, rootid:id, :reqnum=>per_page, :pagetime=>(last_forward ? last_forward.forward_at.to_i+1 : 1) })}
          reposts = reposts_results.try(:data).try(:info)
          
          # save reposts
          (reposts || []).reverse.each{|repost|
            
              following = nil  # TODO : check reposter if following to the origin poster
              exists = TqqForward.where(:forward_id=>repost['id']).first
              if !exists
                last_forward = TqqForward.create(
                  :openid=>@openid,
                  :weibo_id=>id,
                  :forward_id=>repost['id'],
                  :forward_openid=>repost['openid'],
                  :parent_openid=>nil,
                  :forward_at=>Time.at(repost['timestamp']).to_datetime
                )


              elsif exists.weibo_id != id
                exists.update_attributes(weibo_id:id)

              end
              
              
              repost['weibo'] = mweibo
              if !MTqqForward.find(repost['id'].to_i)
                begin
                  MTqqForward.create(repost)
                rescue
                end
              end
              
              all_openids << repost["openid"]
            
          }
          
          break if reposts.nil? || reposts_results.data.try(:hasnext) == 1
        end
        
#        weibo_count.update_attribute(:reposts, reposts_results.total_number)
      
    }
    


    
    # loop all weibo which have new comments
    comments_ids.each{|id,weibo_detail,mweibo,last_comment,new_count|
     
      weibo_count = WeiboInteractionCount.tqq.find_or_create_by_weibo_id(id)
      old_comments = weibo_count.comments

      total_pages = nil
      per_page = 100
      page = 1
      
      debug("load new weibo comments for #{id}, last_comment id : [#{last_comment ? last_comment.comment_id : ''}]")

        
      last_comment = TqqComment.where(weibo_id:id).order("comment_at desc").first
      while true      
          # get new comments from server
          comments_results = stable{api.t.re_list({pageflag:2, flag:1, rootid:id, :reqnum=>per_page, :pagetime=>(last_comment ? last_comment.comment_at.to_i+1 : 1) })}
          comments = comments_results.try(:data).try(:info)
          
          # save comments
          (comments || []).reverse.each{|comment|
            
              following = nil  # TODO : check commenter if following to the origin poster
              if !TqqComment.where(:comment_id=>comment['id']).first
                last_comment = TqqComment.create(
                  :openid=>@openid,
                  :weibo_id=>id,
                  :comment_id=>comment['id'],
                  :comment_openid=>comment['openid'],
                  :comment_at=>Time.at(comment['timestamp']).to_datetime
                )
              end
              
              
              comment['weibo'] = mweibo
              if !MTqqComment.find(comment['id'].to_i)
                begin
                  MTqqComment.create(comment)
                rescue
                end
              end
              
              all_openids << comment["openid"]
            
          }
          break if comments.nil? || comments_results.data.try(:hasnext) == 1
      end
      
#      weibo_count.update_attribute(:comments, comments_results.total_number)
    }
    
    # finally update all weibo interaction counts
    all_weibos.each{|weibo|
      weibo_count = WeiboInteractionCount.tqq.find_or_create_by_weibo_id(weibo.weibo_id)
      weibo_count.update_attributes({:reposts=>weibo.count, :comments=>weibo.mcount })
    }

    all_openids.each{|openid|
      load_weibo_user(openid:openid)
    }
  end

end
