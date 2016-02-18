# -*- encoding : utf-8 -*-

# save my fans info snap
class GetUserInteractSnapTask < WeiboTaskBase

  #  this task supported interval
  SUPPORT_INTERVAL = [:hourly,:daily,:weekly,:monthly]

  def run
    @time ||= Time.now
    
    @date = @time.to_date
    
    @interval_types.each{|interval_type|
    
      case interval_type
        when :hourly
          now = @time || Time.now
          now = Time.local(now.year,now.month,now.day,now.hour)
          hour_ago = now-1.hour
          
          forward_counts = WeiboForward.where(['uid=? and forward_at between ? and ?',@target_uid, hour_ago, now]).group("uid,forward_uid").select("uid,forward_uid, count(distinct forward_id) as count")
          mention_counts = WeiboMention.where(['uid=? and mention_at between ? and ?',@target_uid, hour_ago, now]).group("uid,mention_uid").select("uid, mention_uid, count(distinct mention_id) as count")
          comment_counts = WeiboComment.where(['uid=? and comment_at between ? and ?',@target_uid, hour_ago, now]).group("uid,comment_uid").select("uid, comment_uid, count(distinct comment_id) as count")
          
          snaps = {}
          forward_counts.each{|forwards|
            if snaps[forwards.forward_uid].nil?
              snaps[forwards.forward_uid] = snap_class(interval_type).new({:uid=>@target_uid,:from_uid=>forwards.forward_uid})
              set_snap_time(snaps[forwards.forward_uid], interval_type)
            end
            snap = snaps[forwards.forward_uid]
            snap.forwarded_count = forwards.count
          }
          
          mention_counts.each{|mention|
            if snaps[mention.mention_uid].nil?
              snaps[mention.mention_uid] = snap_class(interval_type).new({:uid=>@target_uid,:from_uid=>mention.mention_uid})
              set_snap_time(snaps[mention.mention_uid], interval_type)
            end
            snap = snaps[mention.mention_uid]
            snap.mentioned_count = mention.count
          }
          
          comment_counts.each{|comment|
            if snaps[comment.comment_uid].nil?
              snaps[comment.comment_uid] = snap_class(interval_type).new({:uid=>@target_uid,:from_uid=>comment.comment_uid})
              set_snap_time(snaps[comment.comment_uid], interval_type)
            end
            snap = snaps[comment.comment_uid]
            snap.commented_count = comment.count
          }
          snaps.each{|uid, snap|
            check_and_save_snap(interval_type, snap)
          }
        when :daily

          start_time = @date - 1.day
          end_time = @date

          
          forward_counts = WeiboForward.where(['uid=? and forward_at between ? and ?',@target_uid, start_time, end_time]).group("uid,forward_uid").select("uid,forward_uid, count(distinct forward_id) as count")
          mention_counts = WeiboMention.where(['uid=? and mention_at between ? and ?',@target_uid, start_time, end_time]).group("uid,mention_uid").select("uid, mention_uid, count(distinct mention_id) as count")
          comment_counts = WeiboComment.where(['uid=? and comment_at between ? and ?',@target_uid, start_time, end_time]).group("uid,comment_uid").select("uid, comment_uid, count(distinct comment_id) as count")
          
          snaps = {}
          forward_counts.each{|forwards|
            if snaps[forwards.forward_uid].nil?
              snaps[forwards.forward_uid] = snap_class(interval_type).new({:uid=>@target_uid,:from_uid=>forwards.forward_uid})
              set_snap_time(snaps[forwards.forward_uid], interval_type)
            end
            snap = snaps[forwards.forward_uid]
            snap.forwarded_count = forwards.count
          }
          
          mention_counts.each{|mention|
            if snaps[mention.mention_uid].nil?
              snaps[mention.mention_uid] = snap_class(interval_type).new({:uid=>@target_uid,:from_uid=>mention.mention_uid})
              set_snap_time(snaps[mention.mention_uid], interval_type)
            end
            snap = snaps[mention.mention_uid]
            snap.mentioned_count = mention.count
          }
          
          comment_counts.each{|comment|
            if snaps[comment.comment_uid].nil?
              snaps[comment.comment_uid] = snap_class(interval_type).new({:uid=>@target_uid,:from_uid=>comment.comment_uid})
              set_snap_time(snaps[comment.comment_uid], interval_type)
            end
            snap = snaps[comment.comment_uid]
            snap.commented_count = comment.count
          }
          snaps.each{|uid, snap|
            check_and_save_snap(interval_type, snap)
          }



        when :weekly
          # get 24 hour's data for last day from hourly data
          yesterday = @date-1.week
          hourly_snaps = snap_class(:daily).where(["date>=? and date < ? and uid=?",yesterday,@date, @target_uid]).group("from_uid").select("uid, from_uid, sum(forwarded_count) forwarded_count, sum(mentioned_count) mentioned_count, sum(commented_count) commented_count, sum(interacted_count) interacted_count")
          
          hourly_snaps.each{|sn|
            check_and_save_snap(interval_type, sn)
          }
        when :monthly
          # get 24 hour's data for last day from hourly data
          yesterday = @date-1.month
          hourly_snaps = snap_class(:daily).where(["date>=? and date < ? and uid=?",yesterday,@date, @target_uid]).group("from_uid").select("uid, from_uid, sum(forwarded_count) forwarded_count, sum(mentioned_count) mentioned_count, sum(commented_count) commented_count, sum(interacted_count) interacted_count")
          
          hourly_snaps.each{|sn|
            check_and_save_snap(interval_type, sn)
          }
      end
    }
    
  end
  
  
  def get_last_snap(interval_type)
    clazz = snap_class(interval_type)
    scope = clazz.where(["uid=?",@uid])
    scope = case interval_type
      when :hourly then scope.order("date desc, hour desc")
      else
        scope.order("date desc")
    end
    snap = scope.first
  end
  
  # set time for current stats (last date or last hour for hourly)
  def set_snap_time(snap,interval_type)
    t = case interval_type
      when :hourly then @time - 1.hour
      when :daily then @date - 1.day
      when :weekly then @date - 1.week
      when :monthly then @date - 1.month
    end
    snap.date = t.to_date
    snap.hour = t.hour if interval_type == :hourly
  end
  
  def snap_class(interval_type)
    ("WeiboUserInteractionSnap"+interval_type.to_s.camelize).constantize
  end
  
  
  def check_and_save_snap(interval_type, sn)
    if interval_type == :hourly
      snap = sn
      snap.interacted_count = sn.forwarded_count.to_i + sn.commented_count.to_i + sn.mentioned_count.to_i ; 
    else
      snap = snap_class(interval_type).new(
                {:uid=>@target_uid,:from_uid=>sn.from_uid,
                :forwarded_count=>sn.forwarded_count,:mentioned_count=>sn.mentioned_count,
                :commented_count=>sn.commented_count,:interacted_count=>sn.interacted_count
              })
    end
    set_snap_time(snap, interval_type)
    # if a snap (same uid, from_uid, date, hour) exist, update it
    exist = snap.class.where({:uid=>snap.uid,:from_uid=>snap.from_uid,:date=>snap.date}.merge(snap.respond_to?(:hour) ? {:hour=>snap.hour} : {})).first
    if exist
      exist.attributes = snap.attributes
      exist.created_at = Time.now
      snap = exist
    end
    snap.save!
  end
  
end

