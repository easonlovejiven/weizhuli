# -*- encoding : utf-8 -*-
class ClassName
  
#通过名字提取微薄列表  并每条微博加上发微博人与英特尔中国互动次数 加从接口 #1193305621
OPENIDS = {
  "75" =>["Alexfan77", "Apple5a1", "c__x_c___", "CarollQ", "chandler0328", "cmleung", "colaileen", "dannylsl", "Definer", "emma的美好生活", "Hanlamp", "IansWorld", "ja-zi-en", "Joyce_Qiubei", "liausliu", "Michelle的蜜", "niuniuforever", "pptangka", "sidneygeng", "Stefanie在漂泊", "TeXd", "TuFangZe", "w26738", "Winnie姜姜", "wxb0712", "yes土不啦叽", "阿伦房田爸", "爱情的牙齿狗狗", "北海战神", "背包客nic", "陈kurt", "嘟嘟囔囔的高大壶", "高勋_pipaMc", "郭小蘑儿", "哈利哥", "睫毛嘻嘻", "看太阳花开的小土豆", "蝌蚪大仙", "-快雪时晴-", "邝小半", "-老刘忙", "狸宝一只", "流亡民-Amor", "棉花糖的王子", "某老杨", "腩Ge", "勤奋的辉姐", "睿肖恩S", "啥都买不起_甭费劲卖广告了", "嗜太稀", "唐塞门儿", "天堂在拐角处", "玩链子的灰机", "薇罗妮卡卡", "我是凡同学", "吴甘沙", "西瓜宁娘娘", "西西里骏马Nelson", "细腿STM", "小帆子哦", "小鱼儿_开始懂了", "宣小宝ashin", "萱葛阁是一颗草莓味儿的妹咂", "雅雅懒猪", "妍子同学", "阳光天秤", "阳光与小麦", "阳台种菜的惬意生活", "鱼尤金", "约力", "泽杏儿BoscoMyolie117", "郑晓大大明", "粥小小小會O_O要吃鱼", "追寻萝土", "资深少女女Rita"],
   "14" =>["名称只是浮云而已", "谢昀辰swimmer", "Hurricanecover", "委员长大人想要小蛮腰", "丁丁bu冒险", "Mut-Cie-Eric", "巴那个乔", "柳小木木", "这峰那疯", "王正ImZheng", "Narson", "何海GAME", "EricZhao", "云清默"],
   "1" =>["委员长大人想要小蛮腰"],
}
#根据 名字 导出 与英特尔中国互动   name:'75'or'13' ,filename: "75-内容-时间.xlsx"  end_time:'2013-09-09'  
#ClassName.export_weibo_list_to_xlsx('14','2013-09-27')
  def self.export_weibo_list_to_xlsx(name,end_time)
           OPENIDS[name]
           @intel = '2637370927' 

           @start_time = Time.parse(end_time)
           @end_time = Time.parse(end_time) + 1.day #Time.parse('2013-09-26'.to_date + 1.day)
           @filename  = "#{name}_内容_#{end_time}.xlsx"   
          names = []
          @list = []
        OPENIDS[name].each do|name|
          names << name.strip 
        end    
            @uids = ReportUtils.names_to_uids(names)
            return if @uids.blank?
           #ReportUtils.export_weibo_list_to_csv_by_name_for_Interface(
           # names,
          #"data/75_weibo_list_0912.csv",Time.new(2013,9,10),Time.new(2013,9,12)
          
        #CSV.open(@filename,"wb"){|csv|
          
          #csv << %w{name  原创 微博内容 发布时间 转发数 评论数 URL 发布来源 微博类型 与英特尔中国转发	 与英特尔中国评论 } #
        @uids.each{|uid|
                 forwards = WeiboForward.where("uid = ? and forward_uid = ?",@intel,uid).where("forward_at between ?     and ?",@start_time,@end_time).count
                  comments = WeiboComment.where("uid = ? and comment_uid = ?",@intel,uid).where("comment_at between ? and ?",@start_time,@end_time).count
          puts "Processing uid : #{uid}"
          top_id = nil
          task = GetUserTagsTask.new
           page = 1

        processing = true
        begin
      
          begin
              res = task.stable{task.api.statuses.user_timeline(uid:uid,count:100, page:page)}# tast.api 连接 接口 ，statuses.user_timeline连接  这个表， uid 要 查的uid  ，count一页显示多少 个 ， page，第几页      
              res2 = task.stable{task.api.statuses.user_timeline(uid:uid,count:100, page:page,feature:2)}['statuses'].map(&:id)
              res3 = task.stable{task.api.statuses.user_timeline(uid:uid,count:100, page:page,feature:3)}['statuses'].map(&:id)
              res4 = task.stable{task.api.statuses.user_timeline(uid:uid,count:100, page:page,feature:4)}['statuses'].map(&:id)
              if page == 1
              if Time.parse(res['statuses'][0].created_at)< Time.parse(res['statuses'][1].created_at)
              top_id = res['statuses'][0].id
              end
              end
              processing = true
              res['statuses'].each{|w|
              next if w.id == top_id
              next if @end_time && Time.parse(w.created_at) > @end_time && @start_time < Time.parse(w.created_at)
              if Time.parse(w.created_at) > @start_time 
                srouce = ActionView::Base.full_sanitizer.sanitize(w.source)
                url = "http://weibo.com/#{uid}/#{WeiboMidUtil.mid_to_str(w.id.to_s)}"   
                !w.retweeted_status ? origin = 'true' : origin = 'false'#是否是原创 
                types = []        
                types << 'image' if res2.include?(w.id)
                types << 'video' if res3.include?(w.id)
                types << 'music' if res4.include?(w.id) # types*","
                types << 'text'  if types.blank?
                post_at = Time.parse(w.created_at).strftime("%Y-%m-%d %H:%M") #时间格式设置           
                @list << [w.user.screen_name,origin,w.text,post_at, w.reposts_count, w.comments_count, url,types*",",srouce,forwards,comments]
              else
                processing = false
                break
              end
            }
            processing ? res.total_number : 0
          rescue Exception=>e
            puts e.message
          end
         page+=1
        end while processing == true
      }
   

 ReportUtils.list_export(@filename,@list,mail_to:"yawei.zhang@weizhuli.com")

    end

   


end
