class Mittsu::MeshAnalysis::Decimator
  def initialize(geometry)
    @geometry = Mittsu::MeshAnalysis::WingedEdgeGeometry.new
    @geometry.from_geometry(geometry)
  end

  def decimate(target_face_count)
    edge_collapses = edge_collapse_costs.sort_by { |x| x[:cost] }
    loop do
      break if @geometry.faces.count <= target_face_count
      edge = edge_collapses.shift
      @geometry.collapse(edge[:edge_index])
    end
    @geometry
  end

  def edge_collapse_costs
    @geometry.edges.map { |e|
      e ? {
        edge_index: e.index,
        cost: @geometry.edge_length(e.index)
      } : nil
    }.compact
  end

  def collapse(edge)
    @geometry.collapse(edge)
  end
end
