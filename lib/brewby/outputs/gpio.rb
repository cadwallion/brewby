module Brewby
  module Outputs
    class GPIO
      attr_reader :gpio_path, :pin
      def initialize options = {}
        @pin = options[:pin]
        @gpio_path = options[:gpio_path] || '/sys/class/gpio'

        initialize_gpio_pin
        initialize_gpio_direction
      end

      def initialize_gpio_pin
        unless File.exists? File.join(gpio_path, "gpio#{pin}", "value")
          File.write File.join(gpio_path, "export"), pin
        end
      end

      def initialize_gpio_direction
        File.write File.join(gpio_path, "gpio#{pin}", "direction"), 'out'
      end

      def on
        write(1)
      end

      def off
        write(0)
      end

      def on?
        '1' == File.read(File.join(gpio_path, "gpio#{pin}", "value"))
      end

      def write value
        File.write File.join(gpio_path, "gpio#{pin}", "value"), value
      end
    end
  end
end
