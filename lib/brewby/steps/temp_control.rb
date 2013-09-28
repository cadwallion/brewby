require 'brewby/temp_sensor'
require 'brewby/heating_element'
require 'brewby/timed'
require 'temper'

module Brewby
  module Steps
    class TempControl
      attr_reader :input, :output, :pid, :target, :duration, :mode, :last_reading
      
      include Brewby::Timed

      def initialize options = {}
        @mode = options[:mode] || :manual
        @output = 0
        @pulse_range = options[:pulse_range] || 5000

        @input = options[:input]
        @output = options[:output]

        if automatic_control?
          configure_automatic_control options
        end
      end

      def configure_automatic_control options
        @target = options[:target]
        @duration = options[:duration] || 1

        @pid = Temper::PID.new maximum: @pulse_range
        @pid.tune 44, 165, 4 
        @pid.setpoint = @target
      end

      def manual_control?
        !automatic_control?
      end

      def automatic_control?
        @mode == :auto
      end

      def read_input
        @last_reading = input.read
      end

      def set_power_level level
        set_pulse_width (level * @pulse_range)
      end

      def calculate_power_level
        set_pulse_width pid.control read_input
      end

      def set_pulse_width width
        output.pulse_width = width
      end

      def power_level
        output.pulse_width
      end
    end
  end
end
