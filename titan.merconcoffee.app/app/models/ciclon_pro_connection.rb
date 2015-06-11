class CiclonProConnection < ActiveRecord::Base
  self.abstract_class = true

  establish_connection :"ctrm_ciclon_pro_#{Rails.env}"
end
