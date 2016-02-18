# -*- encoding : utf-8 -*-
class WeiboForward < ActiveRecord::Base

  belongs_to  :forward_user,  class_name:"WeiboAccount", :foreign_key=>"forward_uid", :primary_key=>"uid"

  scope :time_between, ->(start_time,end_time){where("forward_at between ? and ?", start_time,end_time)}




  # 分析转发之间的关系
  # 必须 在一定阶段内把所有的转发抓取到. 
  # 没有被抓取到的转发 将不会被计为结点
  def self.analyze_tree(weibo_id)

    root = WeiboForwardRelation.where(weibo_id:weibo_id,weibo_forward_id:0).first_or_create

    user_cache = {}
    parent_weibo_cache = {}

    page = 1
    last_forward_id = 0
    while true
      # last_forward_id use for fix mysql duplicate delay problem
      fs = WeiboForward.where(weibo_id:weibo_id, in_tree:false).where("forward_id > ?",last_forward_id).order("forward_id asc").limit(100)
      break if fs.blank?

      fs.each{|f|
        # 解析内容中的 @昵称
        mf = MForward.find(f.forward_id)
        rs = mf.text.match /\/\/@([^:]*):/
        name = rs ? rs[1] : nil

        # 根据昵称查找 用户信息
        a = user_cache[name] ||= WeiboAccount.find_by_screen_name(name) if name
        parent_node = nil

        # 找不到说明之前没有抓过, 跳过
        if a
          # 得到 上级转发的微博转发记录
          uid = a.uid
          # 需要根据  weibo_id, forward_uid 及 发布时间判断 是否存在
          parent = parent_weibo_cache[uid] ||= WeiboForward.where(weibo_id:weibo_id,forward_uid:uid).where("in_tree = 1").order("forward_at asc").first
          parent ? parent_node = WeiboForwardRelation.where(weibo_forward_id:parent.id).first : nil
        end

        parent_node ||= root
        parent_node.children.where(weibo_id:weibo_id,weibo_forward_id:f.id).first_or_create


        f.update_attribute(:in_tree,true)
      }

      page += 1
      last_forward_id = fs.last.forward_id
    end
  end


end
