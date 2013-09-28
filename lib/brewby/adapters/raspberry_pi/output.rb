module Brewby
  module Adapters
    module RaspberryPi
      class Output
        def initialize options = {}
          @output_pin = options[:pin]
          initialize_gpio_pin
          initialize_gpio_direction
        end

        def initialize_gpio_pin
          IO.popen "echo #{@output_pin} > /sys/class/gpio/export"
        end

        def initialize_gpio_direction
          IO.popen "echo 'out' > /sys/class/gpio/gpio#{@output_pin}/direction"
        end

        def on
          write(1)
        end

        def off
          write(0)
        end

        def on?
          '1' == File.read("/sys/class/gpio/gpio#{@output_pin}/value")
        end

        def write value
          `echo #{value} > /sys/class/gpio/gpio#{@output_pin}/value`
        end
      end
    end
  end
end
