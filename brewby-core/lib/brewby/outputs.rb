require 'brewby/outputs/test'
require 'brewby/outputs/gpio'

module Brewby
  module Outputs
    def self.adapter_class adapter
      case adapter
      when :test
        Brewby::Outputs::Test
      else
        Brewby::Outputs::GPIO
      end
    end
  end
end
