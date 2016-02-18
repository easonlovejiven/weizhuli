# -*- encoding : utf-8 -*-
require 'csv'
class Intelbiz
  
  UID = 2295615873
  
  # SCRM 接口  根据时间统计互动列表
  def self.interactions(opts={})
  
    start_time = opts[:start_time] && Time.at(opts[:start_time].to_i) || Time.now - 1.hour
    end_time = opts[:end_time]  && Time.at(opts[:end_time].to_i) || Time.now
    end_time = start_time+1.day if end_time-1.day > start_time
    
    list = []
    uids = []
    
    WeiboForward.where({uid:UID}).time_between(start_time, end_time).each{|f|
    
      uids << f.forward_uid
    
      item = []
      item << f.forward_uid
      item << "微博"
      item << "微博"
      weibo = MWeiboContent.find(f.weibo_id)
      if weibo.text =~ /#([^#]*)#/
        item << $1
      else
        item << ""
      end
      item << "转发"
      item << f.forward_at.to_s

      post = Post.where(weibo_id:f.weibo_id.to_s).first
      item << (post ? post.category : "")
      
      list << item
    }
    
    WeiboComment.where({uid:UID}).time_between(start_time, end_time).each{|f|
      uids << f.comment_uid
      item = []
      item << f.comment_uid
      item << "微博"
      item << "微博"
      weibo = MWeiboContent.find(f.weibo_id)
      if weibo.text =~ /#([^#]*)#/
        item << $1
      else
        item << ""
      end
      item << "评论"
      item << f.comment_at.to_s
      
      post = Post.where(weibo_id:f.weibo_id.to_s).first
      item << (post ? post.category : "")
      
      list << item
    }
    
    WeiboMention.where({uid:UID}).time_between(start_time, end_time).each{|f|
    
      uids << f.mention_uid
    
      item = []
      item << f.mention_uid
      item << "微博"
      item << "微博"
      weibo = MMention.find(f.mention_id)
      if weibo.text =~ /#([^#]*)#/
        item << $1
      else
        item << ""
      end
      item << "主动@"
      item << f.mention_at.to_s

      item << (weibo["categories"] || [])*","
      
      item << weibo.text

      list << item
    }


#comment
WeiboSentComment.where({uid:UID}).time_between(start_time, end_time).each{|f|
      uids << f.target_uid
      item = []
      item << f.target_uid
      item << "微博"
      item << "微博"
      item << ""
      item << "被评论"
      item << f.comment_at.to_s
      item << ''
      item << f.content
      
      list << item
    }

#comment
WeiboSentMention.where({uid:UID}).time_between(start_time, end_time).each{|f|
      uids << f.target_uid
      item = []
      item << f.target_uid
      item << "微博"
      item << "微博"
      item << ""
      item << "被@"
      item << f.mention_at.to_s
      item << ''
      item << f.content
      
      list << item
    }


#private messages
WeiboPrivateMessage.where({uid:UID}).time_between(start_time, end_time).each{|f|
      uids << f.target_uid
      item = []
      item << f.target_uid
      item << "微博"
      item << "微博"
      item << ""
      item << "收到私信"
      item << f.send_at.to_s
      item << ''
      item << f.content
      
      list << item
    }

    list
    
    user_list = users(uids.uniq)
    
    {interactions:list,users:user_list}
  
  end
  def self.users(ids)
    accounts = WeiboAccount.where(uid:ids)
    list = []
    accounts.each{|a|
      u = MUser.find a.uid
      next if u.nil?
      item = []
      item << a.uid
      item << (a.gender==1 ? "男" : "女")
      item << a.screen_name
      item << a.verified_type
      item << u.verified_reason
      item << a.friends_count
      item << a.followers_count
      item << a.statuses_count
      p,c = a.location.split " "
      item << p
      item << (c || "")
      item << u.description
      tags = u.tags
      item << (tags ? tags*"," : "")
      relations = WeiboUserRelation.between(UID,a.uid).all
      if relations.size == 2
        item << "互粉"
      elsif relations.size == 0
        item << "陌生"
      elsif relations.first.uid == UID
        item << "粉丝"
      else
        item << "关注"
      end
      user_keywords = WeiboUserAttribute.where(user_id:1, uid:a.uid).includes(:keyword).map{|a|
        ["INTERNAL","ITDM","核心KOL","降级核心KOL","媒体记者","全量KOL","全网KOL"].include?(a.keyword.name) ? a.keyword.name : nil
      }.compact
      item << user_keywords*","
      
      # user_interestings = WeiboUserAttribute.where(user_id:1, uid:a.uid).includes(:keyword).map{|a|
      #   ["大数据","IT消费化","云计算","行业解决方案及案例",""].include?(a.keyword.name) ? a.keyword.name : nil
      # }.compact
      # item << user_interestings*","


      list << item
    }
    list
  end


  def self.user_updates(opts)
    start_time = opts[:start_time] && Time.at(opts[:start_time].to_i) || Time.now - 1.hour
    end_time = opts[:end_time]  && Time.at(opts[:end_time].to_i) || Time.now
    end_time = start_time+1.day if end_time-1.day > start_time

    list = []
    res = {users:list}



    IntelbizUpdateUser.time_between(start_time,end_time).each{|uu|
      item = []

      if uu.status == 1
        a = WeiboAccount.find_by_uid uu.uid
        u = MUser.find uu.uid

        item << a.uid
        item << a.screen_name
        item << (a.gender==1 ? "男" : "女")
        item << a.verified_type
        item << u.verified_reason
        item << a.friends_count
        item << a.followers_count
        item << a.statuses_count
        p,c = a.location.split " "
        item << p
        item << (c || "")
        item << u.description
        tags = u.tags
        item << (tags ? tags*"," : "")
        relations = WeiboUserRelation.between(UID,a.uid).all
        if relations.size == 2
          item << "互粉"
        elsif relations.size == 0
          item << "陌生"
        elsif relations.first.uid == UID
          item << "粉丝"
        else
          item << "关注"
        end
        user_keywords = WeiboUserAttribute.where(user_id:1, uid:a.uid).includes(:keyword).map{|a|
          ["INTERNAL","ITDM","核心KOL","降级核心KOL","媒体记者","全量KOL","全网KOL"].include?(a.keyword.name) ? a.keyword.name : nil
        }.compact
        item << user_keywords*","


      elsif uu.uid
        item << uu.uid
      elsif uu.name
        item << nil
        item << uu.name
      end

      list << item
    }

    res
  end

  def self.csv(opts)
  
    result = interactions opts
    ints = result[:interactions]
    us = result[:users]
    
    CSV.open("#{UID}_interactions.csv", "wb") do |csv|
      csv << %w{UID 行为发生地 行为对象 行为对象具体名称 动作 时间}
      ints.each{|line|
        csv << line
      }
    end
    
    puts "Generate #{UID}_interactions.csv success"
    
    CSV.open("#{UID}_users.csv", "wb") do |csv|
      csv << %w{UID 性别 微博昵称 认证类型 认证身份 关注数 粉丝数 微博数 微博所在地【省份】 微博所在地【城市】 简介 微博标签 微博关系 身份}
      us.each{|line|
        csv << line
      }
    end
    
    puts "Generate #{UID}_users.csv success"
    
    result
  end
