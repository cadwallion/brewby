require 'spec_helper'

describe Brewby::CLI::Application do
  before do
    @output = {
      pin: 1,
      pulse_range: 5000
    }
    @view = Brewby::VirtualView.new
    Brewby::CLI::Views::Application.any_instance.stub(:load_parent_view).and_return(@view)
    @application = Brewby::CLI::Application.new adapter: :test, outputs: [@output], inputs: [{}]
  end

  context 'rendering' do
    before do
      @application.name = 'Awesome Ale'
      @application.add_step :temp_control, mode: :auto, mode: :auto, target: 155.0, duration: 15, input: @application.inputs.last
      @application.view.render
    end

    it 'renders the recipe name' do
      line = @view.readline(1).strip
      line.should == "BREWBY: Brewing 'Awesome Ale'"
    end

    it 'renders the step counter' do
      line = @view.readline(2).strip
      line.should == 'Step 1/1: Auto Temp Control'
    end

    it 'renders the brew timer' do
      line = @view.readline(16).strip
      line.should == 'Brew Timer: 00:00:00' + ''.ljust(30) + 'Step Timer: 00:00:00'
    end
  end

  context 'input handling' do
    it 'jumps to the next step when the n key is pressed' do
      @view.stub(:getch).and_return('n'.ord)
      @application.add_step :temp_control, mode: :auto, mode: :auto, target: 155.0, duration: 15, input: @application.inputs.last
      @application.start_step @application.steps.first
      @application.view.handle_input
      @application.current_step.should be_ended
    end
  end
end
