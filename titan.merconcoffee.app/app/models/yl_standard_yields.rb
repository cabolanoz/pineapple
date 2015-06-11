class YlStandardYields < CoffeeOriginConnection

  self.table_name = "yield.YL_StandardYields"
  self.primary_key = "SY_id"

  belongs_to :location, :class_name => 'RefLocation', :foreign_key => 'SY_CollectionCenter'
  belongs_to :lineclass, :class_name => 'YlLineClassYields', :foreign_key => 'SY_LC_id'
end
