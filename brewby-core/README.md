# Brewby Core

Core functionality underpinning Brewby - IO interfacing Layer, Recipe DSL, Configuration Loading,
and more.

This library is the foundation for brewery automation applications themselves.  Unless you are
writing a brewery automation application, you will not use this library directly.


## Input Sensors

brewby-core provides adapters for input sensors in a consistent interface.  The following adapters
are currently supported, with several more on the way:

* `Brewby::Input::DS18B20` - Dallas 18B20 temperature sensors runnning on the One-Wire Bus
* `Brewby::Input::Test` - A fake sensor that grabs a random number. Used for testing purposes

## Output Adapters

brewby-core also provides an interface for controlling output for heat sources.  There are two
layers to this system.  The first is the low-level interface adapters for output: GPIO, serial
communication, etc.  These are what trigger the on/off states directly.  On top of that is the
layer that handles knowing when to turn on/off a heating element.  We control this via the
`Brewby::HeatingElement` class, passing it an output adapter.  By setting a few variables, we
can simulate a percentage of total output power utilizing software-based pulse-width modulation.
The principle of pulse width modulation is that you break on/off cycle into equal time lengths
with an identical output waves.  For example, if you wish to simulate 50% power but only have an
on/off switch, you break it up into equal, one-second time lengths, with 500 milliseconds on
and 500 milliseconds off.  The duration of the wave length is called the pulse width, and the
total size of the wave length is called the pulse range.  By modulating between on/off states,
you simulate power levels.

Here is an example of the `Brewby::HeatingElement` class in action, with a 5 second pulse range
and a 2.5 second pulse width.  By continuously calling `pulse`, we check the time and toggle the
element on and off via the passed in adapter:

``` ruby
adapter = Brewby::Outputs::Test.new
element = Brewby::HeatingElement.new(adapter, pulse_range: 5000)
element.pulse_width = 2500  # 50% power

loop do
  element.pulse
  if element.on?
    puts "Within pulse width"
  else
    puts "Outside pulse width"
  end
end
```

## Recipe Steps

Creating a good brew requires several steps in the process, some automatable and some eot. Brewby
treats these steps as logic gates, encapsulating the control for each step based on a step type.
Currently, Brewby only has the `TempControl` step for handling temperature control via manual
and automatic control and duration.  Here is an example of a temperature control step for a mash
step, holding at 155F for 75 minutes:

``` ruby
  sensor = Brewby::Inputs::Test.new
  relay = Brewby::Outputs::Test.new
  element = Brewby::HeatingElement.new(relay, pulse_range: 5000)
  step = Brewby::Steps::TempControl.new({
    mode: :auto, 
    input: sensor, 
    output: element, 
    target: 150.0,
    duration: 75
  })

  loop do
    step.step_iteration
    break if step.time_remaining <= 0
  end
```

## Brewby Applications

As you can imagine, writing out several steps can be very repetitive, especially when handling 
something like a multiple decoction step mash schedule.  Not only do the steps need to be handled,
but the equipment configuration needs to be setup every time a new step is created. To handle this,
steps are wrapped into an Application to act as the bridge between Steps and IO.

``` ruby
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

application = StepMash.new
application.add_input :test
application.add_output :test
application.add_step :temp_control, target: 125.0, duration: 15
application.add_step :temp_control, target: 155.0, duration: 35
application.add_step :temp_control, target: 168.0, duration: 10

application.start
```

By default, Applications use the first input and output when adding new steps unless passed in
as an option to the `add_step` method.
