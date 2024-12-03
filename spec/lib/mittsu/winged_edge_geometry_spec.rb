RSpec.describe Mittsu::MeshAnalysis::WingedEdgeGeometry do

  subject { described_class.new }

  context "with existing geometry loaded in" do
    let(:plane) { Mittsu::PlaneGeometry.new(1,1,1,1) }

    before do
      subject.from_geometry(plane)
    end

    it "preserves number of faces from original geometry" do
      expect(subject.faces.count).to eq 2
    end

    it "preserves number of vertices from original geometry" do
      expect(subject.vertices.count).to eq 4
    end

    it "creates the right number of edge records" do
      expect(subject.edges.count).to eq 5
    end

    context "when inspecting shared edge" do
      let(:edge) { subject.between(1, 2) } # These are the joined opposite corner vertices in the PlaneGeometry

      it "references left edge" do
        expect(edge.left).to eq 0
      end

      it "references right edge" do
        expect(edge.right).to eq 1
      end
    end
  end
end
