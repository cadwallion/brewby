module Brewby
  module Adapters
    module RaspberryPi
      class Output
        GPIO_PATH = "/sys/class/gpio"

        def initialize options = {}
          @output_pin = options[:pin]
          initialize_gpio_pin
          initialize_gpio_direction
        end

        def initialize_gpio_pin
          unless File.exists? File.join(GPIO_PATH, "gpio#{@output_pin}", "value")
            File.write File.join(GPIO_PATH, "export"), @output_pin
          end
        end

        def initialize_gpio_direction
          File.write File.join(GPIO_PATH, "gpio#{@output_pin}", "direction"), 'out'
        end

        def on
          write(1)
        end

        def off
          write(0)
        end

        def on?
          '1' == File.read(File.join(GPIO_PATH, "gpio#{@output_pin}", "value"))
        end

        def write value
          File.write File.join(GPIO_PATH, "gpio#{@output_pin}", "value"), value
        end
      end
    end
  end
end
