module Mittsu::MeshAnalysis
  class WingedEdge
    attr_accessor :start, :finish, :left, :right, :start_left, :finish_left, :start_right, :finish_right, :index

    def initialize(index:, start:, finish:, left: nil, right: nil, start_left: nil, finish_left: nil, start_right: nil, finish_right: nil)
      # Index
      @index = index
      # Vertices
      @start = start
      @finish = finish
      # Faces
      @left = left
      @right = right
      # Edges
      @start_left = start_left
      @finish_left = finish_left
      @start_right = start_right
      @finish_right = finish_right
    end

    def complete?
      @index && @start && @finish && @left && @right && @start_left && @finish_left && @start_right && @finish_right
    end

    def degenerate?
      @start == @finish || @left == @right || [@index, @start_left, @start_right, @finish_left, @finish_right].uniq.count != 5
    end

    def other_vertex(index)
      (@start == index) ? @finish : @start
    end

    def reattach_vertex(from:, to:)
      out = nil
      if @start == from
        out = clone
        out.start = to
      elsif @finish == from
        out = clone
        out.finish = to
      end
      (out.nil? || out.degenerate?) ? nil : out
    end

    def reattach_edge!(from:, to:)
      if @start_left == from
        @start_left = to
      elsif @finish_left == from
        @finish_left = to
      elsif @start_right == from
        @start_right = to
      elsif @finish_right == from
        @finish_right = to
      end
    end

    def coincident_at(edge)
      return @start if edge.start == @start
      return @finish if edge.start == @finish
      return @start if edge.finish == @start
      @finish if edge.finish == @finish
    end

    def colinear?(edge)
      (@start == edge.start && @finish == edge.finish) || (@start == edge.finish && @finish == edge.start)
    end

    # Do the two edges share a face?
    def shared_face(edge)
      return @left if edge.left == @left || edge.right == @left
      @right if edge.left == @right || edge.right == @right
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
        start_left: @start_right,
        finish_left: @finish_right,
        start_right: @start_left,
        finish_right: @finish_left
      )
    end

    def normalize
      normalized? ? self : flip
    end

    # Stitches another edge into this one
    # The edges must share a face and a vertex
    # The edge passed as an argument will be invalid
    # Returns the new edge, or nil if stitch failed
    def stitch(edge)
      # Make sure the edges share a vertex and face
      face = shared_face(edge)
      return nil unless face && edge.coincident_at(edge)
      # Flip incoming edge if it's not pointing the same way
      edge = edge.flip unless same_direction?(edge)
      # Stitch left side of other edge if our left face is the shared one, or vice versa
      stitched_edge = clone
      if face == @left
        stitched_edge.start_left = edge.start_left
        stitched_edge.finish_left = edge.finish_left
        stitched_edge.left = edge.left
      else
        stitched_edge.start_right = edge.start_right
        stitched_edge.finish_right = edge.finish_right
        stitched_edge.right = edge.right
      end
      stitched_edge
    end
  end
end
