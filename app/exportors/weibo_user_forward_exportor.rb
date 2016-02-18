# -*- encoding : utf-8 -*-
class WeiboUserForwardExportor < ExportorBase

  description <<EOF
  根据UID列表 导出微博用户列表 详情及互动数 列表
  数据列包括:
    用户基本信息
    与特定监控用户发生的转发列表及二次转发数
EOF


  title "微博用户 以及与 监控帐户互动 信息 导出(根据uids)"


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
    @target_uid = opts[:target_uid].blank? ?  2637370927 : opts[:target_uid]

  end
=begin
  export name:"用户列表" do |ins,opts|
    ins.export_users(@start_time,@end_time,@uids,@target_uid)
  end
=end
  export name:"用户互动列表" do |ins,opts|
    ins.export_interactions(@start_time,@end_time,@uids,@target_uid)
  end


=begin

  def export_users(start_time, end_time, uids, target_uid)
    task = GetUserTagsTask.new
 #1范范平台方法:  UID 昵称 认证类型 认证信息  粉丝数 平均转发 平均评论 平均互动 与中国互动（评论/转发）
             names = []
             return if uids.blank?
             task = GetUserTagsTask.new
          rows << %w{UID 昵称 认证类型 认证信息  粉丝数  转发 评论 互动总数 是否主号粉丝 关注时间 主号是否关注他} 
          
        uids.each{|uid|
          begin
            account = task.load_weibo_user(uid)
            puts "Processing uid : #{uid}"
            forwards = WeiboForward.where("uid = ? and forward_uid = ?",target_uid,uid).where("forward_at between ? and ?",start_time,end_time).count
            comments = WeiboComment.where("uid = ? and comment_uid = ?",target_uid,uid).where("comment_at between ? and ?",start_time,end_time).count
            verified_type = account.human_verified_type.uniq*"," 
            #account.update_evaluates if account.user_quality.nil?
           # account.reload
           # forward = account.user_quality ? account.user_quality.forward_average  : 0
           # comment = account.user_quality ?  account.user_quality.comment_average : 0
            relation = WeiboUserRelation.where(uid:target_uid,by_uid:uid)
            if relation.count >0
                isfans = 'Y'
                relationtime = relation.first.follow_time
            else
                isfans = 'N'
                relationtime =''
            end
            isfans = relation.count >0 ? 'Y' : 'N'
            a = MUser.find(uid.to_i)
            verified_reason = a.try(:verified_reason)
            
            begin
                res = task.api.friendships.show(source_id:target_uid,target_id:uid)
            rescue Exception=>e
                rows << [uid,account.screen_name,verified_type,verified_reason,account.followers_count,forwards.to_s, comments.to_s, forwards+comments,isfans,relationtime,'']
            end
            rows << [uid,account.screen_name,verified_type,verified_reason,account.followers_count,forwards.to_s, comments.to_s, forwards+comments,isfans,relationtime,res.source.following ? "Y" : "N"]#,forward,comment,forward+comment,
          rescue Exception=>e
            rows << [uid]
          end
      }

  end

=end

