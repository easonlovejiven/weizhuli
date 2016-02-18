# -*- encoding : utf-8 -*-
class WeiboForwardRelation < ActiveRecord::Base
  attr_accessible :depth, :lft, :parent_id, :rgt, :weibo_forward_id

  acts_as_nested_set  :scope=>:weibo_id


  belongs_to  :weibo_forward


  # generate gexf file, to opts[:file]
  def self.generate_gexf(weibo_id, opts={})
    root = WeiboForwardRelation.where(weibo_id:weibo_id).root
    nodes = root.self_and_descendants

    builder = Nokogiri::XML::Builder.new(:encoding => 'UTF-8') do |xml|

      xml.gexf(xmlns:"http://www.gexf.net/1.2draft",version:"1.2",
        "xmlns:viz"=>"http://www.gexf.net/1.2draft/viz",
        "xmlns:xsi"=>"http://www.w3.org/2001/XMLSchema-instance",
        "xsi:schemaLocation"=>"http://www.gexf.net/1.2draft http://www.gexf.net/1.2draft/gexf.xsd"){

        xml.meta(lastmodifieddate:Date.today.to_s){

        }
        xml.graph(defaultedgetype:"directed",mode:"static"){
          xml.nodes{
            nodes.each{|node|
              if node.parent_id
                m_forward = MForward.find(node.weibo_forward.forward_id)
                label = m_forward ? m_forward.user.screen_name+":"+m_forward.text : ""
                node_size = 6
                color = {r:250,g:0,b:0}
              else
                weibo = WeiboDetail.find_by_weibo_id(node.weibo_id)
                account = WeiboAccount.find_by_uid(weibo.uid)
                label = account.screen_name
                node_size = 10
                if account.followers_count >= 2000
                  color = {r:250,g:200,b:0}
                else
                  color = {r:10,g:10,b:250}
                end

              end


              xml.node(id:node.id,label:label){
                xml.attvalues
                xml["viz"].size(value:node_size)
                xml["viz"].color(color)
              }
            }
          }
          xml.edges{
            nodes.each{|node|
              next if node.parent_id.nil?
              xml.edge(id:node.id,source:node.parent_id,target:node.id){
                xml.attvalues
              }
            }

          }
        }
      }
    end


    # generate gexf file
    file = opts[:file] || "public/gexfs/#{weibo_id}.gexf"
    FileUtils.mkdir_p "public/gexfs" if !Dir.exist? "public/gexfs"
    open(file,"wb") do |file|
      file.write builder.to_xml.gsub(/&#x[0-9a-eA-E]*;/, ' ')
    end


    # use gephi generate positions
    `java -jar lib/gephi/gephi.jar #{file} #{file}`
    `sed -i 's/&#x/\\\&amp;#x/g' #{file}`
  end
end
