module Brewby
  module Adapters
    module Test
      class Input
        def initialize options = {}
          # nope
        end

        def read
          (75 + rand(100)).to_f
        end
      end
    end
  end
end
