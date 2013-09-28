require 'spec_helper'

describe Brewby::Application do
  before do
    @output = {
      pin: 1,
      pulse_range: 5000
    }


    @application = Brewby::Application.new adapter: :test, outputs: [@output], inputs: [{}, {hardware_id: '28-ba1c9d2e48'}]
  end
  
  it 'should have one output' do
    @application.outputs.size.should == 1
    @application.outputs.first.should be_instance_of Brewby::HeatingElement
  end

  it 'should have two inputs' do
    @application.inputs.size.should == 2
    @application.inputs.each do |input|
      input.should be_instance_of Brewby::Adapters::Test::Input
    end
  end

  context 'adapters' do
    it 'determines the input adapter class based on application adapter' do
      @application.input_adapter_class.should == Brewby::Adapters::Test::Input
      @application.adapter = :raspberry_pi
      @application.input_adapter_class.should == Brewby::Adapters::RaspberryPi::DS18B20
    end

    it 'determines the output adapter class based on application adapter' do
      @application.output_adapter_class.should == Brewby::Adapters::Test::Output
      @application.adapter = :raspberry_pi
      @application.output_adapter_class.should == Brewby::Adapters::RaspberryPi::Output
    end
  end

  context 'adding steps' do
    before do
      @application.add_step :temp_control, mode: :auto, mode: :auto, target: 155.0, duration: 15
      @step = @application.steps.first
    end

    it 'creates a step object with passed configuration options' do
      @step.should be_instance_of Brewby::Steps::TempControl
    end

    it 'passes an input and an output to the step' do
      @step.input.should == @application.inputs.first
      @step.output.should == @application.outputs.first
    end

    it 'allows the step to specify the input/output objects to use' do
      @application.add_step :temp_control, mode: :auto, mode: :auto, target: 155.0, duration: 15, input: @application.inputs.last
      @step = @application.steps.last
      @step.input.should == @application.inputs.last
    end
  end
end
