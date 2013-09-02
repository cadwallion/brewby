require 'spec_helper'

describe Brewby::Steps::TempControl do
  it 'configures an input sensor' do
    step = Brewby::Steps::TempControl.new input: 1
    step.input.should be_instance_of Brewby::TempSensor
  end

  it 'configures an output sensor' do
    step = Brewby::Steps::TempControl.new output: 1
    step.output.should be_instance_of Brewby::HeatingElement
  end

  context 'automatic temperature control' do
    before do
      @step = Brewby::Steps::TempControl.new mode: :auto, target: 155.0, duration: 15
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
      @step = Brewby::Steps::TempControl.new mode: :manual
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
    @step = Brewby::Steps::TempControl.new mode: :auto, target: 155.0, duration: 15
    @step.input.should_receive(:read) { 115.0 }
    @step.read_input
    @step.last_reading.should == 115.0
  end
end
