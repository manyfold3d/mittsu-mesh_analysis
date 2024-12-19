class Mittsu::MeshAnalysis::Decimator
  def initialize(geometry)
    @geometry = Mittsu::MeshAnalysis::WingedEdgeGeometry.new
    @geometry.from_geometry(geometry)
  end

  def decimate(target_face_count, vertex_splits: false)
    @geometry.flatten!
    edge_collapses = edge_collapse_costs.sort_by { |x| x[:cost] }
    splits = []
    loop do
      break if @geometry.faces.count <= target_face_count || edge_collapses.empty?
      edge = edge_collapses.shift
      splits.unshift @geometry.collapse(edge[:edge_index], flatten: false)
    end
    # Return vertex splits if requested
    @geometry.flatten!
    if vertex_splits
      [@geometry, splits.compact]
    else
      @geometry
    end
  end

  def edge_collapse_costs
    @geometry.edges.filter_map { |e|
      e ? {
        edge_index: e.index,
        cost: @geometry.collapse_cost(e.index)
      } : nil
    }
  end

  def collapse(edge)
    @geometry.collapse(edge)
  end
end
