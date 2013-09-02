module Brewby
  class HeatingElement
    attr_accessor :pulse_width, :pulse_range

    def initialize output_pin, options = {}
      @output_pin = output_pin
      @pulse_range = options[:pulse_range] || 1000
      @on = false
      @pulse_range_start = Time.now.to_i
    end

    def pulse
      set_pulse_time
      update_pulse_range
      
      if pulse_within_width?
        on!
      else
        off!
      end
    end

    def set_pulse_time time = Time.now.to_i
      @pulse_time = time
    end

    def pulse_within_width?
      time_since_last_pulse = (@pulse_time - @pulse_range_start) * 1000
      pulse_width > time_since_last_pulse
    end

    def update_pulse_range
      elapsed_time = (@pulse_time - @pulse_range_start) * 1000

      if elapsed_time > @pulse_range
        @pulse_range_start += @pulse_range
      end
    end

    def on!
      @on = true
    end

    def off!
      @on = false
    end

    def on?
      @on
    end

    def off?
      !@on
    end
  end
end
