class ImportingWeiboPrivateMessage < ActiveRecord::Base
   
# ImportingWeiboPrivateMessage.importing_excel_private_message("ContentIntPlan.xlsx")

 def self.importing_excel_private_message(filename)
  require 'rubygems'  
  require 'roo'
  
  #ee = Openoffice.new(filename+".ods")      # creates an Openoffice Spreadsheet instance  
  #ee = Excel.new(filename+".xls")           # creates an Excel Spreadsheet instance  
  #ee = Google.new("myspreadsheetkey_at_google") # creates an Google Spreadsheet instance  
  ee = Roo::Excelx.new(filename) # creates an Excel Spreadsheet instance for Excel .xlsx files  
  ee.default_sheet = ee.sheets.first

  2.upto(ee.last_row) do |line|

     uid = 2295615873
     send_at = ee.cell(line,'A')
     content = ee.cell(line,'B')
     name = ee.cell(line,'C')
     target_uids = ReportUtils.names_to_uids(%w{name},true)#10秒落泪的感性和平1993
     target_uid =target_uids[0]
     
     #puts "#{uid}\t#{send_at}\t#{content}\t#{target_uid}\t"
     wpm = WeiboPrivateMessage.new
     
     wpm.uid = uid 
puts "#{wpm.uid}\t"
     wpm.send_at = send_at
puts "#{wpm.send_at}\t"
     wpm.content = content
puts "#{wpm.content}\t"
     wpm.target_uid = target_uid
puts "#{wpm.target_uid}\t"
    wpm.save
     
     
   end 
   
  
  end
end

