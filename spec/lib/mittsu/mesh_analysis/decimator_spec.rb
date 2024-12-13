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

  context "when getting vertex splits back" do
    let(:result) { described_class.new(mesh.geometry).decimate(mesh.geometry.faces.length * 0.5, vertex_splits: true) }

    it "returns both geometry and split array" do # rubocop:disable RSpec/MultipleExpectations
      geometry, splits = result
      expect(geometry).to be_a Mittsu::Geometry
      expect(splits).to be_a Array
    end

    it "has half as many splits as the number of faces that were removed" do
      geometry, splits = result
      removed = mesh.geometry.faces.length - geometry.faces.length
      expect(splits.length).to eq removed / 2
    end

    it "creates vertex split objects" do
      _geometry, splits = result
      expect(splits[0]).to be_a Mittsu::MeshAnalysis::VertexSplit
    end
  end
end
