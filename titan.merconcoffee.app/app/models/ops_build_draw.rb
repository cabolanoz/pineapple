class OpsBuildDraw < CiclonProConnection

  self.table_name = "OPS_BUILD_DRAW"
  self.primary_key = "build_draw_num"

  belongs_to :storage, :class_name => 'RefStorage', :foreign_key => 'equipment_num'
  belongs_to :cargo, :class_name => 'OpsCargo', :foreign_key => 'cargo_num'
  belongs_to :build_draw_type, -> { where ind_name: 'build_draw_type_ind' }, :class_name => 'GenIndicatorValue', :foreign_key => 'build_draw_type_ind'
  belongs_to :location, :class_name => 'RefLocation', :foreign_key => 'location_num'
  belongs_to :trade, :class_name => 'TrdHeader', :foreign_key => 'trade_num'
  has_many :tags, -> { where "alloc_status_ind <> 2" }, :class_name => 'OpsBuildDrawTag', :foreign_key => "build_draw_num"
  
end
