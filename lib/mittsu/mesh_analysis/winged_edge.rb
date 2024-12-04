module Mittsu::MeshAnalysis
  class WingedEdge

    attr_accessor :start, :finish, :left, :right, :cw_left, :ccw_left, :cw_right, :ccw_right, :index

    def initialize(index:, start:, finish:, left: nil, right: nil, cw_left: nil, ccw_left: nil, cw_right: nil, ccw_right: nil)
      # Index
      @index = index
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

    def complete?
      index && start && finish && left && right && cw_left && ccw_left && cw_right && ccw_right
    end

    def degenerate?
      start == finish
    end

    def other_vertex(index)
      start == index ? finish : start
    end

  end
end
