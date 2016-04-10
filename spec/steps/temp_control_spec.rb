require 'spec_helper'

describe Brewby::Steps::TempControl do
  let(:sensor) { Brewby::Inputs::Test.new }
  let(:adapter) { Brewby::Outputs::Test.new }
  let(:element) { Brewby::HeatingElement.new adapter, pulse_width: 5000 }
  let(:step) { Brewby::Steps::TempControl.new mode: :manual, input: sensor, output: element }

  it 'configures an input sensor' do
    expect(step.input).to be_instance_of Brewby::Inputs::Test
  end

  it 'configures an output sensor' do
    expect(step.output).to be_instance_of Brewby::HeatingElement
  end

  context 'automatic temperature control' do
    before do
      @step = Brewby::Steps::TempControl.new mode: :auto, target: 155.0,
        duration: 15, output: element, input: sensor
    end

    it 'configures a PID controller' do
      expect(@step.pid).to be_instance_of Temper::PID
    end

    it 'sets a target temperature' do
      expect(@step.target).to eql 155.0
    end

    it "sets the pid setpoint to the target" do
      expect(@step.pid.setpoint).to eql 155.0
    end

    it 'sets a temperature hold duration' do
      expect(@step.duration).to eql 15
    end

    it 'defaults to a 1 minute temperature hold duration' do
      step = Brewby::Steps::TempControl.new mode: :auto, target: 155.0
      expect(step.duration).to eql 1
    end

    it 'returns true for automatic control' do
      expect(@step.automatic_control?).to be true
    end

    it 'returns false for manual control' do
      expect(@step.manual_control?).to be false
    end

    it 'calculates the output level based on PID levels' do
      @step.input.set_value 1.0
      @step.calculate_power_level
      expect(@step.power_level).to eql 1.0
    end

    it "sets the pulse width based on the power level" do
      @step.input.set_value 1.0
      @step.calculate_power_level
      expect(@step.output.pulse_width).to eql 5000
    end

    it 'does not explode with a faulty input' do
      @step.input.set_value nil
      @step.calculate_power_level
      expect(@step.output.pulse_width).to eql 0
    end
  end

  context 'manual temperature control' do
    before do
      @step = Brewby::Steps::TempControl.new mode: :manual, power_level: 0.85, output: element, input: sensor
    end

    it 'does not create a PID controller' do
      expect(@step.pid).to be nil
    end

    it 'returns true for manual mode' do
      expect(@step.manual_control?).to be true
    end

    it 'returns false for automatic control' do
      expect(@step.automatic_control?).to be false
    end

    it 'sets the power level' do
      expect(@step.power_level).to eql 0.85
    end

    it "maps the pulse width to the power level" do
      expect(@step.output.pulse_width).to eql 4250
    end

    it 'can have the power level set manually' do
      @step.set_power_level 0.75
      expect(@step.power_level).to eql 0.75
    end

    it "maps the pulse width based on the manual power level" do
      @step.set_power_level 0.75
      expect(@step.output.pulse_width).to eql 3750
    end
  end

  context 'sensor input' do
    before do
      @step = Brewby::Steps::TempControl.new mode: :auto, target: 155.0,
        duration: 15, input: sensor, output: element
    end

    it 'reads sensor input' do
      @step.input.set_value 115.0
      expect(@step.read_input).to eql 115.0
    end

    it "sets the last_reading based on sensor input" do
      @step.input.set_value 115.0
      @step.read_input
      expect(@step.last_reading).to eql 115.0
    end

    it 'does not set last_reading if sensor input is faulty' do
      @step.input.set_value nil
      @step.read_input
      expect(@step.last_reading).to eql 0.0
    end
  end

  describe 'step iteration' do
    context 'with manual control' do
      before do
        @step = Brewby::Steps::TempControl.new mode: :manual, power_level: 0.85,
          input: sensor, output: element
      end

      it 'pulses the element' do
        @step.step_iteration
        expect(@step.output.on?).to be true
      end

      it 'takes a sensor reading' do
        @step.input.set_value 115.0
        @step.step_iteration
        expect(@step.last_reading).to eql 115.0
      end

      it 'does not take a sensor reading if input does not exist' do
        @step = Brewby::Steps::TempControl.new mode: :manual, power_level: 0.85, output: element
        @step.step_iteration
        expect(@step.last_reading).to eql 0.0
      end
    end

    context 'with automatic control' do
      before do
        @step = Brewby::Steps::TempControl.new mode: :auto, target: 155.0,
          duration: 15, input: sensor, output: element
      end

      it 'pulses the element' do
        @step.step_iteration
      end

      it 'calculates the power level and adjusts the heating element' do
        #@step.pid.stub(:control) { 3000 }
        @step.input.set_value 136.0
        @step.step_iteration
        expect(@step.output.pulse_width).to eql 3427.0
      end

      it 'reads from the sensor and logs to last_reading' do
        @step.input.set_value 125.0
        @step.step_iteration
        expect(@step.last_reading).to eql 125.0
      end

      context 'when temperature threshold is reached' do
        before do
          @step.input.set_value 156.0
          @step.step_iteration
        end

        it 'sets the threshold as true' do
          expect(@step.threshold_reached).to be true
        end

        it 'maintains threshold_reached even when temp drops below threshold' do
          @step.input.set_value 145.0
          @step.step_iteration
          expect(@step.threshold_reached).to be true
        end

        it 'starts the clock on time remaining' do
          expect(@step.time_remaining > 0).to be true
          expect(@step.time_remaining <= @step.duration_in_seconds).to be true
        end

        it 'stops the step when temperature has hit target for duration' do
          @step.instance_variable_set(:@step_finishes_at, Time.now.to_i - 10)
          @step.step_iteration
          expect(@step.ended?).to be true
        end
      end
    end
  end
end
