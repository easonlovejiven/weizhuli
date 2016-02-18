# -*- encoding : utf-8 -*-
class Const

  # get a value for dictionaries
  def self.value(array_name, value)

    if [true,false].include?(value)
      value = value ? 1 : 0
    end


    array = self.send(array_name.to_sym)
    hash = {}
    array.each{|item|
      hash[item[1]] = item[0]
    }

    hash[value]
  end



  # for industry roles
  def self.industry_roles
    [
      [_("公司高层"), 10],
      [_("职员"), 20],
    ]
  end


  # for genders
  def self.genders
    [
      [_("男"),1],
      [_("女"),0]
    ]
  end

  # for marriages
  def self.marriages
    [
      [_("未婚"),0],
      [_("已婚"),1],
    ]
  end


  def self.languages
    [
      ["中文", "zh_CN"],
      ["English", "en"],
    ]
  end

  def self.language_names
    [
      [_("中文"), "zh_CN"],
      [_("英文"), "en"],
    ]
  end



	def self.invoice_types
	  [
	    [_("默认"),0],
	    [_("会议"),1],
	    [_("办公"),2],
	  ]
	end







  def self.feedback_status
    [
      [_("未处理"),0],
      [_("处理中"),1],
      [_("问题解决"),2],
      [_("无法解决"),3],
    ]
  end
  
  def self.user_status
    [
      [_("已禁止"),0],
      [_("已激活"),1],
      [_("邮箱验证"),2],
    ]
  end



end

