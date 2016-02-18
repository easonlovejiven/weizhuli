# -*- encoding : utf-8 -*-
class FansListExportor < ExportorBase

  description <<EOF
  根据UID列表 导出粉丝 详情列表
  数据列包括:
    粉丝基本信息
EOF
  title "监控帐号粉丝列表(根据uids)"  #文件名字 ExportFansListExportor.new.export({uids:[],start_time:"",end_time:""})



  before do |this,opts|
    #TODO:
    @start_time = opts[:start_time]
    @end_time = opts[:end_time]
    @uids = case 
            when opts[:uids].is_a?(String)
              opts[:uids].split("\r\n").map{|line| line.blank? ? nil : line.strip}.compact
            when opts[:uids].is_a?(Array)
              opts[:uids]
            else
            end
    @with_interations = opts[:with_interations]

  end

  export name:"粉丝列表" do |ins,opts|
    ins.export_fans_list(@start_time,@end_time,@uids)
  end

  


# 导出 uids 的粉丝列表
  def export_fans_list(start_time, end_time, uids)   
     # uids = uids    
      #start_time = start_time  # fans follow time start
      #end_time =end_time  # fans follow time end
      #limits = limits  # export results limit
      #row_type = row_type  # export row columns type
      #with_tags = with_tags  # export with user tags
      #with_quality = with_quality  # export with user quality
      #blue_v = blue_v  # export only blue v user
      #yellow_v = yellow_v  # export only yellow v
      #row_type = :full if with_tags
      #row_type = :quality if with_quality
       rows << %w{帐号 UID 昵称 位置 性别 粉丝 关注 微博 注册时间 认证类型 认证原因  备注 标签 被转发率 平均被转发 被评论率 平均被评论 活跃度 原创占比 关注时间 与中国互动次数}
      task = GetUserTagsTask.new
      uids.each{|uid|
      uid = uid
      count = 0
#debugger
        m = MonitWeiboAccount.find_by_uid(uid)
          relations = WeiboUserRelation.where(uid:uid)
          relations = relations.where("follow_time >= ?",start_time) 
          relations = relations.where("follow_time < ?",end_time) 
           
          break if relations.blank?
          relations.each{|rel|
            break if rel.by_uid.blank?  
            begin
              a = task.load_weibo_user(rel.by_uid)
            rescue Exception=>e
              if e.message =~ / does not exists!/
                  rows << [uid]
                   next
              end
            end
            next if a.nil? # || a.forward_rate.nil? || a.forward_rate < 0
            # forwards = WeiboForward.where("uid = ? and forward_uid=?",uid,rel.by_uid).count
            # comments = WeiboComment.where("uid = ? and comment_uid=?",uid,rel.by_uid).count
            row = a.to_row(:quality)
            row.unshift m.screen_name
            follow_time = rel.follow_time ? rel.follow_time.strftime("%Y-%m-%d %H:%M") : nil
            row << follow_time
            row << 0 #forwards + comments
            rows << row
            count += 1
          }

        
      }
  end
 
end
