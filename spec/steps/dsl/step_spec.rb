require 'spec_helper'

class FakeApp
  attr_accessor :steps

  def inputs
    [
      { name: :bk },
      { name: :hlt },
      { name: :mlt }
    ]
  end

  def outputs
    [
      { name: :bk },
      { name: :hlt },
      { name: :mlt }
    ]
  end
end

describe Brewby::Steps::DSL::Step do
  before do
    @application = FakeApp.new
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
end
