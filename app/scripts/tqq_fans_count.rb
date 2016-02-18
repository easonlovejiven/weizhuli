# -*- encoding : utf-8 -*-
class TqqFansCount
   def self.export_tqq_fans_count_to_xlsx()
      @date = Time.now.strftime("%Y-%m-%d %H:%S")
      @list = []
      @filename  = "腾讯总粉丝_#{@date}.xlsx"
      task = GetTqqBasicTask.new
      title = []
       #%w{英特尔中国 	戴尔中国	 联想	 Snapdragon骁龙	 三星电子 	杜蕾斯 	易迅网 }
      openids  = ["0B6A468C0642625453023BFB0D1B8570", "A6AD5631683AA595967D945FB78DB61C", 
                 "2B7C9EE9B6878DF1E1C4EC28ED7EEE15", "997B01BB7EA298442DC62C8912FF57AD", 
                 "43AFF8C3E6A0A98B653F56BE78535199", "334FF584F2A77237CDE67F58B1DA20CF",
                  "8553E3309EDF8235F4CB846C6396DB35"]
      openids.each do |openid|
        nick = TqqAccount.find_by_openid(openid).nick
        title << nick
      end
      
      
      @list << title 
      row = []
      openids.each do|openid| 
        puts openid
        begin #解决异常      
          res = task.stable{task.api.user.other_info(fopenid:openid)}
          res.blank?? row << openid : row << res.data.fansnum
        rescue Exception=>e
          if e.message =~ /User does not exists!/
            row << [openid]
          else
            row << [openid]
          end
        end

      end
      @list << row 
      ReportUtils.list_export(@filename,@list,mail_to:"wangjuan@weizhuli.com,riddle.zhang@weizhuli.com,yawei.zhang@weizhuli.com,yuying@weizhuli.com,haobing@weizhuli.com,nana.tian@weizhuli.com")

   end

end
