# -*- encoding : utf-8 -*-

# save my fans info snap
class GetTqqUserInteractSnapTask < TqqTaskBase

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
          
          forward_counts = TqqForward.where(['openid=? and forward_at between ? and ?',@openid, hour_ago, now]).group("openid,forward_openid").select("openid,forward_openid, count(1) as count")
          mention_counts = TqqMention.where(['openid=? and mention_at between ? and ?',@openid, hour_ago, now]).group("openid,mention_openid").select("openid, mention_openid, count(1) as count")
          comment_counts = TqqComment.where(['openid=? and comment_at between ? and ?',@openid, hour_ago, now]).group("openid,comment_openid").select("openid, comment_openid, count(1) as count")
          
          snaps = {}
          forward_counts.each{|forwards|
            if snaps[forwards.forward_openid].nil?
              snaps[forwards.forward_openid] = snap_class(interval_type).new({:openid=>@openid,:from_openid=>forwards.forward_openid})
              set_snap_time(snaps[forwards.forward_openid], interval_type)
            end
            snap = snaps[forwards.forward_openid]
            snap.forwarded_count = forwards.count
          }
          
          mention_counts.each{|mention|
            if snaps[mention.mention_openid].nil?
              snaps[mention.mention_openid] = snap_class(interval_type).new({:openid=>@openid,:from_openid=>mention.mention_openid})
              set_snap_time(snaps[mention.mention_openid], interval_type)
            end
            snap = snaps[mention.mention_openid]
            snap.mentioned_count = mention.count
          }
          
          comment_counts.each{|comment|
            if snaps[comment.comment_openid].nil?
              snaps[comment.comment_openid] = snap_class(interval_type).new({:openid=>@openid,:from_openid=>comment.comment_openid})
              set_snap_time(snaps[comment.comment_openid], interval_type)
            end
            snap = snaps[comment.comment_openid]
            snap.commented_count = comment.count
          }
          snaps.each{|openid, snap|
            check_and_save_snap(interval_type, snap)
          }
        when :daily
          # get 24 hour's data for last day from hourly data
          yesterday = @date - 1.day
          hourly_snaps = snap_class(:hourly).where(:date=>yesterday,:openid=>@openid).group("from_openid").select("openid, from_openid, sum(forwarded_count) forwarded_count, sum(mentioned_count) mentioned_count, sum(commented_count) commented_count, sum(interacted_count) interacted_count")
          
          hourly_snaps.each{|sn|
            check_and_save_snap(interval_type, sn)
          }

        when :weekly
          # get 24 hour's data for last day from hourly data
          yesterday = @date-1.week
          hourly_snaps = snap_class(:hourly).where(["date>=? and date < ? and openid=?",yesterday,@date, @openid]).group("from_openid").select("openid, from_openid, sum(forwarded_count) forwarded_count, sum(mentioned_count) mentioned_count, sum(commented_count) commented_count, sum(interacted_count) interacted_count")
          
          hourly_snaps.each{|sn|
            check_and_save_snap(interval_type, sn)
          }
        when :monthly
          # get 24 hour's data for last day from hourly data
          yesterday = @date-1.month
          hourly_snaps = snap_class(:hourly).where(["date>=? and date < ? and openid=?",yesterday,@date, @openid]).group("from_openid").select("openid, from_openid, sum(forwarded_count) forwarded_count, sum(mentioned_count) mentioned_count, sum(commented_count) commented_count, sum(interacted_count) interacted_count")
          
          hourly_snaps.each{|sn|
            check_and_save_snap(interval_type, sn)
          }
      end
    }
    
  end
  
  
  def get_last_snap(interval_type)
    clazz = snap_class(interval_type)
    scope = clazz.where(["openid=?",@openid])
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
    ("TqqUserInteractionSnap"+interval_type.to_s.camelize).constantize
  end
  
  
  def check_and_save_snap(interval_type, sn)
    if interval_type == :hourly
      snap = sn
      snap.interacted_count = sn.forwarded_count.to_i + sn.commented_count.to_i + sn.mentioned_count.to_i ; 
    else
      snap = snap_class(interval_type).new(
                {:openid=>@openid,:from_openid=>sn.from_openid,
                :forwarded_count=>sn.forwarded_count,:mentioned_count=>sn.mentioned_count,
                :commented_count=>sn.commented_count,:interacted_count=>sn.interacted_count
              })
    end
    set_snap_time(snap, interval_type)
    # if a snap (same openid, from_openid, date, hour) exist, update it
    exist = snap.class.where({:openid=>snap.openid,:from_openid=>snap.from_openid,:date=>snap.date}.merge(snap.respond_to?(:hour) ? {:hour=>snap.hour} : {})).first
    if exist
      attrs = snap.attributes
      attrs.delete("id")
      attrs.delete("created_at")
      exist.attributes = attrs
      exist.created_at = Time.now
      snap = exist
    end
    snap.save!
  end
  
end

