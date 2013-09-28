module Brewby
  module Adapters
    module Test
      class Output
        def initialize options = {}
          @on = false
        end

        def on
          @on = true
        end

        def off
          @on = false
        end

        def on?
          @on
        end
      end
    end
  end
end
