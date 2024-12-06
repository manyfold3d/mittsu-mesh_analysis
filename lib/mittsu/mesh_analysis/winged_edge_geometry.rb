require "mittsu/mesh_analysis/winged_edge"

module Mittsu::MeshAnalysis
  class WingedEdgeGeometry < Mittsu::Geometry

    attr_reader :vertices, :edges

    def initialize
      super
      @face_indices = []
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
        @face_indices[index] = {face: index, edge: e1}
      end
      normalize! if normalize
      # Calculate renderable mesh after import
      flatten!
    end

    def flatten!
      @faces = @face_indices.map do |face|
        next if face.nil?
        e0 = edge(face[:edge])
        next if e0.nil?
        puts "error accessing edge #{face[:edge]} for face #{face[:face]}" if e0.nil?
        if e0.left == face[:face]
          Mittsu::Face3.new(e0.start, e0.finish, edge(e0.ccw_left)&.other_vertex(e0.finish)) if e0.start && e0.finish && edge(e0.ccw_left)&.other_vertex(e0.finish)
        elsif e0.right == face[:face]
          Mittsu::Face3.new(e0.finish, e0.start, edge(e0.ccw_right)&.other_vertex(e0.start)) if e0.finish && e0.start && edge(e0.ccw_right)&.other_vertex(e0.start)
        end
      end
      @faces.compact!
      compute_face_normals
    end

    def normalize!
      @edges = @edges.map(&:normalize)
    end

    def between(v1, v2)
      edge(indexes_between(v1,v2).first)
    end

    def indexes_between(v1, v2)
      puts "between #{v1} and #{v2}"
      find_edge_indexes(from: v1, to: v2) + find_edge_indexes(from: v2, to: v1)
    end

    def edge(index)
      @edges[index] if index
    end

    def manifold?
      @edges.all? do |e|
        return true if e.nil?
        raise "edge #{e.index} is incomplete" unless e.complete?
        raise "edge #{e.index} is degenerate" if e.degenerate?
        raise "edge #{e.index} is duplicated" if indexes_between(e.start, e.finish).count > 1
        raise "edge #{e.index} references missing start vertex #{e.start}" if @vertices[e.start].nil?
        raise "edge #{e.index} references missing finish vertex #{e.finish}" if @vertices[e.finish].nil?
        raise "edge #{e.index} references missing left face #{e.left}" if @face_indices[e.left].nil?
        raise "edge #{e.index} references missing right face #{e.right}" if @face_indices[e.right].nil?
        raise "edge #{e.index} references missing cw left edge #{e.cw_left}" if @edges[e.cw_left].nil?
        raise "edge #{e.index} references missing ccw left edge #{e.ccw_left}" if @edges[e.ccw_left].nil?
        raise "edge #{e.index} references missing cw right edge #{e.cw_right}" if @edges[e.cw_right].nil?
        raise "edge #{e.index} references missing ccw right edge #{e.ccw_right}" if @edges[e.ccw_right].nil?
        ok = e.complete? &&
          !e.degenerate? &&
          indexes_between(e.start, e.finish).count <= 1 &&
          !@vertices[e.start].nil? &&
          !@vertices[e.finish].nil? &&
          !@face_indices[e.left].nil? &&
          !@face_indices[e.right].nil? &&
          !@edges[e.cw_left].nil? &&
          !@edges[e.ccw_left].nil? &&
          !@edges[e.cw_right].nil? &&
          !@edges[e.ccw_right].nil?
        puts " -- #{e.inspect}" unless ok
        ok
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
      puts "collapsing edge #{index}"
      # find the edge
      e0 = edge(index)
      puts e0.inspect
      return if e0.nil?

      # Move vertices to new position
      new_position = Mittsu::Vector3.new(
        (@vertices[e0.start].x + @vertices[e0.finish].x) / 2,
        (@vertices[e0.start].y + @vertices[e0.finish].y) / 2,
        (@vertices[e0.start].z + @vertices[e0.finish].z) / 2
      )
      # TODO: Calculate displacement vector
      # displacement =
      @vertices[e0.start] = new_position

      # Collapse left face
      cw_left = cwl = @edges[e0.cw_left]
      ccw_left = @edges[e0.ccw_left]
      if cw_left && ccw_left
        face = cw_left.stitch!(ccw_left)
        raise ArgumentError.new("tried to stitch #{ccw_left.inspect} into #{cwl.inspect} and got #{cw_left.inspect}") if cw_left.degenerate?
        @edges[cw_left.index] = cw_left
        @face_indices[face] = {face: face, edge: cw_left.index} if face
      end

      # Collapse right face
      cw_right = @edges[e0.cw_right]
      ccw_right = ccwr = @edges[e0.ccw_right]
      if cw_right && ccw_right
        face = ccw_right.stitch!(cw_right)
        raise ArgumentError.new("tried to stitch #{cw_right.inspect} into #{ccwr.inspect} and got #{ccw_right.inspect}") if ccw_right.degenerate?
        @edges[ccw_right.index] = ccw_right
        @face_indices[face] = {face: face, edge: ccw_right.index} if face
      end

      # Remove two faces, one vertex, and three edges
      @face_indices[e0.left] = nil if e0.left
      @face_indices[e0.right] = nil if e0.right
      @vertices[e0.finish] = Mittsu::Vector3.new(0,0,0) # This can become nil later when we compact and reindex things
      @edges[e0.ccw_left] = nil
      @edges[e0.cw_right] = nil
      @edges[e0.index] = nil

      # Reattach edges to remove old indexes
      # This could be much more efficient by walking round the wings
      puts "reattaching: left #{ccw_left&.index} -> #{cw_left&.index}"
      puts "reattaching: right #{cw_right&.index} -> #{ccw_right&.index}"
      puts "reattaching: finish #{e0.finish} -> #{e0.start}"
      @face_indices.each do |f|
        next if f.nil?
        f[:edge] = cw_left&.index if f[:edge] == ccw_left&.index
        f[:edge] = ccw_right&.index if f[:edge] == cw_right&.index
      end
      @edges.each do |e|
        next if e.nil?
        e.reattach_edge!(from: ccw_left.index, to: cw_left.index) if ccw_left && cw_left
        e.reattach_edge!(from: cw_right.index, to: ccw_right.index) if ccw_right && cw_right
        e.reattach_vertex!(from: e0.finish, to: e0.start) if e0
      end

      # Prepare for rendering
      raise "SHIT" unless manifold?
      flatten! if flatten
      # Return split parameters required to invert operation
      # [vertex, left_vertex, right_vertex, displacement]
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
        return false, index
      else
        index = @edges.count
        @edges << WingedEdge.new(index: index, start: v1, finish: v2, left: face)
        return true, index
      end
    end
  end
end
