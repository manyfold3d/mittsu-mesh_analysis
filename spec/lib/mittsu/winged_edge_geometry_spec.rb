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

    end
  end
end
