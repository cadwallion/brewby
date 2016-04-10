require 'spec_helper'

describe Brewby::Outputs::GPIO do
  before do
    @gpio_dir = Dir.mktmpdir
    Dir.mkdir "#{@gpio_dir}/gpio1"
    File.write "#{@gpio_dir}/export", ""
    File.write "#{@gpio_dir}/gpio1/direction", ""
  end

  after do
    FileUtils.remove_entry @gpio_dir
  end

  context 'GPIO initialization' do
    it 'initializes the GPIO pin via export' do
      Brewby::Outputs::GPIO.new pin: 1, gpio_path: @gpio_dir
      data = File.read "#{@gpio_dir}/export"
      expect(data).to eql '1'
    end

    it 'initializes the GPIO pin direction' do
      Brewby::Outputs::GPIO.new pin: 1, gpio_path: @gpio_dir
      data = File.read "#{@gpio_dir}/gpio1/direction"
      expect(data).to eql 'out'
    end

    it 'does not initialize the GPIO pin if already initialized' do
      File.write "#{@gpio_dir}/gpio1/value", ""
      Brewby::Outputs::GPIO.new pin: 1, gpio_path: @gpio_dir
      data = File.read "#{@gpio_dir}/export"
      expect(data).to eql ''
    end
  end

  context 'output' do
    before do
      @output = Brewby::Outputs::GPIO.new pin: 1, gpio_path: @gpio_dir
      File.write "#{@gpio_dir}/gpio1/value", ""
    end

    def pin_value
      File.read "#{@gpio_dir}/gpio1/value"
    end

    it 'sets the pin value to 1 when on' do
      @output.on
      expect(pin_value).to eql '1'
    end

    it 'sets the pin value to 0 when off' do
      @output.off
      expect(pin_value).to eql '0'
    end

    it 'returns false when off' do
      expect(@output.on?).to be false
    end

    it 'returns true when on' do
      @output.on
      expect(@output.on?).to be true
    end
  end
end
