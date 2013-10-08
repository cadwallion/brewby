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
      time = seconds > 0 ? time_from_seconds(seconds) : [0, 0, 0]

      "%0.2d:%0.2d:%0.2d" % time
    end

    def countdown_for seconds
      sign = seconds > 0 ? "" : "+"

      sign + timer_for(seconds.abs)
    end

    def time_from_seconds seconds
      hours = seconds / 3600
      seconds -= (hours * 3600)
      minutes = seconds / 60
      seconds -= minutes * 60

      [hours, minutes, seconds]
    end
  end
end
