RSpec.describe Mittsu::MeshAnalysis::Decimator do
  let(:mesh) do
    g = Mittsu::SphereGeometry.new(2.0, 32, 16)
    g.merge_vertices
    Mittsu::Mesh.new g
  end

  it "can be applied to a mesh" do
    faces = mesh.geometry.faces.length
    # Reduce by 10%
    target = faces * 0.9
    mesh.geometry = described_class.new(mesh.geometry).decimate(target)
    expect(mesh.geometry.faces.length).to be_within(1).of(target)
  end
end
