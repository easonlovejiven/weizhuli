# -*- encoding : utf-8 -*-
class ReportUtils


=begin
1924531943, 2637370927
ReportUtils.export_weibo_list_to_csv([2637370247],"data/超级本2013-11-06.csv",start_time:Time.new(2011,1,1),end_time:Time.new(2013,11,7))

#根据名字从接口 拿 用户数据
ReportUtils.names_to_uids(%w{金融街购物中心微博 },true)
ReportUtils.export_fans_list([2637370927],"data/中国粉丝列表.csv",start_time:Time.new(2014,5,14),end_time:Time.new(2014,5,21))
  ReportUtils.names_to_uids(names)
ReportUtils.export_weibo_list([1678281133],"data/微博列表2.csv",Time.new(2012,1,13),Time.new(2014,8,8))
=end
  # export weibo list to csv by names
  #   for moniting uids
  def self.export_weibo_list_to_csv_by_name(names,filename,opts={})

    uids = names_to_uids(names)
    return if uids.blank?
    export_weibo_list_to_csv(uids,filename,opts)

  end
 # export weibo list to csv by names
  #   for moniting uids   通过接口 提取
  def self.export_weibo_list_to_csv_by_name_for_Interface(names,filename,opts={})

    uids = names_to_uids(names)
    return if uids.blank?
    export_weibo_list(uids,filename,opts)

  end
  

  # export weibo list to csv by uids
  # => for moniting uids
  # =>   opts :  
  # =>          start_time  >= 'date'
  # =>          end_time < 'date'
  def self.export_weibo_list_to_csv(uids,filename,opts={})

    start_time = opts[:start_time]
    end_time = opts[:end_time]
    scope = WeiboDetail.where("uid in (?)",uids)
    scope = scope.where("post_at >= ?",start_time) if start_time
    scope = scope.where("post_at < ?",end_time) if end_time

    scope = scope.order("uid, post_at asc")

    accounts = {}

    CSV.open filename, "wb" do |csv|
      csv << %w{UID 内容 时间 转发 评论 URL 来源 类型 原创}
      scope.each{|record|

        accounts[record.uid] ||= WeiboAccount.find_by_uid(record.uid)
        account = accounts[record.uid]

        c = MWeiboContent.find(record.weibo_id)
        next if c.nil?
        srouce = ActionView::Base.full_sanitizer.sanitize(c.source)
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

        origin = !record.forward

        post_at = record.post_at.strftime("%Y-%m-%d %H:%M:%S")
        csv << [account.screen_name, c.text,post_at, record.reposts_count, record.comments_count, record.url, srouce, type, origin]
      }
    end
  end

  # convert names to uids, load from database, or from API
  def self.names_to_uids(names,auto_load = false,opts={} )
    task = GetUserTagsTask.new

    uids = []
    bad_names = []
    names.each{|n|
      n = n.strip
      if n.blank?
        uids << nil
      else
        record = WeiboAccount.find_by_screen_name(n)
        if record
          uids << record.uid
        elsif  auto_load
          begin
          res = task.stable{task.api.users.show(screen_name:n)}
          task.save_weibo_user res
          uids << res.id
          rescue Exception
            raise $! unless $!.message =~ /exists/
            uids << nil
            bad_names << n
          end
        else
          uids << nil
          bad_names << n
        end
      end
    }


    if !bad_names.blank?
      puts "bad screen names or not in database: \n#{bad_names*"\n"}"
    end

    if opts[:with_bad_names]
      return {uids:uids,bad_names:bad_names}
    else
      return uids
    end

  end


  # fix MWeiboContent  which in mysql table but not in mongo
  def self.fix_weibo_detail_in_mongo(uids)
    task = GetUserTagsTask.new
    uids.each{|uid|
      WeiboDetail.where(uid:uid).each{|w|
        mw = MWeiboContent.find(w.weibo_id)
        if mw.nil?
          begin
            weibo = task.stable{task.api.statuses.show(id:w.weibo_id.to_s)}
            weibo['feature'] = []
            task.save_weibo weibo
          rescue Exception
            raise $! unless $!.message =~ /target weibo does not exist/
          end
        end
      }
    }
  end

  # load and export all weibo list for <uids> into <filename>
  #   uids are not in monit database #高通中国：1738056157 2 英特尔中国：2637370927, 金融街购物中心微博： 1924531943 
  #ReportUtils.export_weibo_list [2637370927],"data/xiaowen_intel_or_AMD_weibo_list.csv",
  def self.export_weibo_list uids, filename, start_time, end_time

    task = GetUserTagsTask.new
    CSV.open(filename,"wb"){|csv|
      csv << %w{name 微博内容 发布时间 转发数 评论数 互动总数 URL 原创 原微博UID 发布来源  }
      
      uids.each{|uid|
        puts "Processing uid : #{uid}"
        top_id = nil
        task.paginate(:per_page=>100) do |page|
         
          begin
#debugger          
            res = task.stable{task.api.statuses.user_timeline(uid:uid,count:100, page:page)}
            processing = true
           if !res['statuses'][0].nil?
              if page == 1
                if Time.parse(res['statuses'][0].created_at)< Time.parse(res['statuses'][1].created_at)
                top_id = res['statuses'][0].id
                end
               end
              

              res['statuses'].each{|w|
                next if w.id == top_id
                puts w.created_at
                next if end_time && Time.parse(w.created_at) > end_time
                if Time.parse(w.created_at) > start_time

                  srouce = ActionView::Base.full_sanitizer.sanitize(w.source) #去出所有的标签

                  url = "http://weibo.com/#{uid}/#{WeiboMidUtil.mid_to_str(w.id.to_s)}"

                  post_at = Time.parse(w.created_at).strftime("%Y-%m-%d %H:%M")
                  count = w.reposts_count + w.comments_count
                  origin = !w.retweeted_status
                  csv << [w.user.screen_name, w.text,post_at, w.reposts_count, w.comments_count,count, url,origin, origin ? nil : w.retweeted_status["user"]["id"], srouce]

                else
                  processing = false
                  break
                end
              }
  
           end

            processing ? res.total_number : 0
          rescue Exception=>e
            0
          end

        
        end
      }

    } && nil
    nil
  end





  def self.check_weibo_user_quality(scope=nil)

    target_uid = intel


    scope ||= WeiboAccount.joins("left join weibo_user_relations rel on rel.by_uid = weibo_accounts.uid").
                where("rel.uid = ?",target_uid)

    task = GetUserTagsTask.new
    index = 0
    while true
      as  = scope.where("weibo_accounts.forward_rate = -1").limit(1000)
      as.each{|a|
        index += 1
        puts "#{index} loading for #{a.uid}"
        a = WeiboAccount.find(a.id)
        res = task.stable{task.api.statuses.user_timeline(uid:a.uid,count:100)}
        forwards = res.statuses.sum(&:reposts_count)
        comments = res.statuses.sum(&:comments_count)

        forwarded_weibos = res.statuses.count{|s|s.reposts_count > 0}
        commented_weibos = res.statuses.count{|s|s.comments_count > 0}

        status_size = res.statuses.size.to_f

        if status_size > 0
          forward_rate = (forwarded_weibos.to_f / status_size * 100).to_i
          comment_rate = (commented_weibos.to_f / status_size * 100).to_i

          forward_average = (forwards.to_f /  status_size * 100).to_i
          comment_average = (comments.to_f /  status_size * 100).to_i
        else
          forward_rate = 0
          comment_rate = 0

          forward_average = 0
          comment_average = 0
        end

        a.update_attributes(forward_rate:forward_rate,forward_average:forward_average,comment_rate:comment_rate,comment_average:comment_average)

      }

      break if as.blank?
    end
  end


  # 导出 uids 的粉丝列表
  def self.export_fans_list(uids,filename,opts={})
    CSV.open(filename,"wb"){|csv|
      start_time = opts[:start_time]  # fans follow time start
      end_time = opts[:end_time]  # fans follow time end
      limits = opts[:limits]  # export results limit
      row_type = opts[:row_type]  # export row columns type
      with_tags = opts[:with_tags]  # export with user tags
      with_quality = opts[:with_quality]  # export with user quality
      blue_v = opts[:blue_v]  # export only blue v user
      yellow_v = opts[:yellow_v]  # export only yellow v
      row_type = :full if with_tags
      row_type = :quality if with_quality
      uids.each{|uid|
uid
      count = 0
      csv << %w{帐号 UID 昵称 位置 性别 粉丝 关注 微博 注册时间 认证类型 认证原因   关注时间}
        m = MonitWeiboAccount.find_by_uid(uid)
        page = 1
        processing  = true
        while true
          break  if processing == false
          puts "exporting page #{page}"
          relations = WeiboUserRelation.where(uid:uid)
          relations = relations.where("follow_time >= ?",start_time) if start_time
          relations = relations.where("follow_time < ?",end_time) if end_time
          relations = relations.paginate(per_page:1000,page:page)
          break if relations.blank?
          relations.each{|rel|
            # limits
            if limits && count > limits
              break
              processing = false
            end   
            a = WeiboAccount.find_by_uid(rel.by_uid)
            next if a.nil? # || a.forward_rate.nil? || a.forward_rate < 0

            if blue_v || yellow_v
              if blue_v && (1..7).include?(a.verified_type)
              elsif yellow_v && a.verifiedified_type == 0
              else
                next
              end
            end
            row = a.to_row(row_type)
            # tags
            if with_tags
              has_tags = row[11].split(",").sum{|tag| with_tags.include?(tag) ?  1 : 0 }
              next if has_tags == 0
            end
            row.unshift m.screen_name
            follow_time = rel.follow_time ? rel.follow_time.strftime("%Y-%m-%d %H:%M") : nil
            row << follow_time
    #        row << a.forward_rate.to_f/100
    #        row << a.forward_average.to_f/100
    #        row << a.comment_rate.to_f/100
    #        row << a.comment_average.to_f/100
            # forwards = WeiboForward.where(uid:target_uid, forward_uid:rel.by_uid).count
            # comments = WeiboComment.where(uid:target_uid, comment_uid:rel.by_uid).count
            # mentions = WeiboMention.where(uid:target_uid, mention_uid:rel.by_uid).count
            # row << forwards
            # row << comments
            # row << mentions

            csv << row
            count += 1
          }

          page += 1
        end
      }


    }

  end

  # 通过 API 检测 UID 是否 是 target_uid 的粉丝
  def check_following_status(target_uid,uids,file_name)
    task = GetUserTagsTask.new

    CSV.open file_name, "wb" do |csv|
      uids.each_with_index{|uid,index|
        begin
          rel = task.stable{task.api.friendships.show(source_id:uid, target_id:target_uid)}
          following = rel.target.followed_by ? true : false
          csv << [uid, following]
          puts "#{index} \t #{uid}"
        rescue Exception=>e
          if e.message =~ /exist/
          else
            raise e
          end
        end
      }
    end
  end

  

  def self.export_weibo_users_by_names(names,filename,opts={})
    uids = names_to_uids(names,true)
    export_weibo_users_by_uids(uids, filename,opts)
  end


  def self.export_weibo_users_by_uids(uids,filename,opts={})
    ar = []
    row_type = opts[:row_type] || :default
    ar << WeiboAccount.to_row_title(row_type)
    uids.each{|uid|
      a = WeiboAccount.find_by_uid uid

      if !a.nil?
        ar << a.to_row(row_type)
      else
        ar << [uid]
      end
    }

    list_export(filename,ar)
  end


  def self.list_export(filename,list,opts = {})
    case File.extname(filename).downcase
    when '.xlsx'
      Axlsx::Package.new do |p|
        p.workbook.add_worksheet(:name => "sheet1") do |sheet|
          list.each{|row| sheet.add_row row}
        end
        p.serialize(filename)
      end
    when '.csv'
      CSV.open(filename,"wb") do |csv|
        list.each{|row| csv << row}
      end
    else
      raise "Don't support export type for file #{filename}. only support xlsx|csv"
    end


    mail_to = opts[:mail_to]
    if opts[:mail_to]
      Notifier.report(to:opts[:mail_to],subject:(opts[:mail_subject]||File.basename(filename)),
          attachments:[[File.basename(filename),filename]]).deliver
    end
  end

  # 此方法已被修改用于 微博精选
  def self.search_weibo_interface_by_keywords_time(keywords,filename,opts,&block) #start_time:开始时间,end_time：结束时间，filename:导出文件名，keywords:关键词数组

      te = TextEvaluate.new

      start_time = opts[:start_time]  # 搜索时间范围：开始时间，空值则不限时间
      end_time = opts[:end_time]  # 搜索时间范围：结束时间，空值则截止到现在
      sum = opts[:sum]  # 搜索结果集总数限制，为所有关键词搜索结果的总和，如果达到该值，则后边即使还有关键词 也会停止搜索
      province = opts[:province]  # 用户省份范围

      with_eva = opts[:with_eva] || false  # 结果是否包含内容的 正负面 评价

      filter_skip_bluev = opts[:skip_bluev] || false  # 是否跳过 蓝V用户
      filter_skip_negative = opts[:skip_negative] || false  # 是否跳过 负面内容
      filter_skip_words = opts[:skip_words] || nil          # /a|b|c/  是否跳过正则表达式给定的关键词
      filter_include_words = opts[:include_words] || nil   # /a|b|c/  是否 只包含 正则表达式给定的词
      filter_skip_dup_uid = opts[:skip_dup_uid] || false  # 是否去除 重复的UID
      opt_antispam = opts[:antispam] || 1
      opt_dup = opts[:dup] || 1
      opt_hasret = opts[:hasret] || nil
      opt_hasori = opts[:hasori] || nil

      uids = []

      task = GetUserTagsTask.new
      CSV.open filename,"wb" do|csv|

        csv << WeiboAccount.to_row_title(:default)+%w{keyword 微博url 是否转发 发布时间 内容 来源  转发数 评论数}
           begin
            keywords.each do|keyword|
              if end_time.blank?
                endtime = Time.now.to_i
              else
                endtime = Time.parse(end_time).to_i
              end
              puts keyword
              q = keyword
              url = "https://c.api.weibo.com/2/search/statuses/limited.json?"
              number = 0
                processing = true
                retries = 0
                while (processing == true) do
                  pas={access_token:($SEARCH_TOKEN||"2.005wKAMBDtpNADc71e3fbde2T8XNWB"),q:q,endtime:endtime,count:50,antispam:opt_antispam,dup:opt_dup,hasret:opt_hasret,hasret:opt_hasret} #定义一个hash 用来存参数用 to_query 方法追加
                  pas[:province] = province if province
                  res = task.stable(retry_limit:500, retry_interval:10){Hashie::Mash.new(JSON.parse(open(url+pas.to_query).read))}
                  puts "endtime:#{endtime}"
                  puts "total_number:#{res.total_number}"
                  if !res.statuses.blank?
                    retries = 0
                    endtime = Time.parse(res.statuses.last.created_at).to_i - 2
                    puts 'h'+ endtime.to_s
                    puts '本组 获取statuses 结束时间 '+ endtime.to_s
                    res.statuses.each do|status|

                      user = status.user


                      if !start_time.blank? && (Time.parse(status.created_at).to_i < Time.parse(start_time).to_i) #控制提取时间
                        processing = false
                        break
                      end
                      if !sum.blank? && uids.size >= sum.to_i #控制最多打印的个数
                        processing = false
                        break
                      end

                      #
                      # filters
                      #
                      if filter_skip_bluev
                        # 跳过 蓝V
                        if user.verified_type.to_i > 0 && user.verified_type.to_i <= 7
                          puts "跳过蓝V"
                          next 
                        end
                      end


                      if filter_include_words
                        # 只包含关键词
                        if !(status.text =~ filter_include_words)
                          puts "未包含关键词 #{filter_include_words}"
                          next 
                        end
                      end

                      if filter_skip_words
                        # 跳过关键词
                        if status.text =~ filter_skip_words
                          puts "跳过关键词 #{filter_skip_words}"
                          next 
                        end
                      end

                      if filter_skip_dup_uid && uids.include?(user.id)
                        puts "跳过重复 UID"
                        next 
                      end



                      eva = eva_word = nil
                      if with_eva
                        eva, eva_word = te.evaluate(status.text)
                      end
                      if filter_skip_negative
                        # 正负面判断 
                        eva, eva_word = te.evaluate(status.text) if eva == nil
                        if eva < 0
                          puts "跳过负面 #{eva_word}"
                          next 
                        end
                      end

                      if block && !block.call(status)
                        puts "跳过 自定义过滤"
                        next 
                      end


                      source=ActionView::Base.full_sanitizer.sanitize(status.source)
                      url1 = "http://weibo.com/#{status.user.id.to_s}/#{WeiboMidUtil.mid_to_str(status.idstr)}"
                      is_forward = !status.retweeted_status.nil?
                      created_at = Time.parse(status.created_at)
                      genders = {'m'=>"男",'f'=>"女"}
                      gender = genders[user.gender]
                      verified_type = WeiboAccount.human_verified_type(user.verified_type)*','




                      number +=1
                      puts "number:#{number}"
                      uids << user.id

                      csv << [user.id,user.screen_name,user.location,gender,user.followers_count,user.friends_count,user.statuses_count,Time.parse(user.created_at),verified_type,user.verified_reason] + [keyword, url1,is_forward,created_at,status.text,source,status.reposts_count,status.comments_count, eva, eva_word]              

                      if  false && MSumsungUid.find_by_id(user.id.to_i).blank?
                        MSumsungUid.create(
                          id:user.id.to_i,
                          screen_name:user.screen_name,
                          location:user.location,
                          gender:user.gender,
                          followers_count:user.followers_count,
                          friends_count:user.friends_count,
                          statuses_count:user.statuses_count,
                          created_at:Time.parse(user.created_at),
                          verified_type:user.verified_type,
                          verified_reason:user.verified_reason,
                          status:0
                        )

                      end


                    end
                  end
                   
                  if res.statuses.blank? || res.total_number<50 
                    if retries >= 5
                     puts '结果为空'
                     processing = false
                    else
                      puts "空结果， 重试第 #{retries} 次, endtime: #{endtime}"
                      retries += 1
                      endtime -= 3600*24*retries
                    end
                  end
                end
              end


            rescue SystemExit, Interrupt,IRB::Abort
              raise

            rescue Exception=>e
              puts "#{e.class}\n#{e.message}"
            end
      end
  end






end






