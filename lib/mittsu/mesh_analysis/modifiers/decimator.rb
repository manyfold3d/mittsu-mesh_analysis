class Mittsu::MeshAnalysis::Decimator
	# very roughly based on SimplifyModifier from Three.js, but pretty much rewritten from scratch

	def initialize(geometry)
		@geometry = Mittsu::MeshAnalysis::WingedEdgeGeometry.new
		@geometry.from_geometry(geometry)
	end

	def decimate(target_face_count)
		edge_collapses = edge_collapse_costs.sort_by{|x| x[:cost]}
		loop do
			break if @geometry.faces.count <= target_face_count
			@geometry.collapse(edge_collapses.pop[:edge_index])
		end
		@geometry
	end

	def edge_collapse_costs
		@geometry.edges.map { |e| {edge_index: e.index, cost: rand()} }
	end

	def collapse(edge)
		@geometry.collapse(edge)
	end
end
