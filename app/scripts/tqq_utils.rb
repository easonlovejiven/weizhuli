# -*- encoding : utf-8 -*-
class TqqUtils
=begin
TqqUtils.export_weibo_list(
    ['0B6A468C0642625453023BFB0D1B8570'],
    "data/intel_tqq_weibo_list.csv",
    '2014-01-19','2014-01-26'
  )
TqqUtils.export_weibo_list_to_csv(
    ['0B6A468C0642625453023BFB0D1B8570'],
    "data/intel_tqq_weibo_list_1101-1129.csv",
    start_time:Time.new(2013,11,1),end_time:Time.new(2013,11,30)
  )
 联想：2B7C9EE9B6878DF1E1C4EC28ED7EEE15  中国：0B6A468C0642625453023BFB0D1B8570
TqqUtils.export_fans_for_moniting(['0B6A468C0642625453023BFB0D1B8570'],"tqq_联想库全部粉丝列表.csv",start_time:Time.new(2013,9,16),end_time:Time.new(2013,9,23))
 
=end
  # WARNING:根据名字查询openid
  def self.names_to_openids(names,auto_load = false )

    task = GetTqqWeiboTask.new
    openids = []
    bad_names = []
     
    names.each{|n|
       nick = n.strip
     if nick.blank?
        openid << nil
     else
        record = TqqAccount.find_by_name(nick)
       if record

        openids << record.openid
       elsif  auto_load
        begin

        res = task.stable{task.api.user.other_info(nick:nick).data}
        task.save_weibo_user res
        openids << res.openid

        rescue Exception
          raise $! unless $!.message =~ /exists/
          openids << nil
          bad_names << n
        end
        
      else
        openids << nil
        bad_names << n
      end
     end
    }


    if !bad_names.blank?
      puts "bad names or not in database: \n#{bad_names*"\n"}"
    end

    return openids

  end



  # export weibo list to csv by openids
  # => for moniting openids
  # =>   opts :  
  # =>          start_time  >= 'date'
  # =>          end_time < 'date'
  def self.export_weibo_list_to_csv(openids,filename,opts={})

    start_time = opts[:start_time]
    end_time = opts[:end_time]
    scope = TqqWeiboDetail.where("openid in (?)",openids)
    scope = scope.where("post_at >= ?",start_time) if start_time
    scope = scope.where("post_at < ?",end_time) if end_time

    scope = scope.order("openid, post_at asc")

    accounts = {}

    CSV.open filename, "wb" do |csv|
      csv << %w{name 昵称 内容 时间 转发 评论 URL 来源 类型 原创}
      scope.each{|record|

        accounts[record.openid] ||= TqqAccount.find_by_openid(record.openid)
        account = accounts[record.openid]

        c = MTqqWeiboContent.find(record.weibo_id.to_s)
        next if c.nil?
        srouce = c.from
        type = case 
          when record.is_image? && record.is_video
            "image + video"
          when record.is_image?
            "image"
          when record.is_video?
            "video"
          when record.is_music?
            "music"
          else
            "text"
        end

        origin = record.is_origin?

        post_at = record.post_at.strftime("%Y-%m-%d %H:%M:%S")
        csv << [account.name, account.nick, c.text,post_at, record.count, record.mcount, record.url, srouce, type, origin]
      }
    end
  end

#0B6A468C0642625453023BFB0D1B8570 2B7C9EE9B6878DF1E1C4EC28ED7EEE15 43AFF8C3E6A0A98B653F56BE78535199 A6AD5631683AA595967D945FB78DB61C
 #TqqUtils.export_fans_list_to_csv(%w{0B6A468C0642625453023BFB0D1B8570 2B7C9EE9B6878DF1E1C4EC28ED7EEE15 43AFF8C3E6A0A98B653F56BE78535199 A6AD5631683AA595967D945FB78DB61C},"fans_list_20130906.csv")


  def self.export_fans_for_moniting(openids,filename,opts={})
    task = GetTqqBasicTask.new
    start_time = opts[:start_time]
    end_time = opts[:end_time]
    limit = opts[:limit]
    mail_to = opts[:mail_to]

    accounts = {}

    CSV.open filename, "wb" do |csv|
 
      csv << %w{主号 openid	name	nick	微博数 	收听数 	听众数 	location 创建时间	性别	经验 等级	实名认证	 vip	认证类型 关注时间}

      openids.each{|openid|
        m = MonitTqqAccount.find_by_openid openid
        scope = TqqUserRelation.where("openid = ?",openid)
        scope = scope.where("follow_time >= ?",start_time) if start_time
        scope = scope.where("follow_time < ?",end_time) if end_time
        scope = scope.limit(limit) if limit
        
        scope = scope.order("openid, follow_time asc")
        scope = scope.select("distinct by_openid,follow_time").group("by_openid")

        scope.each_with_index{|record,index|

          a = TqqAccount.find_by_openid(record.by_openid)
          if a.nil?
            begin
              a = task.load_weibo_user(openid:openid)
            rescue Exception=>e
               if  e.message =~ / does not exists!/
                 next
               end
            end
          end
          row = a.to_row
          row.unshift(m.nick)
          row << record.follow_time

          csv << row
          
        }

      }
    end


    if mail_to
      Notifier.report(to:mail_to,
        subject:"#{openids.size}用户粉丝信息列表",
        attachments:[[File.basename(filename), filename]]
        ).deliver
    end

  end


