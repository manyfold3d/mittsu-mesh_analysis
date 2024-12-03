module Mittsu::MeshAnalysis
  class WingedEdge

    attr_accessor :start, :finish, :left, :right, :cw_left, :ccw_left, :cw_right, :ccw_right

    def initialize(start:, finish:, left: nil, right: nil, cw_left: nil, ccw_left: nil, cw_right: nil, ccw_right: nil)
      # Vertices
      @start = start
      @finish = finish
      # Faces
      @left = left
      @right = right
      # Edges
      @cw_left = cw_left
      @ccw_left = ccw_left
      @cw_right = cw_right
      @ccw_right = ccw_right
    end

  end
end
