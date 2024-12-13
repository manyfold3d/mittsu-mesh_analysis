require "mittsu/mesh_analysis/vertex_split"

module Mittsu::MeshAnalysis
  class ProgressiveMesh < Mittsu::Mesh
    attr_reader :vertex_splits

    def initialize(geometry = Geometry.new, material = Mittsu::MeshBasicMaterial.new(color: (rand * 0xffffff).to_i))
      super
      @vertex_splits = []
    end

    def progressify(ratio: 0.95)
      decimator = Mittsu::MeshAnalysis::Decimator.new(@geometry)
      @geometry, @vertex_splits = decimator.decimate(
        @geometry.faces.count * (1 - ratio),
        vertex_splits: true
      )
    end
  end
end
