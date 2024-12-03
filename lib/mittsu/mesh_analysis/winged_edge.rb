class Mittsu::MeshAnalysis::WingedEdge

  attr_accessor :start, :finish, :left, :right, :prevLeft, :nextLeft, :prevRight, :nextRight

  def initialize(start:, finish:, left:, right:, prevLeft:, nextLeft:, prevRight:, nextRight:)
    # Vertices
    @start = start
    @finish = finish
    # Faces
    @left = left
    @right = right
    # Edges
    @prevLeft = prevLeft
    @nextLeft = nextLeft
    @prevRight = prevRight
    @nextRight = nextRight
  end

end
