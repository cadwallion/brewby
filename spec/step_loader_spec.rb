require 'spec_helper'

describe Brewby::StepLoader do
  before do
    Brewby::Application.any_instance.stub(:render)
    Brewby::Application.any_instance.stub(:configure_view)

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
    @application.should have(4).steps
  end
end
