RSpec.describe Mittsu::MeshAnalysis::WingedEdgeGeometry do
  subject(:geometry) { described_class.new }

  context "with existing geometry loaded in" do
    let(:plane) { Mittsu::PlaneGeometry.new(1, 1, 1, 1) }

    before do
      geometry.from_geometry(plane, normalize: false)
    end

    it "preserves number of faces from original geometry" do
      geometry.flatten!
      expect(geometry.faces.count).to eq 2
    end

    it "preserves number of vertices from original geometry" do
      expect(geometry.vertices.count).to eq 4
    end

    it "creates the right number of edge records" do
      expect(geometry.edges.count).to eq 5
    end

    context "when inspecting diagonal edge" do
      # These are the joined opposite corner vertices in the PlaneGeometry
      let(:edge) { geometry.between(1, 2) }

      it "calculates edge lengths" do
        expect(geometry.edge_length(edge.index)).to be_within(0.1).of(1.414)
      end

      it "references left face" do
        expect(edge.left).to eq 0
      end

      it "references right face" do
        expect(edge.right).to eq 1
      end

      it "references clockwise edge on left side" do
        expect(edge.start_left).to eq 0
      end

      it "references counter-clockwise edge on left side" do
        expect(edge.finish_left).to eq 2
      end

      it "references clockwise edge on right side" do
        expect(edge.start_right).to eq 4
      end

      it "references counter-clockwise edge on right side" do
        expect(edge.finish_right).to eq 3
      end

      it "has a valid cw left loop" do # rubocop:todo RSpec/MultipleExpectations
        e1 = geometry.edge(edge.start_left)
        expect(e1.left).to eq edge.left
        e2 = geometry.edge(e1.start_left)
        expect(e2.left).to eq edge.left
        expect(e2.start_left).to eq edge.index
      end

      it "has a valid ccw left loop" do # rubocop:todo RSpec/MultipleExpectations
        e1 = geometry.edge(edge.finish_left)
        expect(e1.left).to eq edge.left
        e2 = geometry.edge(e1.finish_left)
        expect(e2.left).to eq edge.left
        expect(e2.finish_left).to eq edge.index
      end

      it "has a valid cw right loop" do # rubocop:todo RSpec/MultipleExpectations
        e1 = geometry.edge(edge.start_right)
        expect(e1.left).to eq edge.right
        e2 = geometry.edge(e1.start_left)
        expect(e2.left).to eq edge.right
        expect(e2.start_left).to eq edge.index
      end

      it "has a valid ccw right loop" do # rubocop:todo RSpec/MultipleExpectations
        e1 = geometry.edge(edge.finish_right)
        expect(e1.left).to eq edge.right
        e2 = geometry.edge(e1.finish_left)
        expect(e2.left).to eq edge.right
        expect(e2.finish_left).to eq edge.index
      end
    end
  end

  context "with a larger geometry loaded in" do
    let(:sphere) {
      s = Mittsu::SphereGeometry.new(2.0, 32, 16)
      s.merge_vertices
      s
    }

    before do
      geometry.from_geometry(sphere)
    end

    it "preserves number of faces from original geometry" do
      geometry.flatten!
      expect(geometry.faces.count).to eq(
        (14 * 32 * 2) + # quads around the sphere
        (2 * 32) # triangles at the poles
      )
    end

    it "preserves number of vertices from original geometry" do
      expect(geometry.vertices.count).to eq((30 * 16) + 2)
    end

    it "creates the right number of edge records" do
      expect(geometry.edges.count).to eq(
        ((14 * 32 * 2) + (2 * 32)) + # faces
        ((30 * 16) + 2) + # vertices
        -2 # From the Euler characteristic: F + V − E = 2
      )
    end

    it "checks mesh integrity" do
      expect(geometry).to be_manifold
    end
  end

  context "when collapsing edges" do
    let(:sphere) {
      s = Mittsu::SphereGeometry.new(2.0, 32, 16)
      s.merge_vertices
      s
    }

    before do
      geometry.from_geometry(sphere)
    end

    it "removes two faces when collapsing a single edge" do
      expect { geometry.collapse(100) }.to change { geometry.faces.count }.by(-2)
    end

    it "removes one vertex when collapsing a single edge" do
      pending "awaiting implementation of vertex compaction"
      expect { geometry.collapse(100) }.to change { geometry.vertices.count }.by(-1)
    end

    context "when inspecting vertex split data" do
      let(:split_data) { geometry.collapse(100) }

      it "returns vertex index that needs splitting" do
        expect(split_data.vertex).to eq 44
      end

      it "returns left vertex index" do
        expect(split_data.left).to eq 12
      end

      it "returns right vertex index" do
        expect(split_data.right).to eq 481
      end

      it "returns displacement vector" do
        expected = Mittsu::Vector3.new(0.057990, 0, -0.047592)
        [:x, :y, :z].each do |axis|
          expect(split_data.displacement.send(axis)).to be_within(1e-6).of expected.send(axis)
        end
      end
    end
  end

  context "when reordering vertices" do
    let(:sphere) {
      s = Mittsu::SphereGeometry.new(2.0, 32, 16)
      s.merge_vertices
      s
    }

    before do
      geometry.from_geometry(sphere)
    end

    it "can reorder vertices by floating them to end of the array" do
      original = geometry.vertices[10].clone
      expect { geometry.move_vertex_to_end(10) }.to change { geometry.vertices.last }.to(original)
    end

    it "keeps number of vertices the same" do
      expect { geometry.move_vertex_to_end(10) }.not_to change { geometry.vertices.count }
    end

    it "updates vertex references in edges for this vertex" do
      expect { geometry.move_vertex_to_end(0) }.to change { geometry.edges.first.start }.from(0).to(481)
    end

    it "updates all other vertex references" do
      expect { geometry.move_vertex_to_end(0) }.to change { geometry.edges.first.finish }.from(1).to(0)
    end

    it "leaves vertex references lower than passed index intact" do
      expect { geometry.move_vertex_to_end(3) }.not_to change { geometry.edges.first.finish }
    end

    it "does not change anything if this is already the last vertex" do
      expect { geometry.move_vertex_to_end(481) }.not_to change(geometry, :edges)
    end

    it "fails safe if index is too high" do
      expect { geometry.move_vertex_to_end(999) }.not_to raise_error
    end
  end
end
