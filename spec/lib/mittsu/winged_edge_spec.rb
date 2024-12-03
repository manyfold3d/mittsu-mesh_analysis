RSpec.describe Mittsu::MeshAnalysis::WingedEdge do
  let(:edge) { described_class.new start: 1, finish: 2, left: 1, right: 2, prevLeft: 2, nextLeft: 3, prevRight: 4, nextRight: 5}

  it "has a start vertex" do
    expect(edge.start).to eq 1
  end

  it "has a finish vertex" do
    expect(edge.finish).to eq 2
  end

  it "has a left face" do
    expect(edge.left).to eq 1
  end

  it "has a right face" do
    expect(edge.right).to eq 2
  end

  it "has a prevLeft edge" do
    expect(edge.prevLeft).to eq 2
  end

  it "has a nextLeft edge" do
    expect(edge.nextLeft).to eq 3
  end

  it "has a prevRight edge" do
    expect(edge.prevRight).to eq 4
  end

  it "has a nextRight edge" do
    expect(edge.nextRight).to eq 5
  end
end
