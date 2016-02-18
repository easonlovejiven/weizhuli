# -*- encoding : utf-8 -*-
class ItdmKolInteractionExportor < ExportorBase

  description ""
  title "商用频道 ITDM KOL 互动列表(根据keyword_id)"


  before do |ins,opts|

  end

  export name:"ITDM" do |ins,opts|

    attr_ids = [77]
    start_time = opts[:start_time]
    end_time = opts[:end_time]

    ins.export_user_interaction_list(attr_ids,start_time,end_time)

  end

  export name:"KOL" do |ins,opts|
    attr_ids = [85,86,88,90,91,92]
    start_time = opts[:start_time]
    end_time = opts[:end_time]

    ins.export_user_interaction_list(attr_ids,start_time,end_time)

  end




  def export_user_interaction_list(attr_ids,start_time,end_time)
    target = 2295615873 #intelbiz

    rows = WeiboAccount.to_row_title + %w{互动 互动时间 互动内容 二次转发}


    WeiboUserAttribute.where("weibo_user_attributes.keyword_id in (?)", attr_ids).all.each{|wua|
      wa = WeiboAccount.find_by_uid(wua.uid)
      next if wa.nil?
      row = wa.to_row


      WeiboForward.where(uid:target,forward_uid:wa.uid).where("forward_at between ? and ?",start_time, end_time).each{|f|
        mf = MForward.find(f.forward_id)
        row = row.clone
        if mf
          row << "转发"
          row << f.forward_at.strftime("%Y-%m-%d %H%M")
          row << mf.text
          row << mf.reposts_count

          rows << row
        end
      }
      WeiboComment.where(uid:target,comment_uid:wa.uid).where("comment_at between ? and ?",start_time, end_time).each{|f|
        mf = MComment.find(f.comment_id)
        row = row.clone
        if mf
          row << "评论"
          row << f.comment_at.strftime("%Y-%m-%d %H%M")
          row << mf.text

          rows << row
        end
      }
    }

  end
end
