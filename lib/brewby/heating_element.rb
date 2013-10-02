module Brewby
  class HeatingElement
    attr_accessor :pulse_width, :pulse_range, :name

    def initialize adapter, options = {}
      @pulse_range = options[:pulse_range] || 1000
      @on = false
      @pulse_range_end = (Time.now.to_i * 1000) + @pulse_range
      @adapter = adapter
      @pulse_width = 0
      @name = options[:name]
    end

    def pulse
      set_pulse_time
      update_pulse_range if pulse_exceeds_range?
      
      if pulse_within_width?
        on!
      else
        off!
      end
    end

    def set_pulse_time
      @pulse_time = (Time.now.to_i * 1000)
    end

    def pulse_within_width?
      @pulse_time <= pulse_end
    end

    def pulse_exceeds_range?
      @pulse_time > @pulse_range_end
    end

    def update_pulse_range
      @pulse_range_end += @pulse_range
    end

    def pulse_end
      @pulse_range_end - (@pulse_range - @pulse_width)
    end

    def on!
      @adapter.on
    end

    def off!
      @adapter.off
    end

    def on?
      @adapter.on?
    end

    def off?
      !on?
    end
  end
end
