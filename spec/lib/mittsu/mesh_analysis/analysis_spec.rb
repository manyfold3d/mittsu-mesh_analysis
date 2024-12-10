RSpec.describe "Mittsu::MeshAnalysis::Analysis" do
  let(:mesh) do
    m = Mittsu::Mesh.new(Mittsu::SphereGeometry.new(2.0, 32, 16))
    m.geometry.merge_vertices
    m
  end

  it "verifies that good meshes are manifold" do
    expect(mesh.manifold?).to be true
  end

  it "detects that meshes with flipped faces are non-manifold" do
    # Flip a single face
    mesh.geometry.faces.first.flip!
    expect(mesh.manifold?).to be false
  end

  it "detects that meshes with holes are non-manifold" do
    # Remove a face
    mesh.geometry.faces.pop
    expect(mesh.manifold?).to be false
  end

  it "verifies that meshes are solid when normals are pointing outwards" do
    expect(mesh.solid?).to be true
  end

  it "detects that meshes where the normals point inwards are not solid" do
    # Flip all the faces on our test object and recalculate normals
    mesh.geometry.faces.each { |f| f.flip! }
    mesh.geometry.compute_face_normals
    expect(mesh.solid?).to be false
  end
end
