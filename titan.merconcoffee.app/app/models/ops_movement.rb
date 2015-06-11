class OpsMovement < CiclonProConnection

  self.table_name = "OPS_MOVEMENT"
  self.primary_key = "movement_num"

  belongs_to :mot, :class_name => 'RefMotId', :foreign_key => 'mot_num'
  belongs_to :mot_type, -> { where ind_name: 'mot_type_ind' }, :class_name => 'GenIndicatorValue', :foreign_key => 'mot_type_ind'
  belongs_to :depart_location, :class_name => 'RefLocation', :foreign_key => 'depart_location_num'
  belongs_to :arrive_location, :class_name => 'RefLocation', :foreign_key => 'arrive_location_num'
  belongs_to :movement_status, -> { where ind_name: 'movement_status_ind' }, :class_name => 'GenIndicatorValue', :foreign_key => 'movement_status_ind'
  has_many :cargos, :class_name => 'OpsCargo', :foreign_key => 'equipment_num', :primary_key => 'equipment_num'

end
