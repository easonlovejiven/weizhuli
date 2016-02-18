class ImportingWeiboSentComment < ActiveRecord::Base
   
  
# excel import mysql weibo_sent_comment
# ImportingWeiboSentComment.importing_excel_sent_comment("Content & Interaction Plan_20130821-20130827.xlsx")

 def self.importing_excel_sent_comment(filename)
  require 'rubygems'  
  require 'roo'
  
  #ee = Openoffice.new(filename+".ods")      # creates an Openoffice Spreadsheet instance  
  #ee = Excel.new(filename+".xls")           # creates an Excel Spreadsheet instance  
  #ee = Google.new("myspreadsheetkey_at_google") # creates an Google Spreadsheet instance  
  ee = Roo::Excelx.new(filename) # creates an Excel Spreadsheet instance for Excel .xlsx files  
  ee.default_sheet = ee.sheets.first

  2.upto(ee.last_row) do |line|

     uid = 2295615873
   debugger
     comment_at = ee.cell(line,'A').to_s  
     content = ee.cell(line,'B')
     name = ee.cell(line,'C')
     target_uids = ReportUtils.names_to_uids([name],true)#10秒落泪的感性和平1993
     target_uid =target_uids[0]
     
     #puts "#{uid}\t#{comment_at}\t#{content}\t#{target_uid}\t"
     wsc = WeiboSentComment.new
     
     wsc.uid = uid 
puts "#{wsc.uid}\t"
     wsc.comment_at = comment_at
puts "#{wsc.comment_at}\t"
     wsc.content = content
puts "#{wsc.content}\t"
     wsc.target_uid = target_uid
puts "#{wsc.target_uid}\t"
    wsc.save
     
     
   end 
   
  
  end
end



