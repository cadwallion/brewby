$: << File.join(File.dirname(__FILE__), '..', 'lib')
require 'brewby'

class StepMash < Brewby::Application
  def tick
    super
    render_status
  end

  def render_status
    @last_output ||= Time.now
    if @last_output < (Time.now - 1)
      puts "Target: #{current_step.target}F\tActual: #{current_step.last_reading}F\tPower Level: #{current_step.power_level * 100}%"
      @last_output = Time.now
    end
  end
end

application = StepMash.new inputs: [{}], outputs: [{}]
application.add_step :temp_control, target: 125.0, duration: 15
application.add_step :temp_control, target: 155.0, duration: 35
application.add_step :temp_control, target: 168.0, duration: 10

application.start
