# -*- encoding : utf-8 -*-
module Client::UserHelper
  def user_progress_bar(user,locale)
#    if "zh_CN" == locale.to_s
#    end 
         info = 0
         if !user.business_card.display_name.blank?
          info += 10 
         end
        if !user.business_card.gender.blank?
          info += 10 
         end
         if !user.business_card.mobile.blank?
          info += 10 
         end
         if !user.business_card.email.blank?
          info += 10 
         end
         if !user.business_card.telephone.blank?
          info += 10 
         end
         if !user.business_card.title.blank?
          info += 10 
         end
         if !user.business_card.company.blank?
          info += 10 
         end
         if !user.business_card.address.blank?
          info += 10 
         end
         if !user.business_card.country.blank? && !user.business_card.province.blank?
          info += 10 
         end
         if !user.business_card.city.blank?
          info += 10 
         end
         info = info.to_s+"%"
  end
end
