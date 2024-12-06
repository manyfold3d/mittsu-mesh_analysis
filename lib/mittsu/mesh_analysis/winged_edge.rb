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
      @start == @finish || @left == @right || [@index, @cw_left, @cw_right, @ccw_left, @ccw_right].uniq.count != 5
    end

    def other_vertex(index)
      @start == index ? @finish : @start
    end

    def reattach_vertex!(from:, to:)
      was = self.clone
      if @start == from
        @start = to
      elsif @finish == from
        @finish = to
      end
      raise ArgumentError.new("was #{was.inspect}, now: #{inspect}") if degenerate?
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
      raise ArgumentError.new(self.inspect) if degenerate?
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
    # Returns nil if not stiched, or the face index that might need
    # an edge reference update if it was
    def stitch!(edge)
      # Make sure the edges share a vertex and face
      face = shared_face(edge)
      return nil unless face && edge.coincident_at(edge)
      # Flip incoming edge if it's not pointing the same way
      edge = edge.flip unless same_direction?(edge)
      raise ArgumentError if edge.degenerate? || degenerate? || !same_direction?(edge)
      # Stitch left side of other edge if our left face is the shared one, or vice versa
      puts face
      if face == @left
        @cw_left = edge.cw_left
        @ccw_left = edge.ccw_left
        @left = edge.left
        raise ArgumentError.new(self.inspect) if degenerate?
        return @left
      else
        @cw_right = edge.cw_right
        @ccw_right = edge.ccw_right
        @right = edge.right
        raise ArgumentError.new(self.inspect) if degenerate?
        return @right
      end
    end
  end
end
