module Brewby
  module Inputs
    class Test
      attr_accessor :name
      def initialize options = {}
        @name = options[:name]
        @last_reading = 68.0
      end

      def read
        @last_reading = (@last_reading + 0.1).round(2)
      end
    end
  end
end
