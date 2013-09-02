module Brewby
  class TempSensor
    attr_reader :input_pin

    def initialize input_pin
      @input_pin = input_pin
    end

    def read
      0.0
    end
  end
end
