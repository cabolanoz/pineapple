json.associated_draw do
  json.array! @associated_draw do |asd|
    build_draw_type = asd.build_draw_type
    location = asd.location

    json.merge! asd.attributes
    json.build_draw_type build_draw_type
    json.location location
  end
end

json.available_draw do
  json.array! @available_draw do |avd|
    build_draw_type = avd.build_draw_type
    location = avd.location

    json.merge! avd.attributes
    json.build_draw_type build_draw_type
    json.location location
  end
end
