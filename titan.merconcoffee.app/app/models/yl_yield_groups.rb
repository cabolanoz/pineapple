class YlYieldGroups < CoffeeOriginConnection

  self.table_name = "yield.YL_YieldGroups"
  self.primary_key = "YG_Id"

  belongs_to :physicalState, :class_name => 'RefProfitUnit', :foreign_key => 'YG_PhysicalState' # ya tenes mapeado el RefProfitUnit?
  belongs_to :calcType, :class_name => 'YlRefCalcTypes', :foreign_key => 'YG_CalcType'
end
