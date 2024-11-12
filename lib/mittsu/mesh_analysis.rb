require "mittsu"
require "mittsu/mesh_analysis/version"
require "mittsu/mesh_analysis/analysis"

module Mittsu
  class Object3D
    include Mittsu::MeshAnalysis::Analysis
  end

  class Face3
    def flip!
      tmp = @a
      @a = @c
      @c = tmp
    end
  end
end
