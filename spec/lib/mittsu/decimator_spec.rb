RSpec.describe Mittsu::MeshAnalysis::Decimator do
  let(:mesh) do
    g = Mittsu::SphereGeometry.new(2.0, 32, 16)
    g.merge_vertices
    Mittsu::Mesh.new g
  end

  it "can be applied to a mesh" do
    vertices = mesh.geometry.vertices.length
    # Reduce by 10%
		remove = ( vertices / 10 ).floor
		mesh.geometry = described_class.new( mesh.geometry).decimate(remove)
    expect(mesh.geometry.vertices.length).to eq vertices - remove
  end

end
