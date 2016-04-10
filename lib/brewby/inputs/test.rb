module Brewby
  module Inputs
    class Test
      attr_accessor :name
      def initialize options = {}
        @name = options[:name]
        @value = options[:value] || (75 + rand(100)).to_f
      end

      def set_value value
        @value = value
      end

      def read
        @value
      end
    end
  end
end
