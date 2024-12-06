RSpec.describe Mittsu::MeshAnalysis::WingedEdgeGeometry do

  subject { described_class.new }

  context "with existing geometry loaded in" do
    let(:plane) { Mittsu::PlaneGeometry.new(1,1,1,1) }

    before do
      subject.from_geometry(plane, normalize: false)
    end

    it "preserves number of faces from original geometry" do
      subject.flatten!
      expect(subject.faces.count).to eq 2
    end

    it "preserves number of vertices from original geometry" do
      expect(subject.vertices.count).to eq 4
    end

    it "creates the right number of edge records" do
      expect(subject.edges.count).to eq 5
    end

    context "when inspecting diagonal edge" do
      # These are the joined opposite corner vertices in the PlaneGeometry
      let(:edge) { subject.between(1, 2) }

      it "references left face" do
        expect(edge.left).to eq 0
      end

      it "references right face" do
        expect(edge.right).to eq 1
      end

      it "references clockwise edge on left side" do
        expect(edge.cw_left).to eq 0
      end

      it "references counter-clockwise edge on left side" do
        expect(edge.ccw_left).to eq 2
      end

      it "references clockwise edge on right side" do
        expect(edge.cw_right).to eq 4
      end

      it "references counter-clockwise edge on right side" do
        expect(edge.ccw_right).to eq 3
      end

      it "has a valid cw left loop" do
        e1 = subject.edge(edge.cw_left)
        expect(e1.left).to eq edge.left
        e2 = subject.edge(e1.cw_left)
        expect(e2.left).to eq edge.left
        expect(e2.cw_left).to eq edge.index
      end

      it "has a valid ccw left loop" do
        e1 = subject.edge(edge.ccw_left)
        expect(e1.left).to eq edge.left
        e2 = subject.edge(e1.ccw_left)
        expect(e2.left).to eq edge.left
        expect(e2.ccw_left).to eq edge.index
      end

      it "has a valid cw right loop" do
        e1 = subject.edge(edge.cw_right)
        expect(e1.left).to eq edge.right
        e2 = subject.edge(e1.cw_left)
        expect(e2.left).to eq edge.right
        expect(e2.cw_left).to eq edge.index
      end

      it "has a valid ccw right loop" do
        e1 = subject.edge(edge.ccw_right)
        expect(e1.left).to eq edge.right
        e2 = subject.edge(e1.ccw_left)
        expect(e2.left).to eq edge.right
        expect(e2.ccw_left).to eq edge.index
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
      subject.from_geometry(sphere)
    end

    it "preserves number of faces from original geometry" do
      subject.flatten!
      expect(subject.faces.count).to eq(
        (14*32*2) + # quads around the sphere
        (2*32) # triangles at the poles
      )
    end

    it "preserves number of vertices from original geometry" do
      expect(subject.vertices.count).to eq((30*16) + 2)
    end

    it "creates the right number of edge records" do
      expect(subject.edges.count).to eq(
        ((14*32*2) + (2*32)) + # faces
        ((30*16) + 2) + # vertices
        -2 # From the Euler characteristic: F + V − E = 2
      )
    end

    it "checks mesh integrity" do
      expect(subject).to be_manifold
    end
  end
end
