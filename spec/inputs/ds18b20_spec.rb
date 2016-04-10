require 'spec_helper'

describe Brewby::Inputs::DS18B20 do
  it 'accepts a hardware_id' do
    sensor = Brewby::Inputs::DS18B20.new hardware_id: 'something'
    expect(sensor.hardware_id).to eql 'something'
  end

  it 'picks the first hardware_id it finds when no hardware_id is specified' do
    Dir.mktmpdir do |dir|
      File.write "#{dir}/28-12345", "1"
      sensor = Brewby::Inputs::DS18B20.new device_path: dir
      expect(sensor.hardware_id).to eql '28-12345'
    end
  end

  context 'reading sensor data' do
    before do
      @sensor = Brewby::Inputs::DS18B20.new device_path: @device_dir, hardware_id: '28-12345'
      allow(@sensor).to receive(:read_raw) { "f5 00 4b 46 7f ff 0b 10 d7 : crc=d7 YES\nf5 00 4b 46 7f ff 0b 10 d7 t=15312" }
    end

    it 'reads the temperaturee and returns it in fahrenheit' do
      input = @sensor.read
      expect(input).to eql 59.562
    end

    it 'parses the raw data to celsius' do
      tempC = @sensor.parse @sensor.read_raw
      expect(tempC).to eql 15.312
    end

    it 'returns nil when an error occurs when parsing' do
      allow(@sensor).to receive(:read_raw) { "f5 00 4b 46 7f ff 0b 10 d7 : crc=d7 NO\nf5 00 4b 46 7f ff 0b 10 d7" }
      input = @sensor.read
      expect(input).to be nil
    end
  end
end
