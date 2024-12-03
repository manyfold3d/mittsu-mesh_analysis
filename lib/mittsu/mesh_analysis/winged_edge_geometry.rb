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
      index = find_edge(from: v1, to: v2) || find_edge(from: v2, to: v1)
      index ? @edges[index] : nil
    end

    private

    def find_edge(from:, to:)
      @edges.find_index { |e| (e.start == from && e.finish == to) }
    end

    def add_edge(v1:, v2:, face:)
      # Is there already an edge going the other way?
      index = find_edge(from: v2, to: v1)
      if index
        edge = @edges[index]
        raise "Mesh conflict" unless edge.right.nil?
        edge.right = face
      else
        index = @edges.count
        @edges << WingedEdge.new(start: v1, finish: v2, left: face)
      end
      index
    end
  end
end
