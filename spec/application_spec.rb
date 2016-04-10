require 'spec_helper'

describe Brewby::Application do
  before do
    @outputs = [{
      pin: 1,
      pulse_range: 5000,
      adapter: :test
    }]

    @inputs = [
      { adapter: :test },
      { adapter: :test, hardware_id: '28-ba1c9d2e48' }
    ]

    @application = Brewby::Application.new outputs: @outputs, inputs: @inputs
  end

  it 'should have one output' do
    expect(@application.outputs.size).to eql 1
  end

  it "should have a heating element output" do
    expect(@application.outputs.first).to be_instance_of Brewby::HeatingElement
  end

  it "should have a test adapter for the heating element" do
    expect(@application.outputs.first.adapter).to be_instance_of Brewby::Outputs::Test
  end

  it 'should have two inputs' do
    expect(@application.inputs.size).to eql 2
  end

  it "should have inputs of type test" do
    @application.inputs.each do |input|
      expect(input).to be_instance_of Brewby::Inputs::Test
    end
  end


  context 'adding steps' do
    before do
      @application.add_step :temp_control, mode: :auto, target: 155.0, duration: 15
      @step = @application.steps.first
    end

    it 'creates a step object with passed configuration options' do
      expect(@step).to be_instance_of Brewby::Steps::TempControl
    end

    it 'passes an input to the step' do
      expect(@step.input).to eql @application.inputs.first
    end

    it "passes an output to the step" do
      expect(@step.output).to eql @application.outputs.first
    end

    it 'allows the step to specify the input/output objects to use' do
      @application.add_step :temp_control, mode: :auto, target: 155.0, duration: 15, input: @application.inputs.last
      @step = @application.steps.last
      expect(@step.input).to eql @application.inputs.last
    end
  end
end
