module Olivine::Generator::SpaceGeometry
  class Base < Olivine::Generator::Base
    PathFinder = Olivine::PathFinder

    set_unit '空間図形', 530

    def format_quiz(expr)
      expr
    end
  end
end

require_dir 'space-geometry'
