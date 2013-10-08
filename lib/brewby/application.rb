require 'brewby/inputs'
require 'brewby/outputs'
require 'brewby/view'

module Brewby
  class Application
    attr_reader :outputs, :inputs, :steps, :view
    attr_accessor :adapter, :name

    include Brewby::Timed

    def initialize options = {}
      @options = options
      @steps = []
      @adapter = options[:adapter].to_sym
      configure_inputs
      configure_outputs
      configure_view
      @ready = false
    end

    def configure_inputs
      @inputs = []

      @options[:inputs].each do |input_options|
        sensor = Brewby::Inputs.adapter_class(@adapter).new input_options
        @inputs.push sensor
      end
    end

    def configure_outputs
      @outputs = []
      
      @options[:outputs].each do |output_options|
        output_adapter = Brewby::Outputs.adapter_class(@adapter).new output_options
        element = Brewby::HeatingElement.new output_adapter, pulse_range: output_options[:pulse_range], name: output_options[:name]
        @outputs.push element
      end
    end

    def configure_view
      @view = Brewby::View.new
    end

    def add_step step_type, options = {}
      case step_type
      when :temp_control
        default_options = { input: @inputs.first, output: @outputs.first }
        step = Brewby::Steps::TempControl.new default_options.merge(options)
      end
      @steps.push step
    end

    def load_recipe file
      Brewby::StepLoader.new(self).load_file file
    end

    def start
      start_timer
      @steps.each do |step|
        start_step step
        until ready_for_next_step?
          tick 
        end
        @ready = false
      end
    ensure
      view.clear if view
    end

    def ready_for_next_step?
      @ready
    end

    def tick
      current_step.step_iteration
      render
      handle_input
    end

    def start_step step
      @current_step = step
      step.start_timer
    end

    def handle_input
      if (char = view.getch) == 'q'[0].ord
        exit
      elsif char == 'n'[0].ord
        @current_step.stop_timer
        @ready = true
      else
        @current_step.handle_input char
      end
    end

    def render
      view.move 1, 0
      view.addstr "BREWBY: Brewing '#{@name}'" if @name
      view.move 2, 0
      view.addstr "Step #{@steps.index(current_step)+1}/#{@steps.size}: "
      view.move 16, 0
      view.addstr "Brew Timer: #{timer_for(elapsed.to_i)}"
      view.refresh
      current_step.render(view)
    end

    def current_step
      @current_step || @steps[0]
    end
  end
end
