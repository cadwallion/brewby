require 'spec_helper'

describe Brewby::Steps::DSL::Step do
  before do
    @outputs = [
      { adapter: :test, name: :hlt, pin: 3 },
      { adapter: :test, name: :mlt, pin: 2 },
      { adapter: :test, name: :bk, pin: 1 }
    ]

    @inputs = [
      { adapter: :test, name: :bk },
      { adapter: :test, name: :mlt },
      { adapter: :test, name: :hlt }
    ]

    Brewby::Application.any_instance.stub(:render)
    Brewby::Application.any_instance.stub(:configure_view)
    @application = Brewby::Application.new outputs: @outputs, inputs: @inputs
    @step = Brewby::Steps::DSL::Step.new 'Test Step', @application
  end

  it 'accepts a type' do
    @step.type :temp_control
    @step.step_class.should == Brewby::Steps::TempControl
  end

  it 'accepts options on the type' do
    @step.type :temp_control, mode: :auto, target: 155.0, duration: 60
    @step.options[:mode].should == :auto
    @step.options[:target].should == 155.0
    @step.options[:duration].should == 60
  end

  it 'accepts a mode' do
    @step.mode :manual
    @step.options[:mode].should == :manual
  end

  it 'accepts a target' do
    @step.target 155.0
    @step.options[:target].should == 155.0
  end

  context 'creation' do
    before do
      @step.type :temp_control, mode: :manual, power_level: 1.0
      @step.input :mlt
      @step.output :bk
      @created_step = @step.create!
    end

    it 'should translate the input correctly' do
      @created_step.input.name.should == :mlt
    end

    it 'should translate the output correctly' do
      @created_step.output.name.should == :bk
    end
  end
end
