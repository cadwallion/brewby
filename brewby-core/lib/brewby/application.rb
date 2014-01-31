require 'brewby/inputs'
require 'brewby/outputs'

module Brewby
  class Application
    attr_reader :outputs, :inputs, :steps
    attr_accessor :adapter, :name

    include Brewby::Timed

    def initialize options = {}
      @options = options
      @steps = []
      @adapter = options[:adapter].to_sym
      configure_inputs
      configure_outputs
      @ready = false
    end

    def configure_inputs
      @inputs = []

      @options[:inputs].each do |input_options|
        add_input @adapter, input_options
      end
    end

    def add_input adapter, options = {}
      sensor = Brewby::Inputs.adapter_class(adapter).new options
      @inputs.push sensor
    end

    def configure_outputs
      @outputs = []
      
      @options[:outputs].each do |output_options|
        add_output @adapter, output_options
      end
    end

    def add_output adapter, options = {}
      output_adapter = Brewby::Outputs.adapter_class(adapter).new options
      element = Brewby::HeatingElement.new output_adapter, pulse_range: options[:pulse_range], name: options[:name]
      @outputs.push element
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
    end

    def ready_for_next_step?
      @ready
    end

    def tick
      current_step.step_iteration
    end

    def start_step step
      @current_step = step
      step.start_timer
    end

    def current_step
      @current_step || @steps[0]
    end
  end
end
