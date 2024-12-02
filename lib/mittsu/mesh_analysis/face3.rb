module Mittsu::MeshAnalysis::Face3
  def flip!
    tmp = @a
    @a = @c
    @c = tmp
  end
end
