module Brewby
  module Timed
    attr_reader :start_time, :end_time

    def started?
      !@start_time.nil?
    end

    def ended?
      !@end_time.nil?
    end

    def in_progress?
      started? && !ended?
    end

    def start_timer
      @start_time = Time.now
    end

    def stop_timer
      @end_time = Time.now
    end

    def elapsed
      started? ? (@end_time || Time.now) - @start_time :  0
    end

    def timer_for seconds
      if seconds < 0
        seconds = seconds * -1
        sign = "-"
      else
        sign = ""
      end

      hours = seconds / 3600
      seconds -= (hours * 3600)
      minutes = seconds / 60
      seconds -= minutes * 60

      "%s%0.2d:%0.2d:%0.2d" % [sign, hours, minutes,seconds]
    end
  end
end
