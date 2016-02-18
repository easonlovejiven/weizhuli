# -*- encoding : utf-8 -*-
module Client::GuidesHelper

  def guide_step_class(step)
    idx = case action_name
    when "full_profile" then 0
    when "save_full_profile" then 0
    when "save_industries" then 1
    when "industries" then 1
    when "people" then 2
    when "save_people" then 2
    when "complete" then 3
    end
    idx > step ? ("finish") : (idx == step ? "focus" : "")
  end


end
