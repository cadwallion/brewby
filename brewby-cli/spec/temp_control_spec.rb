require 'spec_helper'

describe Brewby::CLI::Views::TempControl do
  let(:sensor) { Brewby::TempSensor.new 1 }
  let(:adapter) { Brewby::Outputs::Test.new }
  let(:element) { Brewby::HeatingElement.new adapter, pulse_width: 5000 }
  let(:step) { Brewby::Steps::TempControl.new mode: :manual, input: sensor, output: element }
  let(:view) { Brewby::VirtualView.new }
  let(:step_view) { Brewby::CLI::Views::TempControl.new step, view }

  describe 'rendering' do
    let(:step) { Brewby::Steps::TempControl.new mode: :auto, target: 152.0, input: sensor, output: element }

    before do
      step.instance_variable_set(:@last_reading, 100.0)
      step_view.render
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
        step_view.handle_input('e'.ord)
        step.power_level.should == 1.0
      end

      it 'decreases power level by 5% when c key is pressed' do
        step.set_power_level 0.85
        step_view.handle_input('c'.ord)
        step.power_level.should == 0.80
      end
    end

    context 'in auto mode' do
      let(:step) { Brewby::Steps::TempControl.new mode: :auto, target: 150.0, 
        input: sensor, output: element }

      it 'does nothing when e key is pressed' do
        step.set_power_level 0.80
        step_view.handle_input('e'.ord)
        step.power_level.should == 0.80 
      end

      it 'does nothing when c key is pressed' do
        step.set_power_level 0.80
        step_view.handle_input('c'.ord)
        step.power_level.should == 0.80
      end
    end
  end
end
