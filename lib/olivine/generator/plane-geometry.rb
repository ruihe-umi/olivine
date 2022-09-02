module Olivine::Generator::PlaneGeometry
  class Base < Olivine::Generator::Base
    PathFinder = Olivine::PathFinder

    set_unit '平面図形', 510

    def format_quiz(expr)
      expr
    end
  end
end

require_dir 'plane-geometry'
