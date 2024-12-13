RSpec.describe Mittsu::MeshAnalysis::VertexSplit do
  subject(:split) {
    described_class.new(
      vertex: 1, left: 2, right: 3,
      displacement: Mittsu::Vector3.new(0.1, 0.2, 0.3)
    )
  }

  it "has a vertex index" do
    expect(split.vertex).to eq 1
  end

  it "has a left vertex index" do
    expect(split.left).to eq 2
  end

  it "has a right vertex index" do
    expect(split.right).to eq 3
  end

  it "has a displacement vector" do
    expect(split.displacement).to eq Mittsu::Vector3.new(0.1, 0.2, 0.3)
  end
end
