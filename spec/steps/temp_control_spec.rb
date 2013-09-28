require 'spec_helper'

describe Brewby::Steps::TempControl do
  let(:sensor) { Brewby::TempSensor.new 1 }
  let(:adapter) { Brewby::Adapters::Test::Output.new }
  let(:element) { Brewby::HeatingElement.new adapter, pulse_width: 5000 }
  let(:step) { Brewby::Steps::TempControl.new input: sensor, output: element }

  it 'configures an input sensor' do
    step.input.should be_instance_of Brewby::TempSensor
  end

  it 'configures an output sensor' do
    step.output.should be_instance_of Brewby::HeatingElement
  end

  context 'automatic temperature control' do
    before do
      @step = Brewby::Steps::TempControl.new mode: :auto, target: 155.0, 
        duration: 15, output: element, input: sensor
    end

    it 'configures a PID controller' do
      @step.pid.should be_instance_of Temper::PID
    end

    it 'sets a target temperature' do
      @step.target.should == 155.0
      @step.pid.setpoint.should == 155.0
    end

    it 'sets a temperature hold duration' do
      @step.duration.should == 15
    end

    it 'defaults to a 1 minute temperature hold duration' do
      step = Brewby::Steps::TempControl.new mode: :auto, target: 155.0
      step.duration.should == 1
    end

    it 'returns true for automatic control' do
      @step.automatic_control?.should be_true
    end

    it 'returns false for manual control' do
      @step.manual_control?.should be_false
    end

    it 'calculates the output level based on PID levels' do
      @step.calculate_power_level
      @step.power_level.should == 5000
      @step.output.pulse_width.should == 5000
    end
  end

  context 'manual temperature control' do
    before do
      @step = Brewby::Steps::TempControl.new mode: :manual, output: element, input: sensor
    end

    it 'does not create a PID controller' do
      @step.pid.should be_nil
    end

    it 'returns true for manual mode' do
      @step.manual_control?.should be_true
    end

    it 'returns false for automatic control' do
      @step.automatic_control?.should be_false
    end

    it 'sets the power level manually' do
      @step.set_power_level 1
      @step.power_level.should == 5000
      @step.output.pulse_width.should == 5000
    end
  end

  it 'reads sensor input' do
    @step = Brewby::Steps::TempControl.new mode: :auto, target: 155.0,
      duration: 15, input: sensor, output: element
    @step.input.should_receive(:read) { 115.0 }
    @step.read_input
    @step.last_reading.should == 115.0
  end

  describe 'step iteration' do
    before do
      @step = Brewby::Steps::TempControl.new mode: :auto, target: 155.0,
        duration: 15, input: sensor, output: element
    end

    it 'pulses the element' do
      @step.output.should_receive(:pulse)
      @step.step_iteration
    end

    it 'calculates the power level and adjusts the heating element' do
      @step.pid.stub(:control) { 3000 }
      @step.step_iteration
      @step.output.pulse_width.should == 3000
    end

    it 'reads from the sensor and logs to last_reading' do
      @step.input.stub(:read) { 125.0 }
      @step.step_iteration
      @step.last_reading.should == 125.0
    end
  end
end
