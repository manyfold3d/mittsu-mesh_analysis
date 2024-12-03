require "mittsu/mesh_analysis/winged_edge"

module Mittsu::MeshAnalysis
  class WingedEdgeGeometry < Mittsu::Geometry

    attr_reader :vertices, :faces, :edges

    def initialize
      @vertices = []
      @faces = []
      @edges = []
    end

    def from_geometry(geometry)
      # Vertices are the same
      @vertices = geometry.vertices.clone
      # Faces get converted to an edge reference
      geometry.faces.each_with_index do |face, index|
        # Add the three edges
        e1_new, e1 = add_edge(v1: face.a, v2: face.b, face: index)
        e2_new, e2 = add_edge(v1: face.b, v2: face.c, face: index)
        e3_new, e3 = add_edge(v1: face.c, v2: face.a, face: index)
        # Set wing data
        if e1_new
          @edges[e1].cw_left = e3
          @edges[e1].ccw_left = e2
        else
          @edges[e1].cw_right = e3
          @edges[e1].ccw_right = e2
        end
        if e2_new
          @edges[e2].cw_left = e1
          @edges[e2].ccw_left = e3
        else
          @edges[e2].cw_right = e1
          @edges[e2].ccw_right = e3
        end
        if e3_new
          @edges[e3].cw_left = e2
          @edges[e3].ccw_left = e1
        else
          @edges[e3].cw_right = e2
          @edges[e3].ccw_right = e1
        end
        # Store face->edge reference
        @faces[index] = e1
      end
    end

    def between(v1, v2)
      index = find_edge(from: v1, to: v2) || find_edge(from: v2, to: v1)
      edge(index)
    end

    def edge(index)
      @edges[index] if index
    end

    private

    def find_edge(from:, to:)
      @edges.find_index { |e| (e.start == from && e.finish == to) }
    end

    def add_edge(v1:, v2:, face:)
      # Is there already an edge going the other way?
      index = find_edge(from: v2, to: v1)
      if index
        edge = edge(index)
        raise "Mesh conflict" unless edge.right.nil?
        edge.right = face
        return false, index
      else
        index = @edges.count
        @edges << WingedEdge.new(start: v1, finish: v2, left: face)
        return true, index
      end
    end
  end
end
