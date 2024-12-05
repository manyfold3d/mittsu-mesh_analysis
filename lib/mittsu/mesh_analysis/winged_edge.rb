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
      @index && @start && @finish && @left && @right && @cw_left && @ccw_left && @cw_right && @ccw_right
    end

    def degenerate?
      @start == @finish || @left == @right || [@cw_left, @cw_right, @ccw_left, @ccw_right].uniq.count != 4
    end

    def other_vertex(index)
      @start == index ? @finish : @start
    end

    def reattach_vertex!(from:, to:)
      if @start == from
        @start = to
      elsif @finish == from
        @finish = to
      end
    end

    def reattach_edge!(from:, to:)
      if @cw_left == from
        @cw_left = to
      elsif @ccw_left == from
        @ccw_left = to
      elsif @cw_right == from
        @cw_right = to
      elsif @ccw_right == from
        @ccw_right = to
      end
    end

    def coincident_at(edge)
      return @start if edge.start == @start
      return @finish if edge.start == @finish
      return @start if edge.finish == @start
      return @finish if edge.finish == @finish
    end

    def colinear?(edge)
      return (@start == edge.start && @finish == edge.finish) || (@start == edge.finish && @finish == edge.start)
    end

    # Do the two edges share a face?
    def shared_face(edge)
      return @left if edge.left == @left || edge.right == @left
      return @right if edge.left == @right || edge.right == @right
    end

    def normalized?
      @finish > @start
    end

    # Are two coincident edges pointing the same direction
    # compared to their shared vertex?
    def same_direction?(edge)
      edge.start == @start || edge.finish == @finish
    end

    def flip
      WingedEdge.new(
        index: @index,
        start: @finish,
        finish: @start,
        left: @right,
        right: @left,
        cw_left: @cw_right,
        ccw_left: @ccw_right,
        cw_right: @cw_left,
        ccw_right: @ccw_left
      )
    end

    def normalize
      normalized? ? self : flip
    end

    # Stitches another edge into this one
    # The edges must share a face and a vertex
    # The edge passed as an argument will be invalid
    # if operation succeeds (returns true) and should
    # be discarded
    def stitch(edge)
      true
    end
  end
end
