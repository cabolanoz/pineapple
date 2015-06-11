class CoffeeOriginConnection < ActiveRecord::Base
  self.abstract_class = true

  establish_connection :"coffeeorigin_#{Rails.env}"
end
