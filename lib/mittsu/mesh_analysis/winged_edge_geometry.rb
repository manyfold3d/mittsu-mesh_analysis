require "mittsu/mesh_analysis/winged_edge"

module Mittsu::MeshAnalysis
  class WingedEdgeGeometry < Mittsu::Geometry
    attr_reader :vertices, :edges

    def initialize
      super
      @edges = []
    end

    def from_geometry(geometry, merge: true, normalize: true)
      # Merge vertices unless told not to
      geometry.merge_vertices if merge
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
          @edges[e1].start_left = e3
          @edges[e1].finish_left = e2
        else
          @edges[e1].start_right = e3
          @edges[e1].finish_right = e2
        end
        if e2_new
          @edges[e2].start_left = e1
          @edges[e2].finish_left = e3
        else
          @edges[e2].start_right = e1
          @edges[e2].finish_right = e3
        end
        if e3_new
          @edges[e3].start_left = e2
          @edges[e3].finish_left = e1
        else
          @edges[e3].start_right = e2
          @edges[e3].finish_right = e1
        end
      end
      normalize! if normalize
      # Calculate renderable mesh after import
      flatten!
    end

    def collapse_cost(index)
      edge_length(index) || 100
    end

    def edge_length(index)
      e0 = edge(index)
      return nil if e0.nil?
      @vertices[e0.start].distance_to(@vertices[e0.finish])
    end

    def flatten!
      @faces = []
      @edges.each do |e0|
        next if e0.nil?
        if e0.left && @faces[e0.left].nil?
          @faces[e0.left] = Mittsu::Face3.new(e0.start, e0.finish, edge(e0.finish_left)&.other_vertex(e0.finish)) if e0.start && e0.finish && edge(e0.finish_left)&.other_vertex(e0.finish)
        end
        if e0.right && @faces[e0.right].nil?
          @faces[e0.right] = Mittsu::Face3.new(e0.finish, e0.start, edge(e0.finish_right)&.other_vertex(e0.start)) if e0.finish && e0.start && edge(e0.finish_right)&.other_vertex(e0.start)
        end
      end
      @faces.compact!
      compute_face_normals
    end

    def normalize!
      @edges = @edges.map(&:normalize)
    end

    def between(v1, v2)
      edge(indexes_between(v1, v2).first)
    end

    def indexes_between(v1, v2)
      find_edge_indexes(from: v1, to: v2) + find_edge_indexes(from: v2, to: v1)
    end

    def edge(index)
      @edges[index] if index
    end

    def manifold?
      @edges.all? do |e|
        return true if e.nil?
        e.complete? &&
          !e.degenerate? &&
          indexes_between(e.start, e.finish).count <= 1 &&
          !@vertices[e.start].nil? &&
          !@vertices[e.finish].nil? &&
          !@edges[e.start_left].nil? &&
          !@edges[e.finish_left].nil? &&
          !@edges[e.start_right].nil? &&
          !@edges[e.finish_right].nil?
      end
    end

    def split(vertex:, left:, right:, displacement:, flatten: true)
      # Find the vertex and edges that will be split
      # Create new vertex
      # Move existing vertex
      # Create new edge
      # Split left edge
      # Split right edge
      # Prepare for rendering
      flatten! if flatten
      raise NotImplementedError
    end

    # Collapses an edge by removing the finish vertex, left and right faces,
    # and merging everything onto the start vertex instead.
    # If the result would be degenerate in some way, the mesh is unchanged
    def collapse(index, flatten: true)
      # Find edge, reorder vertices and reload
      e0 = edge(index)
      if e0
        move_vertex_to_end(e0.finish)
        e0 = edge(index)
      else
        # Invalid edge index
        return nil
      end

      # Create vertex split record
      split = VertexSplit.new(vertex: e0.start)

      # Calculate displacement vector and move old vertex
      split.displacement = Mittsu::Vector3.new
      split.displacement.sub_vectors(@vertices[e0.finish], @vertices[e0.start])
      split.displacement.divide_scalar(2)
      @vertices[e0.start].add(split.displacement)

      # Collapse left face
      start_left = @edges[e0.start_left]
      finish_left = @edges[e0.finish_left]
      if start_left && finish_left
        split.left = start_left.other_vertex(e0.start)
        start_left = start_left.stitch(finish_left)
        @edges[start_left.index] = start_left
      end

      # Collapse right face
      start_right = @edges[e0.start_right]
      finish_right = @edges[e0.finish_right]
      if start_right && finish_right
        split.right = finish_right.other_vertex(e0.start)
        finish_right = finish_right.stitch(start_right)
        @edges[finish_right.index] = finish_right
      end

      # Remove one vertex, and three edges
      @vertices[e0.finish] = Mittsu::Vector3.new(0, 0, 0) # This can become nil later when we compact and reindex things
      @edges[e0.finish_left] = nil
      @edges[e0.start_right] = nil
      @edges[e0.index] = nil

      # Reattach edges to remove old indexes
      # This could be much more efficient by walking round the wings
      @edges.each do |e|
        next if e.nil?
        e.reattach_edge!(from: finish_left.index, to: start_left.index) if finish_left && start_left
        e.reattach_edge!(from: start_right.index, to: finish_right.index) if finish_right && start_right
        r = e.reattach_vertex(from: e0.finish, to: e0.start)
        @edges[e.index] = r if r
      end

      # Prepare for rendering
      flatten! if flatten
      # Return split parameters required to invert operation
      split
    end

    def move_vertex_to_end(index)
      return unless @vertices[index]
      # Add move vertex to end of array
      @vertices.push @vertices.slice!(index)
      new_index = @vertices.count - 1
      # Update all vertex references
      @edges.each do |edge|
        next if edge.nil?
        if edge.start == index
          edge.start = new_index
        elsif edge.start > index
          edge.start = edge.start - 1
        end
        if edge.finish == index
          edge.finish = new_index
        elsif edge.finish > index
          edge.finish = edge.finish - 1
        end
      end
    end

    private

    def find_edge_indexes(from:, to:)
      @edges.select { |e| !e.nil? && (e.start == from && e.finish == to) }.map(&:index)
    end

    def add_edge(v1:, v2:, face:)
      # Is there already an edge going the other way?
      index = find_edge_indexes(from: v2, to: v1).first
      if index
        edge = edge(index)
        raise "Mesh conflict" unless edge.right.nil?
        edge.right = face
        [false, index]
      else
        index = @edges.count
        @edges << WingedEdge.new(index: index, start: v1, finish: v2, left: face)
        [true, index]
      end
    end
  end
end
