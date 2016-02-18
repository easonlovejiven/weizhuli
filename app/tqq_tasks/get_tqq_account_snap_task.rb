# -*- encoding : utf-8 -*-
class GetTqqAccountSnapTask < TqqTaskBase

  #  this task supported interval
  SUPPORT_INTERVAL = [:hourly,:daily,:weekly,:monthly]
  # if this task stats only for the user which logged in by token
  # means to use this task , the target user have to LOGIN
  ONLY_TOKEN_USER = false
  # this task support multi-users stats in the same time
  SUPPORT_MULTI_USERS = false

  def run
    @time ||= Time.now
    @date = @time.to_date
    user = stable{api.user.other_info(:fopenid=>@openid)}.data
    save_weibo_user user
    @interval_types.each{|interval_type|
      debug("create account snap for #{interval_type}")
      # build snap object
      last_snap = get_last_snap(interval_type)
      snap = snap_class(interval_type).new
      set_snap_time(snap, interval_type)
      
      # check the snap exist, if exist, just update
      exist = snap.class.where({:openid=>@openid,:date=>snap.date}.merge( snap.respond_to?(:hour) ? {:hour=>snap.hour} : {})).first
      snap = exist if exist
      last_snap = nil if last_snap && last_snap.id == snap.id
      snap.attributes = {
        :openid=>@openid,
        :friends_count => user['idolnum'],
        :favourites_count => user['favnum'],
        :followers_count => user['fansnum'],
      }
      if last_snap
        snap.fans_increase = user['fansnum'].to_i - last_snap.followers_count 
      end
      
      case interval_type
        when :hourly
          new_fans_count = 0
          now = @time
          now = Time.local(now.year,now.month,now.day,now.hour)
          hour_ago = now-1.hour
          snap.new_fans_count = TqqUserRelation.where(["openid = ? and follow_time between ? and ?",@openid, hour_ago, now]).count
        when :daily
          # get 24 hour's data for last day from hourly data
          yesterday = @date-1.day
          hourly_snaps = snap_class(:hourly).where(:openid=>@openid,:date=>yesterday).order("hour desc")
          count = 0
          hourly_snaps.each{|s| count+= s.new_fans_count}
          snap.new_fans_count = count
        when :weekly
          # get last 7 day's data from hourly data
          last_week = @date-1.week
          daily_snaps = snap_class(:daily).where(["openid= ? and date >= ? and date < ?",@openid,last_week, @date]).order("date desc")
          count = 0
          daily_snaps.each{|s| count+= s.new_fans_count}
          snap.new_fans_count = count
        when :monthly
          # # get the data for last month from hourly data
          last_month = @date-1.month
          daily_snaps = snap_class(:daily).where(["openid= ? and date >= ? and date < ?",@openid,last_month, @date]).order("date desc")
          count = 0
          daily_snaps.each{|s| count+= s.new_fans_count}
          snap.new_fans_count = count
      end


      # save
      snap.save!
    }
    
    
  end
  
  
  def get_last_snap(interval_type)
    clazz = snap_class(interval_type)
    scope = clazz.where(["openid=?",@openid])
    scope = case interval_type
      when :hourly then scope.where("concat(date,'-',hour) < ?", "#{@date.to_s}-#{@time.hour}").order("date desc, hour desc")
      else
        scope.where("date < ?",@date).order("date desc")
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
    ("TqqAccountSnap"+interval_type.to_s.camelize).constantize
  end

end
