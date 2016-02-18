# -*- encoding : utf-8 -*-

# save all weibo content for current account
class GetTqqWeiboTask < TqqTaskBase

  #  this task supported interval
  SUPPORT_INTERVAL = [:hourly,:daily,:weekly,:monthly]
  # if this task stats only for the user which logged in by token
  # means to use this task , the target user have to LOGIN
  ONLY_TOKEN_USER = false
  SUPPORT_MULTI_USERS = false

  def run

    debug("START <GetTqqWeiboTask> for openid #{@openid}")

    target_openid = @openid
      # get last post id
      per_page = 100
      

      page = 1
      hasnext = true
      while hasnext

        post = TqqWeiboDetail.where(:openid=>target_openid).order("post_at desc").first
        last_time = post ? post.post_at.to_i : 1
        
        weibo_results = stable{api.statuses.user_timeline({:pageflag=>2, :fopenid=>target_openid,:reqnum=>70,:pagetime=>last_time+1})}
        if weibo_results.data
          debug("page #{page} / #{(weibo_results.data.totalnum/per_page.to_f).ceil}, total number #{weibo_results.data.totalnum}")

          weibo_results.data.info.size.downto(1){|i|

            post = weibo_results.data.info[i-1]
            
            # save contents to mongodb
            begin
            save_weibo(post)
            rescue
            end

            
            last_time = post.timestamp
          } 

          hasnext = weibo_results.data.hasnext == 0
        else
          hasnext = false
        end
      end


      
  end
  

end
