require 'brewby/inputs/ds18b20'
require 'brewby/inputs/test'

require 'brewby/outputs/test'
require 'brewby/outputs/gpio'

module Brewby
  class Application
    attr_reader :outputs, :inputs, :steps
    attr_accessor :adapter, :name

    def initialize options = {}
      @options = options
      @steps = []
      @adapter = options[:adapter].to_sym
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
        Brewby::Inputs::Test
      else
        Brewby::Inputs::DS18B20
      end
    end

    def output_adapter_class
      case adapter
      when :test
        Brewby::Outputs::Test
      else
        Brewby::Outputs::GPIO
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

    def load_recipe file
      Brewby::StepLoader.new(self).load_file file
    end

    def start
      puts "Starting Recipe '#{@name}'" if @name
      @steps.each do |step|
        puts "Beginning Step #{step.name}" if step.name
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

        input = ''
        while input != 'y'
          puts "Continue (y/N): "
          input = gets.chomp

          case input
          when 'N'
            break
          when 'y'
            puts "Proceeding to next step..."
          else
            puts "Invalid response."
          end
        end
      end
    end
  end
end
