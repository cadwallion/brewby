require 'spec_helper'

describe Brewby::StepLoader do
  before do
    @application = Brewby::Application.new adapter: :test, 
      outputs: [{ pin: 1, name: :hlt }, { pin: 2, name: :mlt }, { pin: 3, name: :bk }], 
      inputs: [{ name: :hlt}, { name: :mlt }, { name: :bk }]
    @loader = Brewby::StepLoader.new @application
  end

  it 'reads a Brewby process file' do
    @loader.load_file File.join(File.dirname(__FILE__), 'support', 'sample_recipe.rb')
    @application.should have(4).steps
    @application.steps[0].name.should == 'Strike Water'
  end
end
