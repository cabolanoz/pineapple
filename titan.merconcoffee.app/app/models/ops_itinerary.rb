class OpsItinerary < CiclonProConnection

  self.table_name = "OPS_ITINERARY"
  self.primary_key = "itinerary_num"

  belongs_to :operator, :class_name => 'RefPerson', :foreign_key => 'operator_person_num'
  belongs_to :internal_company, :class_name => 'RefCompany', :foreign_key => 'internal_company_num'
  has_many :movements, :class_name => 'OpsMovement', :foreign_key => "itinerary_num"
  
end
