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
      @faces = geometry.faces.clone
      # Faces get converted to an edge reference
      @faces.each_with_index do |face, index|
        # Add the three edges
        add_edge(v1: face.a, v2: face.b, face: index)
        add_edge(v1: face.b, v2: face.c, face: index)
        add_edge(v1: face.c, v2: face.a, face: index)
      end
    end

    def between(v1, v2)
      index = index_between(v1, v2)
      index ? @edges[index] : nil
    end

    private

    def index_between(v1, v2)
      @edges.find_index { |e| (e.start == v1 && e.finish == v2) || (e.start == v2 && e.finish == v1) }
    end

    def add_edge(v1:, v2:, face:)
      # Is there already an edge?
      index = index_between(v1, v2)
      if index
        edge = @edges[index]
        edge.right = face if edge.right.nil?
      else
        index = @edges.count
        @edges << WingedEdge.new(start: v1, finish: v2, left: face)
      end
      index
    end
  end
end