# Intelbiz.importing_excel_sent_comment("ContentIntPlan.xlsx")




 def self.importing_excel_sent_mentions(filename)
  
  #ee = Openoffice.new(filename+".ods")      # creates an Openoffice Spreadsheet instance  
  #ee = Excel.new(filename+".xls")           # creates an Excel Spreadsheet instance  
  #ee = Google.new("myspreadsheetkey_at_google") # creates an Google Spreadsheet instance  
  ee = Roo::Excelx.new(filename) # creates an Excel Spreadsheet instance for Excel .xlsx files  
  ee.default_sheet = ee.sheets.first
  uid = 2295615873

  2.upto(ee.last_row) do |line|

    mention_at = ee.cell(line,'A')
    mention_at = Date.parse(mention_at) if mention_at.is_a? String
    content = ee.cell(line,'B')
    name = ee.cell(line,'C')
    target_uids = ReportUtils.names_to_uids([name],true)
    target_uid =target_uids[0]
    next if target_uid.nil?
    #puts "#{uid}\t#{mention_at}\t#{content}\t#{target_uid}\t"
    wsc = WeiboSentMention.new
    wsc.uid = uid 
    puts "#{wsc.uid}\t"
    wsc.mention_at = mention_at
    puts "#{wsc.mention_at}\t"
    wsc.content = content
    #puts "#{wsc.content}\t"
    wsc.target_uid = target_uid
    #puts "#{wsc.target_uid}\t"
    wsc.save
     
     
   end 
   
  
  end
# ImportingWeiboPrivateMessage.importing_excel_private_message("ContentIntPlan.xlsx")

 def self.importing_excel_private_message(filename)
  
  #ee = Openoffice.new(filename+".ods")      # creates an Openoffice Spreadsheet instance  
  #ee = Excel.new(filename+".xls")           # creates an Excel Spreadsheet instance  
  #ee = Google.new("myspreadsheetkey_at_google") # creates an Google Spreadsheet instance  
  ee = Roo::Excelx.new(filename) # creates an Excel Spreadsheet instance for Excel .xlsx files  
  ee.default_sheet = ee.sheets.first

  2.upto(ee.last_row) do |line|
    puts line
     uid = 2295615873
     send_at = ee.cell(line,'A')
     send_at = Date.parse(send_at) if send_at.is_a? String
     content = ee.cell(line,'B')
     name = ee.cell(line,'C')
     target_uids = ReportUtils.names_to_uids(%w{name},true)#10秒落泪的感性和平1993
     target_uid =target_uids[0]
     
     #puts "#{uid}\t#{send_at}\t#{content}\t#{target_uid}\t"
     wpm = WeiboPrivateMessage.new
     
     wpm.uid = uid 
#puts "#{wpm.uid}\t"
     wpm.send_at = send_at
#puts "#{wpm.send_at}\t"
     wpm.content = content
#puts "#{wpm.content}\t"
     wpm.target_uid = target_uid
#puts "#{wpm.target_uid}\t"
    wpm.save
     
     
   end 
   
  
  end




end
