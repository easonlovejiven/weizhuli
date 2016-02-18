class Api::InteractionsController < Api::ApplicationController

  
  def index
    case @uid
    when "2295615873"
      render :json=>Intelbiz.interactions(:start_time=>params[:start_time], :end_time=>params[:end_time])
    when "intelsocial"
      # "/api/interactions",{u:"intelsocial",p:"778899",uids:"2712385930,1689151001,1839793183",target_uid:2637370927,start_time:"2013-8-10",end_time:"2013-8-11"}
      uids = params[:uids].to_s.split(",")
      target_uid = params[:target_uid]
      start_time = params[:start_time]
      end_time = params[:end_time]
      if uids.blank? || target_uid.blank? || start_time.blank? || end_time.blank?
        render :json=>{:status=>"params failed"}
        return
      end
      results = {}
      uids.each{|uid|
        fs = WeiboForward.where(uid:target_uid, forward_uid:uid).
          where("forward_at between ? and ?",start_time,end_time).all
        cs = WeiboComment.where(uid:target_uid, comment_uid:uid).
          where("comment_at between ? and ?",start_time,end_time).all
        results[uid] ||={:forwards=>[],:comments=>[]}
        fs.each{|forward|
          results[uid][:forwards] << [forward.uid,forward.weibo_id,forward.forward_id,forward.forward_at.strftime("%Y-%m-%d %H:%M:%S")]
        }
        cs.each{|comment|
          results[uid][:comments] << [comment.uid,comment.weibo_id,comment.comment_id,comment.comment_at.strftime("%Y-%m-%d %H:%M:%S")]
        }
      }
      render :json=>results

    else
      render :json=>{status:"auth failed"}
    end
  end
  
  


end
