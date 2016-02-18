def aaa(keywords,filename,opts,&block) #start_time:开始时间,end_time：结束时间，filename:导出文件名，keywords:关键词数组

      te = TextEvaluate.new
      
      
      no_sources = opts[:no_sources] #过滤掉这些微薄来源 
      start_time = opts[:start_time]  # 搜索时间范围：开始时间，空值则不限时间
      end_time = opts[:end_time]  # 搜索时间范围：结束时间，空值则截止到现在
      sum = opts[:sum]  # 搜索结果集总数限制，为所有关键词搜索结果的总和，如果达到该值，则后边即使还有关键词 也会停止搜索
      province = opts[:province]  # 用户省份范围 #这个暂时不用考虑

      with_eva = opts[:with_eva] || false  # 结果是否包含内容的 正负面 评价 这个也不用考虑

      filter_skip_bluev = opts[:skip_bluev] || false  # 是否跳过 蓝V用户
      filter_skip_negative = opts[:skip_negative] || false  # 是否跳过 负面内容
      filter_skip_words = opts[:skip_words] || nil          # /a|b|c/  是否跳过正则表达式给定的关键词
      filter_include_words = opts[:include_words] || nil   # /a|b|c/  是否 只包含 正则表达式给定的词
      filter_skip_dup_uid = opts[:skip_dup_uid] || false  # 是否去除 重复的UID
      
      filter_max_status = opts[:filter_max_status] #微薄数量控制
      filter_min_status = opts[:filter_min_status]
      filter_max_fans = opts[:filter_max_fans] #微薄粉丝量控制
      filter_min_fans = opts[:filter_min_fans]

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
                  pas={access_token:"2.005wKAMBDtpNAD311a7e19a70ues3Z",q:q,endtime:endtime,count:50,antispam:0,dup:0} #定义一个hash 用来存参数用 to_query 方法追加
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
                      if !filter_max_status.blank? && user.statuses_count >= filter_max_status.to_i #控制最多打印的个数
                        processing = false
                        break
                      end
                      
                      if !filter_min_status.blank? && user.statuses_count <= filter_min_status.to_i #控制最多打印的个数
                        processing = false
                        break
                      end
                      
                      if !filter_min_fans.blank? && user.followers_count <= filter_min_fans.to_i #控制最多打印的个数
                        processing = false
                        break
                      end
                      
                      if !filter_max_fans.blank? && user.followers_count >= filter_max_fans.to_i #控制最多打印的个数
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

                      if no_sources.include?(ActionView::Base.full_sanitizer.sanitize(status.source))
                        puts "不要这些来源"
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
  
  
  #方法调用
  
  #调用这个方法
      #keywords,filename,opts,&block
      no_sources = ['皮皮时光机','vivo_Xplay','么么哒4G','一加手机','OPPO_N1mini','云中小鸟','孔明社交管理','Beauty小微','定时showone','粉丝大本营','搞笑达人','我的微播炉','简网','时光机','好保姆','活力兔','语录类','创意类','时尚类','红人类','搞笑类','职场类','星座类','漫画类','风景类','娱乐类','亲子类','美食类','女性类','汽车类','淘宝网','悄悄喜欢你']
      start_time = '2014-01-01'
      end_time = '2014-12-12'
      sum = 20000
      filter_max_status = 90000
      filter_min_status = 100
      filter_max_fans = 30000
      filter_min_fans = 100
      
      aaa(['物理学家霍金'],'测试关键词文件2.csv',{no_sources:no_sources,start_time:start_time,end_time:end_time,sum:sum,filter_max_status:filter_max_status,filter_min_status:filter_min_status,filter_max_fans:filter_max_fans,filter_min_fans:filter_min_fans}){|status|
        true
      }
