class OpsBuildDrawTag < CiclonProConnection

  self.table_name = "OPS_BUILD_DRAW_TAG"
  self.primary_key = "build_draw_num"

  has_many :build_draw, :class_name => 'OpsBuildDraw', :foreign_key => "build_draw_num"
  
end
