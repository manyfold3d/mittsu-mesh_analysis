require "mittsu/mesh_analysis/winged_edge"

class Mittsu::MeshAnalysis::WingedEdgeGeometry < Mittsu::Geometry

  attr_reader :vertices, :faces

  def initialize
    @vertices = []
    @faces = []
    @edges = []
  end

  def from_geometry(geometry)
    # Vertices are the same
    @vertices = geometry.vertices.clone
    # Faces get converted to an edge reference
    @faces = geometry.faces.clone # TODO
  end

end
