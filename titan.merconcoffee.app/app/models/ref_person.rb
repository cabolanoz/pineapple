class RefPerson < CiclonProConnection

  self.table_name = "REF_PERSON"
  self.primary_key = "person_num"

  def name
    "#{self.first_name} #{self.last_name}"
  end
  
end
