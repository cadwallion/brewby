require 'spec_helper'

describe Brewby::Adapters::RaspberryPi::DS18B20 do
  it 'accepts a hardware_id' do
    sensor = Brewby::Adapters::RaspberryPi::DS18B20.new hardware_id: 'something'
    sensor.hardware_id.should == 'something'
  end

  it 'picks the first hardware_id it finds when no hardware_id is specified' do
    Dir.mktmpdir do |dir|
      File.write "#{dir}/28-12345", "1"
      sensor = Brewby::Adapters::RaspberryPi::DS18B20.new device_path: dir
      sensor.hardware_id.should == '28-12345'
    end
  end

  context 'reading sensor data' do
    before do
      Brewby::Adapters::RaspberryPi::DS18B20.any_instance.stub(:read_raw) { "f5 00 4b 46 7f ff 0b 10 d7 : crc=d7 YES\nf5 00 4b 46 7f ff 0b 10 d7 t=15312" }
      @sensor = Brewby::Adapters::RaspberryPi::DS18B20.new device_path: @device_dir, hardware_id: '28-12345'
    end

    it 'reads the temperaturee and returns it in fahrenheit' do
      input = @sensor.read
      input.should == 59.562
    end

    it 'parses the raw data to celsius' do
      tempC = @sensor.parse @sensor.read_raw
      tempC.should == 15.312
    end
  end
end
