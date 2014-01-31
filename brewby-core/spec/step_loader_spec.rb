require 'spec_helper'

describe Brewby::StepLoader do
  before do
    Brewby::Application.any_instance.stub(:render)
    Brewby::Application.any_instance.stub(:configure_view)

    @application = Brewby::Application.new adapter: :test, 
      outputs: [{ pin: 1, name: :hlt }, { pin: 2, name: :mlt }, { pin: 3, name: :bk }], 
      inputs: [{ name: :hlt}, { name: :mlt }, { name: :bk }]
    @loader = Brewby::StepLoader.new @application
  end

  it 'reads a Brewby process file' do
    @loader.load_file File.join(File.dirname(__FILE__), 'support', 'sample_recipe.rb')
    @application.should have(4).steps
  end
end
