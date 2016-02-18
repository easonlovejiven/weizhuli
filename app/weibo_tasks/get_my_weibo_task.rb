# -*- encoding : utf-8 -*-

# save all weibo content for current account
class GetMyWeiboTask < WeiboTaskBase

  #  this task supported interval
  SUPPORT_INTERVAL = [:hourly,:daily,:weekly,:monthly]
  # if this task stats only for the user which logged in by token
  # means to use this task , the target user have to LOGIN
  ONLY_TOKEN_USER = false
  SUPPORT_MULTI_USERS = false

  def run
    @target_uids.each{|target_uid|
      # get last post id
      post = WeiboDetail.where(:uid=>target_uid.to_i).order("weibo_id desc").first
      last_id = post ? post.weibo_id : nil
      
      per_page = 100
      

      if last_id.nil?
        weibo_results = stable(ignore_user_exists_error:true){api.statuses.user_timeline({:uid=>target_uid,:count=>10,:page=>1})}
        last_id = weibo_results["statuses"].first['mid']
      end


      weibo_results = stable(ignore_user_exists_error:true){api.statuses.user_timeline({:uid=>target_uid,:count=>1,:page=>1}.merge(last_id ? {:since_id=>last_id} : {}))}

      old_weibo_count = WeiboDetail.where(:uid=>target_uid.to_i).count
      new_counts = weibo_results.total_number.to_i - old_weibo_count
      debug("new weibos : #{new_counts} ")


      # load weibo content
      paginate(:per_page=>per_page, :total=>new_counts, :reverse=>true){|page|
          
          batch_import{

            puts "+++++++++++++++++++++++++ #{target_uid} #{per_page} #{page} #{last_id}"
            @timeline = stable(ignore_user_exists_error:true){api.statuses.user_timeline({:uid=>target_uid,:count=>per_page,:page=>page}.merge(last_id ? {:since_id=>last_id} : {}))}
            @timeline["statuses"].size.downto(1){|i|
              post = @timeline["statuses"][i-1]
              # set features
              post['feature'] = []
              post['feature'] << 'image' if !post['original_pic'].blank?
              
              
              # save contents to mongodb
              save_weibo(post)

              # compute ratio
              @process_total = @timeline[:total_number] if @process_total.nil?
              @process_ratio = i.to_f / @process_total.to_f
              update_ratio(@process_ratio)
              # end compute ratio
              
            } 
          }
        @timeline[:total_number]
      }
      
      # update weibo features : origin, image, vedio, music
      features = {:origin=>1, :image=>2, :video=>3, :music=>4}
        features.each{|column, val|
          paginate(:per_page=>per_page){|page|
            @timeline_ids = stable(ignore_user_exists_error:true){api.statuses.user_timeline_ids({:uid=>target_uid,:count=>per_page,:page=>page, :feature=>val}.merge(last_id ? {:since_id=>last_id} : {}))}
            WeiboDetail.where(:weibo_id=>@timeline_ids['statuses']).update_all(column=>1)
            (@timeline_ids.next_cursor > 0 ? page + 1 : page)*100
        }
      }
      WeiboDetail.where(:origin=>0).update_all(:forward=>1)
      
    }
  end
  

end
