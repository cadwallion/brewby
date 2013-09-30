require 'brewby/adapters/raspberry_pi/output'
require 'brewby/adapters/raspberry_pi/ds18b20'

require 'brewby/adapters/test/output'
require 'brewby/adapters/test/input'

module Brewby
  class Application
    attr_reader :outputs, :inputs, :steps
    attr_accessor :adapter

    def initialize options = {}
      @options = options
      @steps = []
      @adapter = options[:adapter]
      configure_inputs
      configure_outputs
    end

    def configure_inputs
      @inputs = []

      @options[:inputs].each do |input_options|
        sensor = input_adapter_class.new input_options
        @inputs.push sensor
      end
    end

    def configure_outputs
      @outputs = []
      
      @options[:outputs].each do |output_options|
        adapter = output_adapter_class.new output_options
        element = Brewby::HeatingElement.new adapter, pulse_range: output_options[:pulse_range], name: output_options[:name]
        @outputs.push element
      end
    end

    def input_adapter_class
      case adapter
      when :test
        Brewby::Adapters::Test::Input
      else
        Brewby::Adapters::RaspberryPi::DS18B20
      end
    end

    def output_adapter_class
      case adapter
      when :test
        Brewby::Adapters::Test::Output
      else
        Brewby::Adapters::RaspberryPi::Output
      end
    end

    def add_step step_type, options = {}
      case step_type
      when :temp_control
        default_options = { input: @inputs.first, output: @outputs.first }
        step = Brewby::Steps::TempControl.new default_options.merge(options)
      end
      @steps.push step
    end

    def start
      @steps.each do |step|
        step.start_timer
        while step.in_progress? do
          step.step_iteration
          puts "Temp: #{step.last_reading} Output: #{step.power_level}"
          if step.threshold_reached
            if step.time_remaining > 60
              puts "Time Remaining: #{step.time_remaining / 60} minutes"
            else
              puts "Time Remaining: #{step.time_remaining} seconds"
            end
          end
          sleep 1
        end
      end
    end
  end
end
