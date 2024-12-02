require "mittsu"
require "mittsu/mesh_analysis/version"
require "mittsu/mesh_analysis/face3"
require "mittsu/mesh_analysis/analysis"
require "mittsu/mesh_analysis/modifiers/decimator"

module Mittsu
  class Object3D
    include MeshAnalysis::Analysis
  end

  class Face3
    include MeshAnalysis::Face3
  end
end
