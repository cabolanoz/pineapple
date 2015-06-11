class McgensConnection < ActiveRecord::Base
  self.abstract_class = true

  establish_connection :"mcgens_#{Rails.env}"
end
