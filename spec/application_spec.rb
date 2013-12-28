require 'spec_helper'

describe Brewby::Application do
  before do
    @output = {
      pin: 1,
      pulse_range: 5000
    }

    Brewby::Application.any_instance.stub(:configure_view)
    @view = Brewby::VirtualView.new
    Brewby::Application.any_instance.stub(:view).and_return(@view)
    @application = Brewby::Application.new adapter: :test, outputs: [@output], inputs: [{}, {hardware_id: '28-ba1c9d2e48'}]
  end
  
  it 'should have one output' do
    @application.outputs.size.should == 1
    @application.outputs.first.should be_instance_of Brewby::HeatingElement
    @application.outputs.first.adapter.should be_instance_of Brewby::Outputs::Test
  end

  it 'should have two inputs' do
    @application.inputs.size.should == 2
    @application.inputs.each do |input|
      input.should be_instance_of Brewby::Inputs::Test
    end
  end
  
  it 'should have one view' do
    @application.view.should be_instance_of Brewby::VirtualView
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
