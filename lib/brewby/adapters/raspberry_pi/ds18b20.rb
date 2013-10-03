module Brewby
  module Adapters
    module RaspberryPi
      class DS18B20
        attr_accessor :name, :hardware_id, :device_path
        def initialize options = {}
          @name = options[:name]
          @device_path = options[:device_path] || "/sys/bus/w1/devices"
          @hardware_id = options[:hardware_id] || find_hardware_id
        end

        def find_hardware_id
          w1_devices[0].gsub("#{device_path}/",'')
        end

        def w1_devices
          Dir["#{device_path}/28*"]
        end

        def read
          raw = read_raw

          if tempC = parse(raw)
            tempF = to_fahrenheit tempC
          else
            tempC
          end
        end

        def parse raw_data
          if temp_data = raw_data.match(/t=([0-9]+)/)
            temp_data[1].to_f / 1000
          else
            nil
          end
        end

        def to_fahrenheit temp
          ((temp * 1.8) + 32).round(3)
        end

        def read_raw
          File.read device_file
        end

        def device_file
          "/sys/bus/w1/devices/#{@hardware_id}/w1_slave"
        end
      end
    end
  end
end

