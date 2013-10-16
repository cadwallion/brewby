require 'spec_helper'

describe Brewby::Steps::TempControl do
  let(:sensor) { Brewby::TempSensor.new 1 }
  let(:adapter) { Brewby::Outputs::Test.new }
  let(:element) { Brewby::HeatingElement.new adapter, pulse_width: 5000 }
  let(:step) { Brewby::Steps::TempControl.new mode: :manual, input: sensor, output: element }

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
      @step.power_level.should == 1.0
      @step.output.pulse_width.should == 5000
    end

    it 'does not explode with a faulty input' do
      @step.stub(:read_input) { nil }
      @step.calculate_power_level
      @step.output.pulse_width.should == 0
    end
  end

  context 'manual temperature control' do
    before do
      @step = Brewby::Steps::TempControl.new mode: :manual, power_level: 0.85, output: element, input: sensor
    end

    it 'does not create a PID controller' do
      @step.pid.should be_nil
    end

    it 'returns true for manual mode' do
      @step.should be_manual_control
    end

    it 'returns false for automatic control' do
      @step.should_not be_automatic_control
    end

    it 'sets the power level' do
      @step.power_level.should == 0.85
      @step.output.pulse_width.should == 4250
    end

    it 'can have the power level set manually' do
      @step.set_power_level 0.75
      @step.power_level.should == 0.75
      @step.output.pulse_width.should == 3750
    end
  end

  context 'sensor input' do
    before do
      @step = Brewby::Steps::TempControl.new mode: :auto, target: 155.0,
        duration: 15, input: sensor, output: element
    end

    it 'reads sensor input' do
      @step.input.should_receive(:read) { 115.0 }
      @step.read_input.should == 115.0
      @step.last_reading.should == 115.0
    end

    it 'does not set last_reading if sensor input is faulty' do
      @step.input.stub(:read) { nil }
      @step.read_input.should be_nil
      @step.last_reading.should == 0.0
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
        @step.output.should be_on
      end

      it 'takes a sensor reading' do
        @step.input.stub(:read) { 115.0 }
        @step.step_iteration
        @step.last_reading.should == 115.0
      end

      it 'does not take a sensor reading if input does not exist' do
        @step = Brewby::Steps::TempControl.new mode: :manual, power_level: 0.85, output: element
        @step.step_iteration
        @step.last_reading.should == 0.0
      end
    end

    context 'with automatic control' do
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

      context 'when temperature threshold is reached' do
        before do
          @step.input.stub(:read) { 156.0 }
          @step.step_iteration
        end

        it 'sets the threshold as true' do
          @step.threshold_reached.should be_true
        end

        it 'maintains threshold_reached even when temp drops below threshold' do
          @step.input.stub(:read) { 145.0 }
          @step.step_iteration
          @step.threshold_reached.should be_true
        end

        it 'starts the clock on time remaining' do
          (@step.time_remaining > 0).should be_true
          (@step.time_remaining <= @step.duration_in_seconds).should be_true
        end

        it 'stops the step when temperature has hit target for duration' do
          @step.instance_variable_set(:@step_finishes_at, Time.now.to_i - 10)
          @step.step_iteration
          @step.should be_ended
        end
      end
    end

    describe 'rendering' do

      let(:step) { Brewby::Steps::TempControl.new mode: :auto, target: 152.0, input: sensor, output: element }
      let(:view) { Brewby::VirtualView.new }
      before do
        step.instance_variable_set(:@last_reading, 100.0)
        step.render(view)
      end

      it 'renders the default name of the step' do
        line = view.readline(2).strip
        line.should == "Auto Temp Control"
      end

      it 'renders the actual temperature' do
        line = view.readline(5).strip
        line.should == "Actual Temp: 100.0 F"
      end

      it 'renders the target temperature' do
        line = view.readline(4).strip
        line.should == "Target Temp: 152.0 F"
      end

      it 'renders the current power level' do
        line = view.readline(6).strip
        line.should == "Power Level: 0.0%"
      end

      it 'renders the step timer' do
        line = view.readline(16).strip
        line.should == "Step Timer: 00:00:00"
      end
    end

    describe 'input handling' do
      context 'in manual mode' do
        it 'increases power level by 5% when e key is pressed' do
          step.set_power_level 0.95
          step.handle_input('e'.ord)
          step.power_level.should == 1.0
        end

        it 'decreases power level by 5% when c key is pressed' do
          step.set_power_level 0.85
          step.handle_input('c'.ord)
          step.power_level.should == 0.80
        end
      end

      context 'in auto mode' do
        let(:step) { Brewby::Steps::TempControl.new mode: :auto, target: 150.0, 
          input: sensor, output: element }

        it 'does nothing when e key is pressed' do
          step.set_power_level 0.80
          step.handle_input('e'.ord)
          step.power_level.should == 0.80 
        end

        it 'does nothing when c key is pressed' do
          step.set_power_level 0.80
          step.handle_input('c'.ord)
          step.power_level.should == 0.80
        end
      end
    end
  end
end
