module Mittsu::MeshAnalysis
  class WingedEdge

    attr_accessor :start, :finish, :left, :right, :prevLeft, :nextLeft, :prevRight, :nextRight

    def initialize(start:, finish:, left: nil, right: nil, prevLeft: nil, nextLeft: nil, prevRight: nil, nextRight: nil)
      # Vertices
      @start = start
      @finish = finish
      # Faces
      @left = left
      @right = right
      # Edges
      @prevLeft = prevLeft
      @nextLeft = nextLeft
      @prevRight = prevRight
      @nextRight = nextRight
    end

  end
end
