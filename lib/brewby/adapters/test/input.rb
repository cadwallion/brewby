module Brewby
  module Adapters
    module Test
      class Input
        attr_accessor :name
        def initialize options = {}
          @name = options[:name]
        end

        def read
          (75 + rand(100)).to_f
        end
      end
    end
  end
end
