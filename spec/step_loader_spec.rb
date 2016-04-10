require 'spec_helper'

describe Brewby::StepLoader do
  before do
    outputs = [
      { adapter: :test, pin: 1, name: :hlt },
      { adapter: :test, pin: 2, name: :mlt },
      { adapter: :test, pin: 3, name: :bk }
    ]
    inputs = [
      { adapter: :test, name: :hlt},
      { adapter: :test, name: :mlt },
      { adapter: :test, name: :bk }
    ]

    @application = Brewby::Application.new outputs: outputs, inputs: inputs
    @loader = Brewby::StepLoader.new @application
  end

  it 'reads a Brewby process file' do
    @loader.load_file File.join(File.dirname(__FILE__), 'support', 'sample_recipe.rb')
    expect(@application.steps.length).to eql 4
  end
end
