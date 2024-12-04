class Mittsu::MeshAnalysis::Decimator
	# very roughly based on SimplifyModifier from Three.js, but pretty much rewritten from scratch

	def initialize(geometry)
		@geometry = geometry.clone
	end

	def decimate(vertex_count_to_remove)
		edges = calculate_edge_data.sort_by(&:collapse_cost).first(vertex_count_to_remove)
		edges.each { |e| collapse e }
		@geometry
	end

	def calculate_edge_data
		[]
	end

	def collapse(edge)
	end
end
