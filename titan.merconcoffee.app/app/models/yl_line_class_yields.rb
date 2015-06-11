class YlLineClassYields < CoffeeOriginConnection

  self.table_name = "yield.YL_LineClassYields"
  self.primary_key = "LC_id"

  belongs_to :physicalState, :class_name => 'RefProfitUnit', :foreign_key => 'LC_PhysicalState' 
  belongs_to :group, :class_name => 'RefCommodityGroup', :foreign_key => 'LC_GroupNum' 
  belongs_to :element, :class_name => 'YlYieldElements', :foreign_key => 'LC_YE_id' 
    
end
