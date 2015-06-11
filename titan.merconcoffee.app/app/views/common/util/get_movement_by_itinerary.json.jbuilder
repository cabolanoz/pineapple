json.array! @movements do |movement|
  mot = movement.mot
  mot_type = movement.mot_type
  depart_location = movement.depart_location

  json.merge! movement.attributes
  json.mot mot
  json.mot_type mot_type
  json.depart_location depart_location
end
