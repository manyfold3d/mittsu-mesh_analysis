module Mittsu::MeshAnalysis
  class VertexSplit
    attr_accessor :vertex, :left, :right, :displacement

    def initialize(vertex: nil, left: nil, right: nil, displacement: nil)
      @vertex = vertex
      @left = left
      @right = right
      @displacement = displacement
    end
  end
end
