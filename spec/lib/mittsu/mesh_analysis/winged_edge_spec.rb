RSpec.describe Mittsu::MeshAnalysis::WingedEdge do
  let(:edge) { described_class.new index: 0, start: 1, finish: 2, left: 3, right: 4, start_left: 5, finish_left: 6, start_right: 7, finish_right: 8 }

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

  it "has a start_left edge" do
    expect(edge.start_left).to eq 5
  end

  it "has a finish_left edge" do
    expect(edge.finish_left).to eq 6
  end

  it "has a start_right edge" do
    expect(edge.start_right).to eq 7
  end

  it "has a finish_right edge" do
    expect(edge.finish_right).to eq 8
  end

  it "can return the other vertex index" do # rubocop:todo RSpec/MultipleExpectations
    expect(edge.other_vertex(1)).to eq 2
    expect(edge.other_vertex(2)).to eq 1
  end

  it "can reattach start to a different vertex" do # rubocop:disable RSpec/MultipleExpectations
    new_edge = edge.reattach_vertex(from: 1, to: 3)
    expect(new_edge.start).to eq 3
    expect(new_edge.finish).to eq 2
  end

  it "can reattach end to a different vertex" do # rubocop:disable RSpec/MultipleExpectations
    new_edge = edge.reattach_vertex(from: 2, to: 3)
    expect(new_edge.start).to eq 1
    expect(new_edge.finish).to eq 3
  end

  it "does not change unattached vertices" do # rubocop:disable RSpec/MultipleExpectations
    new_edge = edge.reattach_vertex(from: 5, to: 3)
    expect(new_edge.start).to eq 1
    expect(new_edge.finish).to eq 2
  end

  context "when testing for duplication with #colinear?" do
    it "returns true if start and finish are the same" do
      other = described_class.new index: 1, start: 1, finish: 2
      expect(edge.colinear?(other)).to be true
    end

    it "returns true if start and finish are the same but flipped round" do
      other = described_class.new index: 1, start: 2, finish: 1
      expect(edge.colinear?(other)).to be true
    end

    it "returns false if either start or finish are different" do
      other = described_class.new index: 1, start: 1, finish: 3
      expect(edge.colinear?(other)).to be false
    end
  end

  context "when testing for shared vertices with #coincident_at" do
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

  context "when normalizing an edge with start higher than finish" do
    let(:edge) { described_class.new(index: 0, start: 2, finish: 1, left: 3, right: 4, start_left: 5, finish_left: 6, start_right: 7, finish_right: 8).normalize }

    it "preserves index" do
      expect(edge.index).to eq 0
    end

    it "swaps vertices" do # rubocop:todo RSpec/MultipleExpectations
      expect(edge.start).to eq 1
      expect(edge.finish).to eq 2
    end

    it "swaps faces" do # rubocop:todo RSpec/MultipleExpectations
      expect(edge.left).to eq 4
      expect(edge.right).to eq 3
    end

    it "rotates wings" do # rubocop:todo RSpec/MultipleExpectations
      expect(edge.start_left).to eq 7
      expect(edge.finish_left).to eq 8
      expect(edge.start_right).to eq 5
      expect(edge.finish_right).to eq 6
    end
  end

  context "when normalizing an edge start is lower than finish" do
    let(:edge) { described_class.new(index: 0, start: 1, finish: 2, left: 3, right: 4, start_left: 5, finish_left: 6, start_right: 7, finish_right: 8).normalize }

    it "does not swap anything" do # rubocop:todo RSpec/MultipleExpectations, RSpec/ExampleLength:
      expect(edge.index).to eq 0
      expect(edge.start).to eq 1
      expect(edge.finish).to eq 2
      expect(edge.left).to eq 3
      expect(edge.right).to eq 4
      expect(edge.start_left).to eq 5
      expect(edge.finish_left).to eq 6
      expect(edge.start_right).to eq 7
      expect(edge.finish_right).to eq 8
    end
  end

  context "when checking if edges share a face" do
    it "returns index if they share the same left face" do
      other = described_class.new index: 1, start: 1, finish: 2, left: 3
      expect(edge.shared_face(other)).to eq 3
    end

    it "returns index if they share the same right face" do
      other = described_class.new index: 1, start: 1, finish: 2, right: 4
      expect(edge.shared_face(other)).to eq 4
    end

    it "returns index if they share opposite faces (l/r)" do
      other = described_class.new index: 1, start: 1, finish: 2, right: 3
      expect(edge.shared_face(other)).to eq 3
    end

    it "returns index if they share opposite faces (r/l)" do
      other = described_class.new index: 1, start: 1, finish: 2, left: 4
      expect(edge.shared_face(other)).to eq 4
    end

    it "returns nil if they do not share a face" do
      other = described_class.new index: 1, start: 1, finish: 2, left: 9, right: 10
      expect(edge.shared_face(other)).to be_nil
    end
  end

  context "when checking if coincident edges are pointing the same way" do
    it "return true if edges share a start" do
      other = described_class.new index: 1, start: 1, finish: 3
      expect(edge.same_direction?(other)).to be true
    end

    it "return true if edges share a finish" do
      other = described_class.new index: 1, start: 3, finish: 2
      expect(edge.same_direction?(other)).to be true
    end

    it "return false if our edge starts where the other finishes" do
      other = described_class.new index: 1, start: 3, finish: 1
      expect(edge.same_direction?(other)).to be false
    end

    it "return false if our edge finishes where the other starts" do
      other = described_class.new index: 1, start: 2, finish: 3
      expect(edge.same_direction?(other)).to be false
    end
  end
end
