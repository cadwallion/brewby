require 'brewby/inputs/ds18b20'
require 'brewby/inputs/test'

module Brewby
  module Inputs
    def self.adapter_class adapter
      case adapter
      when :test
        Brewby::Inputs::Test
      when :ds18b20
        Brewby::Inputs::DS18B20
      else
        Brewby::Inputs::DS18B20
      end
    end
  end
end
