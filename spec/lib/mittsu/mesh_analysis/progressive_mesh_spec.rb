RSpec.describe Mittsu::MeshAnalysis::ProgressiveMesh do
  let(:mesh) do
    g = Mittsu::SphereGeometry.new(2.0, 32, 16)
    g.merge_vertices
    described_class.new g
  end

  it "reduces core face count by target amount" do
    expect { mesh.progressify(ratio: 0.5) }.to change { mesh.geometry.faces.count }.from(960).to(480)
  end

  it "generates a set of vertex splits" do
    mesh.progressify(ratio: 0.5)
    expect(mesh.vertex_splits.count).to eq 240
  end
end
