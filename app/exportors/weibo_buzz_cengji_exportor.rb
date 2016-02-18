# -*- encoding : utf-8 -*-
class WeiboBUZZCengExportor < ExportorBase

  description <<EOF
    接口根据url列表 导出微博BUZZ声量和传播层级
EOF

  title '微博BUZZ&&传播层级(根据urls)'

  before do |this,opts|
    #TODO:
    @urls = case 
      when opts[:urls].is_a?(String)
        opts[:urls].split("\r\n").map{|line| line.blank? ? nil : line.strip}.compact
      when opts[:urls].is_a?(Array)
        opts[:urls]
      else
      end
  end

  export name:"微博BUZZ&&传播层级" do |ins,opts|
    ins.get_buzz_cengji(@urls)
  end

  def get_buzz_cengji(urls)
    require 'rseg'
    Rseg.load
    #全局变量统计关键词数量
      keywords = %w{安腾 Itanium 凌动 Atom Xeon 酷睿i3 酷睿i5 酷睿i7 Core i3 Core i5 Core i7 Intel 英特尔 Intel 平板 英特尔 平板 PC平板2合1 PC平板二合一 二合一超极本 二合一电脑 平板PC2合1 平板PC二合一}#文件的路径
      words_stats = {}
      keywords.each{|word|
        word = word.strip
        words_stats[word] = 0
      }
      rows << %w{URL BUZZ声量 传播层级}
      urls.each do |url|
        weibo_id = WeiboMidUtil.str_to_mid URI.parse(url.strip).path.split("/").last
        forwards = WeiboForward.where("weibo_id = ?",weibo_id)
        comments = WeiboComment.where("weibo_id = ?",weibo_id)
         # 转发
        if !forwards.blank?
          forwards.each do |forward|
          #得到一个用户信息对象
          forward_text = MForward.find_by_id(forward.forward_id)
          if !forward_text.blank?
            ftext = forward_text.text.strip
            @str = ""
            keywords.each{|w|
              @key = w.strip
              if ftext.include?(@key)
                @str += @key
                @str = @str += ","
                words_stats[@key] += 1
              end
            }
          end
        end
      end
    
      # 评论
      if !comments.blank?
        comments.each do |comment|
          #得到一个用户信息对象
          comment_text = MComment.find_by_id(comment.comment_id)
          if !comment_text.blank?
            @str = ""
            ctext = comment_text.text.strip
            keywords.each{|w|
              @key = w.strip
              if ctext.include?(@key)
                @str += @key
                @str = @str += ","
                words_stats[@key] += 1
              end
            }
          end
        end
      end
      
      num = words_stats.values.sum
      #每循环一个连接都要清空一下values
      keywords.each{|w|
        @key = w.strip
        words_stats[@key] = 0
      }
      
      #以上是BUZZ声量
      
      #以下是传播层级
      WeiboForward.analyze_tree(weibo_id)
        records = WeiboForwardRelation.find_by_sql <<-EOF
          select depth,count(*) as num from weibo_forward_relations where weibo_id = #{weibo_id} group by depth 
        EOF
        a = 0
        b = 0
        records.each do |line|
          a = a + line.depth*line.num
          b = b + line.num
        end
        if b != 0
          c = a.to_f/b.to_f
            rows << [url,c,num]
          elsif
            rows << [url,0,num]
        end
    end
  end
end
