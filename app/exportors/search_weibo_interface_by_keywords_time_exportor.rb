# -*- encoding : utf-8 -*-
class SearchWeiboInterfaceByKeywordsTimeExportor < ExportorBase

  description <<EOF
  接口提取关键词微博（页码微博搜索接口）限定时间次数 提取
  数据列包括:
   ["UID", "昵称", "位置", "性别", "粉丝", "关注", "微博", "注册时间", "认证信息", "认证原因", "keyword", "微博url","是否转发", "发布时间", "内容", "来源", "转发数", "评论数"]
EOF
  title "接口提取关键词微博(keywords,time,sum)"  #文件名字 SearchWeiboInterfaceByKeywordsTimeExportor.new.export({@keywords:[],start_time:"",end_time:""})



  before do |this,opts|
    #TODO:
    @start_time = opts[:start_time]
    @end_time = opts[:end_time]
    @keywords = case 
            when opts[:keywords].is_a?(String)
              opts[:keywords].split("\r\n").map{|line| line.blank? ? nil : line.strip}.compact
            when opts[:keywords].is_a?(Array)
              opts[:keywords]
            else
            end
    @province = [:province]
    @sum = opts[:sum]

  end

  export name:"提取关键词微博" do |ins,opts|
    ins.export_search_weibo_interface(@keywords,@start_time,@end_time,@sum,@province)
  end

  


# 导出 uids 的粉丝列表
  def export_search_weibo_interface(keywords,start_time,end_time,sum, province)   
      uids = []
      task = GetUserTagsTask.new
      rows << WeiboAccount.to_row_title(:default)+%w{keyword 微博url 是否转发 发布时间 内容 来源  转发数 评论数}
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
                  pas={access_token:"2.005wKAMBDtpNAD2352f32261Ki17gC",q:q,endtime:endtime,count:50} #定义一个hash 用来存参数用 to_query 方法追加
                  pas[:province] = province if province
                  res = task.stable(retry_times:10){Hashie::Mash.new(JSON.parse(open(url+pas.to_query).read))}
                  puts "endtime:#{endtime}"
                  puts "total_number:#{res.total_number}"
                  if !res.statuses.blank?
                    retries = 0
                    endtime = Time.parse(res.statuses.last.created_at).to_i - 2
                    puts 'h'+ endtime.to_s
                    puts '本组 获取statuses 结束时间 '+ endtime.to_s
                    res.statuses.each do|status|
                      if !start_time.blank? && (Time.parse(status.created_at).to_i < Time.parse(start_time).to_i) #控制提取时间
                        processing = false
                        break
                      end
                      if !sum.blank? && uids.size >= sum.to_i #控制最多打印的个数
                        processing = false
                        break
                      end
                      number +=1
                      puts "number:#{number}"
                      source=ActionView::Base.full_sanitizer.sanitize(status.source)
                      url1 = "http://weibo.com/#{status.user.id.to_s}/#{WeiboMidUtil.mid_to_str(status.idstr)}"
                      is_forward = !status.retweeted_status.nil?
                      created_at = Time.parse(status.created_at)
                      use = status.user
                      genders = {'m'=>"男",'f'=>"女"}
                      gender = genders[use.gender]
                      next if uids.include?(use.id)
                      uids << use.id
                      verified_type = WeiboAccount.human_verified_type(use.verified_type)*','
                      rows << [use.id,use.screen_name,use.location,gender,use.followers_count,use.friends_count,use.statuses_count,Time.parse(use.created_at),verified_type,use.verified_reason] + [keyword, url1,is_forward,created_at,status.text,source,status.reposts_count,status.comments_count]              
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
            rescue Exception=>e
              puts "#{e.class}\n#{e.message}"
            end
  end
 
end
