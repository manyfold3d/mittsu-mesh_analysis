RSpec.describe Mittsu::MeshAnalysis::WingedEdge do
  let(:edge) { described_class.new index: 0, start: 1, finish: 2, left: 3, right: 4, cw_left: 5, ccw_left: 6, cw_right: 7, ccw_right:8}

  it "has an index" do
    expect(edge.index).to eq 0
  end

  it "has a start vertex" do
    expect(edge.start).to eq 1
  end

  it "has a finish vertex" do
    expect(edge.finish).to eq 2
  end

  it "has a left face" do
    expect(edge.left).to eq 3
  end

  it "has a right face" do
    expect(edge.right).to eq 4
  end

  it "has a cw_left edge" do
    expect(edge.cw_left).to eq 5
  end

  it "has a ccw_left edge" do
    expect(edge.ccw_left).to eq 6
  end

  it "has a cw_right edge" do
    expect(edge.cw_right).to eq 7
  end

  it "has a ccw_right edge" do
    expect(edge.ccw_right).to eq 8
  end
end
