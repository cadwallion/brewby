module Brewby
  module Outputs
    class Test
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
