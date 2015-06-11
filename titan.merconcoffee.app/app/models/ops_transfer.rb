class OpsTransfer < CiclonProConnection

  self.table_name = "OPS_TRANSFER"
  self.primary_key = "transfer_num"

  belongs_to :from_type, -> { where ind_name: 'from_type_ind' }, :class_name => 'GenIndicatorValue', :foreign_key => 'from_type_ind'
  belongs_to :to_type, -> { where ind_name: 'to_type_ind' }, :class_name => 'GenIndicatorValue', :foreign_key => 'to_type_ind'
  belongs_to :location, :class_name => 'RefLocation', :foreign_key => 'location_num'
  belongs_to :from_itinerary, :class_name => 'OpsItinerary', :foreign_key => 'from_itinerary_num'
  belongs_to :from_storage, :class_name => 'RefStorage', :foreign_key => 'from_equipment_num'
  belongs_to :from_cargo, :class_name => 'OpsCargo', :foreign_key => 'from_cargo_num'
  belongs_to :to_itinerary, :class_name => 'OpsItinerary', :foreign_key => 'to_itinerary_num'
  belongs_to :to_storage, :class_name => 'RefStorage', :foreign_key => 'to_equipment_num'
  belongs_to :to_cargo, :class_name => 'OpsCargo', :foreign_key => 'to_cargo_num'
  belongs_to :build, :class_name => 'OpsBuildDraw', :foreign_key => 'build_num'
  belongs_to :draw, :class_name => 'OpsBuildDraw', :foreign_key => 'draw_num'
  belongs_to :operator, :class_name => 'RefPerson', :foreign_key => 'operator_person_num'
  belongs_to :transfer_at, -> { where ind_name: 'transfer_at_ind' }, :class_name => 'GenIndicatorValue', :foreign_key => 'transfer_at_ind'
  belongs_to :delivery_active_status, -> { where ind_name: 'delivery_active_status_ind' }, :class_name => 'GenIndicatorValue', :foreign_key => 'delivery_active_status_ind'
  has_many :transfer_daily_detail, :class_name => 'OpsTransferDailyDetail', :foreign_key => 'transfer_num'
  has_many :from_udf, -> { where to_from_ind: 1 }, :class_name => 'OpsTransferUdf', :foreign_key => 'transfer_num'
  has_many :to_udf, -> { where to_from_ind: 0 }, :class_name => 'OpsTransferUdf', :foreign_key => 'transfer_num'

end
