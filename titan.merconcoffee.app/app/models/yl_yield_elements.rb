class YlYieldElements < CoffeeOriginConnection

  self.table_name = "yield.YL_YieldElements"
  self.primary_key = "YE_Id"

  belongs_to :elementType, :class_name => 'YlRefElementTypes', :foreign_key => 'YE_IdElementType' # ya tenes mapeado el RefProfitUnit?
  belongs_to :yieldGroup, :class_name => 'YlYieldGroups', :foreign_key => 'YE_IdYieldGroup'
end
