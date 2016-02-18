#情感分析 初期版 。。  

s = Roo::Excelx.new("data/sentiment/情感分析用语.xlsx")
#放情感次 0 1
array1 =[]
  [0,1].each do |num|
    sheetname = s.sheets[num]
      ['A','B','C','D','E','F'].each do |line|
      num1 = 3
      chars = line
      array = []
      while true
        break if s.cell(num1,chars,sheetname).nil?
        array << s.cell(num1,chars,sheetname)
        num1 +=1
      end
      array1 << {:title=>s.cell(2,chars,sheetname),:array=>array}
    end
  end
#array1 = [
#  {:title=>"2",:array=>[2,2,3]},
#  {:title=>"3",:array=>['f',2,3]},
#  {:title=>"3",:array=>['d',2,3]},
#  {:title=>"4",:array=>[1,2,3]},
#  {:title=>"5",:array=>[1,2,3]},
#]
#array2 = [{:title=>"2",:array=>[2,2,3]}]
array2 =[]
[2,3,4,5,6,7,8,9,10,11].each do |num|
  
  sheetname = s.sheets[num]
      ['A'].each do |line|
      num1 = 2
      chars = line
      array = []
      while true
        break if s.cell(num1,chars,sheetname).nil?
        array << s.cell(num1,chars,sheetname)
        num1 +=1
      end
      array2 << {:title=>s.cell(1,chars,sheetname).to_s,:array=>array}#
    end
end
  
def check_array(text,array1)
  array1.each do |col|
    next if col[:array].nil?
    col[:array].each do |line|
      
      isarr = text.to_s.include?(line.to_s)
      if isarr
        return [col[:title],line]
        puts col[:title]
        puts line
        break
      end
    end
  end  
  nil
end




#//放互动说的内容
#contents = [
#  [1234,1234,'zhanghua','fdslfjldskjflsdjfl'],
#  [1234,1234,'zhanghua','fdslfjldskjflsdjfl'],
#  [1234,1234,'zhanghua','fdslfjldskjflsdjfl']
#]
#contents = []
#path = File.join(Rails.root, "db/name")
#File.open(path,"r").each do |name|
 #contents << [name.strip]
#end
# 微博互动内容列表ASUS华硕 .xlsx  微博互动内容列表华硕平板电脑.xlsx
#微博互动内容列表华硕智能手机.xlsx 微博互动内容列表英特尔芯品汇.xlsx

s1 = Roo::Excelx.new("data/sentiment/互动内容列表-京东.xlsx")
num2 = 2
contents = []
sheetname = s1.sheets[0]
while true
  break if s1.cell(num2,'A',sheetname).nil?
  contents << [s1.cell(num2,'A',sheetname).to_i,s1.cell(num2,'B',sheetname),s1.cell(num2,'C',sheetname),s1.cell(num2,'D',sheetname),s1.cell(num2,'E',sheetname)]
  num2 +=1
end

  #处理情感匹配并且返回一个hash
def match_contents(contents,array1,array2)
  matchs = {}
  contents.each{|content|
    text = content[1]
    level = check_array(text,array1)
    eva = check_array(text,array2)
    # level = ['1',1]  eva=['a','bbb']
    # level  = nil eva = nil
    level = [''] if level.nil?
    eva = [''] if eva.nil?
    # l = "1", e =  "a"
     matchs[level[0]+eva[0]] ||= []
     matchs[level[0]+eva[0]]  << [content[0],content[1],content[2],content[3],content[4],level.last.to_s+'|'+eva.last.to_s]
  }
  return matchs
  
end

 def sheet_set(sheet,row,col,data)
    if data.is_a? Array
      data.each{|d|
        sheet[row,col] = d
        col += 1
      }
    else
      sheet[row,col] = data
    end
  end
 
 matchs = match_contents(contents,array1,array2)
def create_worksheet(filename,matchs)
  book = Spreadsheet::Workbook.new
  sheet = book.create_worksheet :name=>"各页数据统计"
  sheet_set(sheet,0,0,matchs.keys)
  count = []
  matchs.keys.each do |match|
     count << matchs[match].size
  end
  sheet_set(sheet,1,0,count)
  matchs.keys.each do |match|
    sheet = book.create_worksheet :name=>match.strip
    title = %w{uid  	内容	   互动时间	  互动微博连接  	动作 包含情感词}
    sheet_set(sheet,0,0,title)
    row = 1
    matchs[match].each do |ma|
      sheet_set(sheet,row,0,ma)
  end
  book.write filename
end
create_worksheet("京东情感分析.xlsx",matchs)

