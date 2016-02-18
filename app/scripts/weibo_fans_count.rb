# -*- encoding : utf-8 -*-
class WeiboFansCount

 def self.export_weibo_fans_count_to_xlsx()
    @date = Time.now.strftime("%Y-%m-%d %H:%S")
    @list = []
    @filename  = "新浪总粉丝_#{@date}.xlsx"
    task = GetUserTagsTask.new 
      #title = %w{英特尔中国	 英特尔知IN 	英特尔商用频道 	英特尔芯品汇 	Qualcomm中国 	Snapdragon骁龙 	联想	 ThinkPad	 东芝电脑 	戴尔中国	 ASUS华硕	 惠普电脑 	杜蕾斯官方微博	 戴尔促销	 ARM中国	 AMD中国	 Acer宏碁  饭团AMD  小米手机  可口可乐  星巴克中国  小米公司 超能双雄}
    title = []
    uids = [2637370927, 1340241374, 2295615873, 
           2637370247, 1738056157, 2619244577, 2183473425, 
           1617785922, 1765189187, 1687053504, 1747360663, 
           1847000261, 1942473263, 1785529887, 2216786767, 
           1883832215, 1775695331, 2027607132, 2202387347, 
           1795839430, 1741514817, 1771925961, 3906939792]
    uids.each do |uid|
      name = WeiboAccount.find_by_uid(uid).screen_name
      title << name
    end
    @list << title
    row = []
    uids.each do|uid| 
      puts uid
      begin #解决异常      
         res = task.stable{task.api.users.show(uid:uid)}
         res.blank?? row << " ": row << res.followers_count
      rescue Exception=>e
         if e.message =~ /User does not exists!/
            row << [uid[0]]
         else
            row << [uid[0]]
         end
      end
    end
    @list << row 
    ReportUtils.list_export(@filename,@list,mail_to:"wangjuan@weizhuli.com,yawei.zhang@weizhuli.com,riddle.zhang@weizhuli.com,yuying@weizhuli.com,haobing@weizhuli.com,nana.tian@weizhuli.com")


 end

end
