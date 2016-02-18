# -*- encoding : utf-8 -*-
def run
  task = GetContentCountSnapTask.new(1340241374)

  accounts = %w{北京新东方 上海新东方官方微博 武汉新东方 广州新东方学校 西安新东方 杭州新东方学校 新东方天津学校 南京新东方官方微博 深圳新东方 沈阳新东方 重庆新东方学校 成都新东方学校 济南新东方学校 哈尔滨新东方 长沙新东方学校 长春新东方 郑州新东方 太原新东方 昆明新东方学校 新东方南昌学校 南通新东方学校 苏州新东方学校 厦门新东方 石家庄新东方 宁波新东方学校 福州新东方 唐山新东方学校 徐州新东方学校 吉林新东方 乌鲁木齐新东方学校 洛阳新东方学校 新东方兰州学校 新东方呼和浩特学校 镇江新东方学校 大连新东方 青岛新东方 合肥新东方 无锡新东方官方微博 南宁新东方学校 贵阳新东方学校 新东方 新东方泡泡少儿教育 新东方优能中学教育 新东方雅思 新东方留学考试 新东方考研 新东方倍学口语 新东方前途出国留学 新东方在线 新东方大愚图书 新东方迈格森国际教育 新东方国际高中 新东方家庭教育中心 新东方国际游学 新东方满天星 新东方网} 


  users = {}

  accounts.each{|a|

    user_json = task.api.users.show(:screen_name=>a)
    users[user_json.id] = {:info=>user_json}

  }

  users.each{|uid, value|

    puts "load weibos for user #{uid}, #{value[:info].screen_name}"

    weibos = []
    
    page = 1
    finish = false
    while true
      
      ws = task.stable{task.api.statuses.user_timeline(:page=>page, :uid=>uid, :count=>100)}
      
      ws.statuses.each{|post|
        (finish = true; break) if Time.parse(post.created_at) < Time.local(2013,3,6)
        weibos << post
      }
      
      page += 1
      break if finish
    end

    forwards = 0
    comments = 0
    weibos.each{|weibo|
      forwards += weibo.reposts_count
      comments += weibo.comments_count
    }
    
    value[:forwards] = forwards
    value[:comments] = comments
    
    value[:weibos] = weibos
  }


  CSV.open("xindongfang-#{Date.today.to_s}.csv","w") do |csv|

    csv << %w{UID 昵称 粉丝 关注 微博 转发 评论}

    users.each{|uid, values|
      user = values[:info]
      puts user.screen_name
      csv << [uid, user.screen_name, user.followers_count, user.friends_count, user.statuses_count, values[:forwards], values[:comments]]

    }
  end



end

