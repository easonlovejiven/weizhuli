# -*- encoding : utf-8 -*-
class Pinganbeijing::AccountSummariesController < Pinganbeijing::ApplicationController

  layout "client"

  def index
    compute_summary


    @date_start = params[:start_date] || Date.yesterday
    @date_end = params[:end_date] || Date.yesterday

    @account_type= params[:account_type]
    @sort_col = params[:sort_col] || "mentions_count"
    @sort_type = params[:sort_type] || "0"

    @uids = PinganbeijingAccountsLog::UIDS[@account_type]


    @uids = PinganbeijingAccountsLog::UIDS.values.flatten if @uids.blank?

    @uids = @uids.map(&:to_i)

    operator = @sort_type == '1' ? :asc : :desc
    s = @sort_col.to_sym.send(operator)

    # 最后一天数据 
    @accounts = MPinganbeijingMonitAccount.where(uid:@uids,date:Date.to_mongo(@date_end)).sort(s)
    # 第一天数据 
    @accounts_in_first_day= {}
    MPinganbeijingMonitAccount.where(uid:@uids,date:Date.to_mongo(@date_start)).sort(s).each{|m|
        @accounts_in_first_day[m.uid] = m
    }



    # 转发/评论 官微次数
    forwards = WeiboForward.where(uid:@uid,forward_uid:@accounts.map(&:uid)).where("forward_at between ? and ?", @date_start, @date_end).group("forward_uid").select("forward_uid uid,count(1) total")
    comments = WeiboComment.where(uid:@uid,comment_uid:@accounts.map(&:uid)).where("comment_at between ? and ?", @date_start, @date_end).group("comment_uid").select("comment_uid uid,count(1) total")

    @forwards = {}
    @comments = {}

    forwards.each{|f|@forwards[f.uid] = f.total}
    comments.each{|f|@comments[f.uid] = f.total}

    # 计算数据 
    @account_stats = {}
    @accounts.each{|a|

      first_day = @accounts_in_first_day[a.uid]

      status_count = a.origin_statuses_count+a.forward_statuses_count

      @account_stats[a.uid] = {
        new_fans:first_day ? a.followers_count - first_day.followers_count : 0,
        new_statuses:first_day ? a.statuses_count - first_day.statuses_count : 0,
        new_forwards:first_day ? a.forwards_count - first_day.forwards_count : 0,
        new_comments:first_day ? a.comments_count - first_day.comments_count : 0,
        origin_rate:status_count > 0 ? ((a.origin_statuses_count.to_f / status_count)*100).to_i : 0,
        forwards_main:@forwards[a.uid] || 0,
        comments_main:@comments[a.uid] || 0
      }
    }




  end


end
