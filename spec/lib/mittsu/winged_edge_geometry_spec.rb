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
  end
end
