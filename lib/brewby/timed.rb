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

    def start!
      @start_time = Time.now
    end

    def stop!
      @end_time = Time.now
    end

    def elapsed
      started? ? (@end_time || Time.now) - @start_time :  0
    end
  end
end
