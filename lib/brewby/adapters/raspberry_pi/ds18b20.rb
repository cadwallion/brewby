module Brewby
  module Adapters
    module RaspberryPi
      class DS18B20
        def initialize options = {}
          @hardware_id = options[:hardware_id] || find_hardware_id
        end

        def find_hardware_id
          Dir['/sys/bus/w1/devices/28*'][0].gsub('/sys/bus/w1/devices/','')
        end

        def read
          raw = read_raw
          tempC = raw.match(/t=([0-9]+)/)[1].to_i / 1000
          tempF = ((tempC * 1.8) + 32).round(3)

          tempF
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

