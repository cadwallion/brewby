require 'brewby/temp_sensor'
require 'brewby/heating_element'
require 'brewby/timed'
require 'temper'

module Brewby
  module Steps
    class TempControl
      attr_reader :input, :output, :pid, :target, :duration, :mode, :threshold_reached, :name, :readings

      include Brewby::Timed

      def initialize options = {}
        @mode = options[:mode] || :manual
        @output = 0
        @pulse_range = options[:pulse_range] || 5000

        @input = options[:input]
        @output = options[:output]
        @threshold_reached = false
        @name = options[:name]
        @readings = [{ value: 0.0,  time: Time.now }]

        if automatic_control?
          configure_automatic_control options
        else
          set_power_level options[:power_level] || 1.0
        end
      end

      def last_reading
        @readings.last[:value]
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
        if reading = input.read
          @readings.push({ value: reading, time: Time.now })
        end
        reading
      end

      def set_power_level level
        set_pulse_width (level * @pulse_range).to_i
      end

      def calculate_power_level
        if read_input
          set_pulse_width pid.control last_reading
        end
      end

      def set_pulse_width width
        if width
          output.pulse_width = width
        end
      end

      def power_level
        output.pulse_width / @pulse_range.to_f
      end

      def step_iteration
        if automatic_control?
          calculate_power_level
          output.pulse
          check_temp_threshold unless threshold_reached
          check_step_completion
        else
          read_input if input
          output.pulse
        end
      end

      def check_step_completion
        if threshold_reached && Time.now.to_i > @step_finishes_at
          stop_timer
        end
      end

      def time_remaining
        if @step_finishes_at
          @step_finishes_at - Time.now.to_i
        else
          duration_in_seconds
        end
      end

      def check_temp_threshold
        if last_reading >= target
          @threshold_reached = true
          @step_finishes_at = Time.now.to_i + duration_in_seconds
        end
      end

      def duration_in_seconds
        @duration * 60
      end

      def render(view)
        view.move 2, 10
        if @name
          view.addstr @name.ljust(70)
        else
          view.addstr "#{mode.capitalize} Temp Control".ljust(70)
        end

        view.move 6, 0
        view.addstr "Power Level: #{(power_level * 100.0).round(3)}%".ljust(70)
        view.move 16, 50
        view.addstr "Step Timer: #{timer_for(elapsed.to_i)}"
        view.refresh

        if target
          view.move 4, 0
          view.addstr "Target Temp: #{target} F".ljust(70)
        end

        view.move 5, 0
        view.addstr "Actual Temp: #{last_reading} F".ljust(25)

        if threshold_reached
          view.move 7, 0
          view.addstr "Time Remaining: #{countdown_for(time_remaining)}".ljust(70)
        else
          view.move 7, 0
          view.addstr "".ljust(70)
        end
      end

      def handle_input key
        case key
        when 'e'.ord
          if @mode == :manual
            new_pct = [(power_level + 0.05).round(2), 1.0].min
            set_power_level new_pct
          end
        when 'c'.ord
          if @mode == :manual
            new_pct = [(power_level - 0.05).round(2), 0.0].max
            set_power_level new_pct
          end
        end
      end
    end
  end
end
