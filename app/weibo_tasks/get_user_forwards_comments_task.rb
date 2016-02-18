# -*- encoding : utf-8 -*-
# archive user relations each hour
# NOTE : BEFORE this task, mast run get_my_weibo_task to load all weibo
class GetUserForwardsCommentsTask < WeiboTaskBase

  #  this task supported interval
  SUPPORT_INTERVAL = [:hourly]
  ONLY_TOKEN_USER = false
  SUPPORT_MULTI_USERS = false

  def run
    info("loading forwards for user #{@target_uid}")
    # check all weibo forwards & comments
    
    # compute pages for data loading
    user = MUser.where(:id=>@target_uid.to_i).first
    
    # save weibo id separatly for reposts and comments
    reposts_ids = []
    comments_ids = []
    
    all_weibos = []

    page = 1
    posts = nil
    
    # loop { get all weibo detail record from db} by page
    begin
      # get count records of weibo for last time
      posts = WeiboDetail.where(:uid=>@target_uid).order("weibo_id desc").paginate(:page=>page,:per_page=>100)
      
      debug("checking weibo forwards & comments for page #{page}, total #{posts.total_pages} pages, #{posts.total_entries} entries")
      
      # loop to get all weibo ids, and store count data
      old_counts = {}
      ids = []
      posts.each{|post|
        
        cont = MWeiboContent.find(post.weibo_id)

        next if cont.nil?


        retweet = MRetweetContent.find(cont.retweeted_status_id)

              
        all_weibos << post
        ids << post['weibo_id']
        old_counts[post['weibo_id']] = {:reposts_count=>post['reposts_count'], :comments_count=>post['comments_count'], :object=>post}


      } 

      (page += 1; next) if ids.blank?
      # get new count data from API
      counts = stable{api.statuses.count({:ids=>ids*","})}
      
      # compare new data with old data
      counts.each{|count|
        old = old_counts[count['id']]
        weibo_detail = old[:object]
        weibo_detail.update_attributes(:reposts_count=>count['reposts'], :comments_count=>count['comments'])
        mweibo = nil  # MWeiboContent.find(count['id'].to_i)  don't need this for now

        weibo_count = WeiboInteractionCount.find_or_create_by_weibo_id(count['id'])

        # if last forward record is null, means this is the first time load the forwards
        last_forward = WeiboForward.where(:uid=>@target_uid, :weibo_id=>count['id']).order("forward_id desc").first
        if count['reposts'].to_i > weibo_count.reposts.to_i
          reposts_ids << [count['id'],weibo_detail,mweibo,last_forward,count,weibo_count] 
        end
        
        # if last forward record is null, means this is the first time load the forwards
        last_comment = WeiboComment.where(:uid=>@target_uid, :weibo_id=>count['id']).order("comment_id desc").first
        if count['comments'].to_i > weibo_count.comments.to_i
          comments_ids << [count['id'],weibo_detail,mweibo,last_comment,count,weibo_count] 
        end
        
      }
    
      page += 1
      
    end while page <= posts.total_pages

    debug("#{reposts_ids.size} weibo has new forwards")
    debug("#{comments_ids.size} weibo has new comments")
    
    # loop all weibo which have new forwards
    reposts_ids.each{|id,weibo_detail,mweibo, last_forward,new_count,weibo_count|
      
      per_page = 200
        old_reposts = weibo_count.reposts
        
        debug("load new weibo forwards for #{id}, last_forward id : [#{last_forward ? last_forward.forward_id : ''}]")
        
        # 从远到近取出所有评论
        reposts_results = stable{api.statuses.repost_timeline(id, {:count=>1, :page=>1}.merge( last_forward ? {:since_id=>last_forward.forward_id} : {}))}
        
        if reposts_results.blank?
          warn("weibo #{id} may has be deleted! ")
          next 
        end
        
        new_counts = reposts_results.total_number.to_i - (old_reposts || WeiboForward.where(["weibo_id=?",id]).count)
        new_counts = 2000 if new_counts > 2000
        debug("new forwards : #{new_counts} ")
        


        batch_import{
          paginate(:per_page=>per_page, :total=>new_counts, :reverse=>true){|page|
              # get new reposts from server
              reposts_results = stable{api.statuses.repost_timeline(id, {:count=>per_page, :page=>page}.merge( last_forward ? {:since_id=>last_forward.forward_id} : {}))}
              next if reposts_results.blank?
              reposts = reposts_results.reposts
              
              # save reposts
              reposts.reverse.each{|repost|
                
                  following = nil  # TODO : check reposter if following to the origin poster
                  if !WeiboForward.where(:forward_id=>repost['id']).first
                    import_for_batch WeiboForward.new(
                      :uid=>@target_uid,
                      :weibo_id=>id,
                      :forward_id=>repost['id'],
                      :forward_uid=>repost['user']['id'],
                      :forward_at=>DateTime.parse(repost['created_at'])
                    ),:ignore => true
                  end
                  
                  
                  user = save_weibo_user(repost['user'])
                  repost['user_id'] = user.uid
                  repost['weibo'] = mweibo
                  if !MForward.find(repost['id'].to_i)
                    MForward.create(repost)
                  end
                  
                
              }
            
              reposts_results.total_number
          }
        }

        
#        weibo_count.update_attribute(:reposts, reposts_results.total_number)
      
    }
    


    
    # loop all weibo which have new comments
    comments_ids.each{|id,weibo_detail,mweibo,last_comment,new_count,weibo_count|
     
      old_comments = weibo_count.comments

      total_pages = nil
      per_page = 200
      page = 1
      
      debug("load new weibo comments for #{id}, last_comment id : [#{last_comment ? last_comment.comment_id : ''}]")
      # 从远到近取出所有评论
      comments_results = stable{api.comments.show(id, {:count=>1, :page=>1}.merge( last_comment ? {:since_id=>last_comment.comment_id} : {}))}

      if comments_results.blank?
        warn("weibo #{id} may has be deleted! ")
        next 
      end
        


      new_counts = comments_results.total_number.to_i - (old_comments ||WeiboComment.where(["weibo_id=?",id]).count)
      new_counts = 2000 if new_counts > 2000
      debug("new comments : #{new_counts} ")
      
      batch_import{
        paginate(:per_page=>per_page, :total=>new_counts, :reverse=>true){|page|
      
            # get new reposts from server
            comments_results = stable{api.comments.show(id, {:count=>per_page, :page=>page}.merge( last_comment ? {:since_id=>last_comment.comment_id} : {}))}
            next if comments_results.blank?
            comments = comments_results.comments
            
            # save reposts
            comments.reverse.each{|comment|
              
                following = nil  # TODO : check reposter if following to the origin poster
                
                if !WeiboComment.where(:comment_id=>comment['id']).first
                  import_for_batch  WeiboComment.new(
                    :uid=>@target_uid,
                    :weibo_id=>id,
                    :comment_id=>comment['id'],
                    :comment_uid=>comment['user']['id'],
                    :comment_at=>DateTime.parse(comment['created_at'])
                  ),:ignore => true
                end
                user = save_weibo_user(comment['user'])
                comment['user_id'] = user.uid
                comment['weibo'] = mweibo
                if !MComment.find(comment['id'].to_i)
                  MComment.create(comment)
                end
              
            }
          
        }
      }
      
#      weibo_count.update_attribute(:comments, comments_results.total_number)
    }
    
    # finally update all weibo interaction counts
    all_weibos.each{|weibo|
      weibo_count = WeiboInteractionCount.find_or_create_by_weibo_id(weibo.weibo_id)
      weibo_count.update_attributes({:reposts=>weibo.reposts_count, :comments=>weibo.comments_count })
    }
  end

end
