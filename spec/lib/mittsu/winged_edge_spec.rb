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

  it "can return the other vertex index" do
    expect(edge.other_vertex(1)).to eq 2
    expect(edge.other_vertex(2)).to eq 1
  end

  it "can reattach start to a different vertex" do
    expect{edge.reattach!(from: 1, to: 3)}.to change(edge, :start).from(1).to(3).and change(edge, :finish).by(0)
  end

  it "can reattach end to a different vertex" do
    expect{edge.reattach!(from: 2, to: 3)}.to change(edge, :finish).from(2).to(3).and change(edge, :start).by(0)
  end

  it "does not change unattached vertices" do
    expect{edge.reattach!(from: 5, to: 3)}.to change(edge, :start).by(0).and change(edge, :finish).by(0)
  end

  context "testing for shared vertices with #coincident?" do

    it "matches start to start" do
      other = described_class.new index: 1, start: 1, finish: 3
      expect(edge.coincident_at(other)).to eq 1
    end

    it "matches finish to start" do
      other = described_class.new index: 1, start: 3, finish: 1
      expect(edge.coincident_at(other)).to eq 1
    end

    it "matches start to finish" do
      other = described_class.new index: 1, start: 2, finish: 3
      expect(edge.coincident_at(other)).to eq 2
    end

    it "matches finish to finish" do
      other = described_class.new index: 1, start: 3, finish: 2
      expect(edge.coincident_at(other)).to eq 2
    end

    it "returns nil if not coincident" do
      other = described_class.new index: 1, start: 3, finish: 4
      expect(edge.coincident_at(other)).to be_nil
    end
  end
end
