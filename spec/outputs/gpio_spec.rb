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
      data.should == '1'
    end

    it 'initializes the GPIO pin direction' do
      Brewby::Outputs::GPIO.new pin: 1, gpio_path: @gpio_dir
      data = File.read "#{@gpio_dir}/gpio1/direction"
      data.should == 'out'
    end

    it 'does not initialize the GPIO pin if already initialized' do
      File.write "#{@gpio_dir}/gpio1/value", ""
      Brewby::Outputs::GPIO.new pin: 1, gpio_path: @gpio_dir
      data = File.read "#{@gpio_dir}/export"
      data.should == ''
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
      pin_value.should == '1'
    end

    it 'sets the pin value to 0 when off' do
      @output.off
      pin_value.should == '0'
    end

    it 'returns false when off' do
      @output.should_not be_on
    end

    it 'returns true when on' do
      @output.on
      @output.should be_on
    end
  end
end