#2范范平台方法: UID 昵称  活跃度 时间 微博内容分类 微博连接 微博内容 总转/评 二次转/评率
  def export_interactions(start_time,end_time,uids,target_uid)

    return if uids.blank?
    task = GetUserTagsTask.new
    te = TextEvaluate.new
    rows << WeiboAccount.to_row_title + %w{活跃度 互动内容 原微博链接  原微博发布时间 原微博内容 原微博内容分类 转发微博连接 转发时间   总转发 总评论 二次转发 二次评论  转发占比 动作 正负面 有效性} 
    uids.each{|uid|
        uniq_forward_ids = []
        uniq_comment_ids = []
        uid = uid
        account =  task.load_weibo_user(uid)
        evaluates = account.user_quality
        evaluate =0
        if !evaluates.nil?
          evaluate = evaluates.forward_average + evaluates.comment_average
        end
        commentcount = 0
        forward_weibo = WeiboForward.where("uid = ? and forward_uid = ? and forward_at between ? and ?",target_uid,uid,start_time,end_time)
        comment_weibo = WeiboComment.where("uid = ? and comment_uid = ? and comment_at between ? and ?",target_uid,uid,start_time,end_time)

        if !(comment_weibo.count ==0)
        comment_weibo.each do |comment|
          next if uniq_comment_ids.include?(comment.comment_id)
          uniq_comment_ids << comment.comment_id
          comment_at = comment.comment_at.strftime("%Y-%m-%d %H:%M:%S")
          comment_url = "http://weibo.com/#{comment.comment_uid}/#{WeiboMidUtil.mid_to_str(comment.comment_id.to_s)}"
          record=WeiboDetail.where("weibo_id = ?",comment.weibo_id).first         
          c=MWeiboContent.find(comment.weibo_id)
          cc = MComment.find(comment.comment_id)
          srouce=''
          text=''
          if !c.nil?
            srouce=ActionView::Base.full_sanitizer.sanitize(c.source)
            text=c.text
          end
          type = case 
            when record.image? && record.video?
              "image + video"
            when record.image?
              "image"
            when record.video?
              "video"
            when record.music?
              "music"
            when record.vote?
              "vote"
            else
              "text"
          end
          origin=!record.origin
          post_at = record.post_at.strftime("%Y-%m-%d %H:%M:%S")
          begin
            f=task.stable{task.api.statuses.show(id:comment.comment_id)}
            freposts_count =f.reposts_count
            fcomments_count = f.comments_count
          rescue Exception=>e
             if e.message =~ / does not exists!/
               freposts_count =0
               fcomments_count = 0
             end
          end
          int_text=eva=eva_word=valid = nil
          if cc
            int_text = cc.text
            eva,eva_word = te.evaluate(int_text)
            valid = te.valid(int_text)
          end
          rows << account.to_row + [evaluate/100.0,int_text, record.url, post_at,text,type,comment_url, comment_at,record.reposts_count.to_s ,record.comments_count.to_s,freposts_count, fcomments_count, freposts_count.to_f/record.reposts_count.to_f,'评论',eva,valid]
         end
        end

     if !(forward_weibo.count == 0)  
        forward_weibo.each do |forward|
          next if uniq_forward_ids.include?(forward.forward_id)
          uniq_forward_ids << forward.forward_id

          forward_at=forward.forward_at.strftime("%Y-%m-%d %H:%M:%S")
          forward_url="http://weibo.com/#{forward.forward_uid}/#{WeiboMidUtil.mid_to_str(forward.forward_id.to_s)}"
          record=WeiboDetail.find_by_weibo_id(forward.weibo_id)
          c=MWeiboContent.find(forward.weibo_id)
          cf = MForward.find(forward.forward_id)
          srouce=''
          text=''
          if !c.nil?
            srouce=ActionView::Base.full_sanitizer.sanitize(c.source)
            text=c.text
          end
          type=case 
            when record.image? && record.video?
              "image + video"
            when record.image?
              "image"
            when record.video?
              "video"
            when record.music?
              "music"
            when record.vote?
              "vote"
            else
              "text"
          end
          origin = !record.origin
          post_at = record.post_at.strftime("%Y-%m-%d %H:%M:%S")
          begin
            f = stable{api.statuses.show(id:forward.forward_id)}
            freposts_count =f.reposts_count
            fcomments_count = f.comments_count
          rescue Exception=>e
             if e.message =~ / does not exists!/
               freposts_count =0
               fcomments_count = 0
             end
          end
          int_text=eva=eva_word=valid = nil
          if cf
            int_text = cf.text
            eva,eva_word = te.evaluate(cf.text)
            valid = te.valid(cf.text)
          end

         rows << account.to_row + [evaluate/100.0,int_text, record.url, post_at,text,type,forward_url, forward_at,record.reposts_count.to_s ,record.comments_count.to_s,freposts_count, fcomments_count, freposts_count.to_f/record.reposts_count.to_f,'转发',eva,valid]

        end
      end

    }

  end



end
