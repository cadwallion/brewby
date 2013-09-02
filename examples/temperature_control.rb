require 'brewby'
require 'temper'

class TemperatureControl
  def initialize target_temp, duration
    @client = Brewby::Client.new
    @pid = Temper::PID.new setpoint: target_temp

    @time_start = Time.now
    @time_elapsed = 0

    @duration = duration

    @window_start = @time_start.to_i
    @window_size = 5000
  end

  def start
    while @time_elapsed < @duration
      temp = @client.get_temperature
      @output = @pid.control(temp)

      toggle_relay

      @time_elapsed = (Time.now - @time_start).to_i
    end
  end

  def toggle_relay
    now = Time.now.to_i
    if now - @window_start > @window_size
      @window_start += @window_size
    end

    if @output > now - @window_start
      @client.activate_relay
    else
      @client.deactivate_relay
    end
  end
end

TemperatureControl.new(150, 60).start
