module Brewby
  module Steps
    module DSL
      class Step
        attr_reader :step_class, :options
        def initialize name, application
          @application = application
          @options = {}
          @options[:name] = name
        end

        def type symbol, options = {}
          @step_class = case symbol
          when :temp_control
            Brewby::Steps::TempControl
          end
          @options.merge!(options)
        end

        def mode m
          @options[:mode] = m
        end

        def target t
          @options[:target] = t
        end

        def hold_duration d
          @options[:duration] = d
        end

        def input i
          @options[:input] = i
        end

        def output o
          @options[:output] = o
        end

        def create!
          @options[:input] = @application.inputs.find { |i| i.name }
          @options[:output] = @application.outputs.find { |o| o.name }
          @step_class.new @options
        end
      end
    end
  end
end