#   TqqUtils.export_fans_for_other '0B6A468C0642625453023BFB0D1B8570',"英特尔中国_fans.csv"
  def self.export_fans_for_other(openids,filename,opts={})
    limit = opts[:limit]
    limit_per_user = (opts[:limit_per_user] || 1000).to_i
    limit_per_user = 10000 if limit_per_user > 10000
    mail_to = opts[:mail_to]

    accounts = {}


    task = MonitTqqAccount.first.get_weibo_task

    CSV.open filename, "wb" do |csv|
 
      csv << ["帐号"] + TqqAccount::to_row_titles


      openids.each{|openid|
        ma = task.load_weibo_user(openid:openid)

        number = 0
        per_page = 30
        page = 0
        new_openids = []
        mode =  limit_per_user <= 1000 ? 1 : 0
        puts("load #{mode == 1 ? '10K' : '1K'} followers from api")

        while true
          break if number > limit_per_user

        
          startindex = per_page * page
          res = task.stable{task.api.friends.user_fanslist(fopenid:openid,reqnum:per_page,mode:mode,startindex:startindex)}
          rels = res.data.try(:info) || []
          rels.each{|rel|
            break if number > limit_per_user
            a = task.load_weibo_user openid:rel.openid

            next if a.nil?

            row = a.to_row
            csv << [ma.name] + row


            number += 1
          }
          puts("get #{rels.size} followers in page #{page} ")
          break if res.data.nil? || res.data.hasnext == 1
          page += 1
        end


      }
    end


    if mail_to
      Notifier.report(to:mail_to,
        subject:"#{openids.size}用户粉丝信息列表",
        attachments:[[File.basename(filename), filename]]
        ).deliver
    end

  end



  # load and export all weibo list for <openids> into <filename>
  #   openids are not in monit database
  def self.export_weibo_list openids, filename, start_time, end_time

    start_time = Time.parse(start_time)
    end_time = Time.parse(end_time)

    task = MonitTqqAccount.first.get_weibo_task

    CSV.open(filename,"wb"){|csv|

      csv << %w{帐户 内容 发送时间 转发 评论 URL 来源 类型}

      openids.each{|openid|
        ma = task.load_weibo_user openid:openid
        puts "Processing openid : #{openid}"

        page = 1
        hasnext = true
        last_time = start_time.to_i
        processing = true
        
        while processing && hasnext
        
          begin
            puts "load weibos for #{ma.name}, page #{page} time start: #{Time.at(last_time)}"
            res = task.stable{task.api.statuses.user_timeline({:pageflag=>2, :fopenid=>openid,:reqnum=>70,:pagetime=>last_time.to_i+1})}


            if res.data
              res.data.info.size.downto(1){|i|
                post = res.data.info[i-1]

                last_time = post.timestamp
                post_at = Time.at(last_time)
                if post_at <= end_time && post_at >= start_time

                  srouce = post.from

                  url = "http://t.qq.com/p/t/#{post.id}"

                  post_at = post_at.strftime("%Y-%m-%d %H:%M")
                  csv << [post.name, post.text,post_at, post[:count], post.mcount, url, srouce,TqqWeiboDetail::human_type(post[:type])]

                else
                  processing = false
                  break
                end
              } 

              hasnext = res.data.hasnext == 0

            end

          rescue IRB::Abort,SystemExit, Interrupt
            raise $!

          rescue Exception=>e
            puts e.message
          end
          page += 1
        end
      }
    } && nil
    nil
  end




end

