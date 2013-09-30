module Brewby
  module Adapters
    module Test
      class Output
        attr_accessor :name
        def initialize options = {}
          @on = false
          @name = options[:name]
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
