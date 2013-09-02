require 'spec_helper'

describe Brewby::HeatingElement do
  before do
    @element = Brewby::HeatingElement.new(1, pulse_range: 5000)
    @element.pulse_width = 3000
  end

  describe 'relay pulsing' do
    it 'turn on the relay when first pulsed' do
      @element.should be_off
      @element.pulse
      @element.should be_on
    end

    it 'turns on the relay while within pulse range' do
      @element.should be_off
      @element.instance_variable_set(:@pulse_range_start, (Time.now - 1).to_i)
      @element.pulse
      @element.should be_on
    end

    it 'turns off the relay when time exceeds pulse range' do
      @element.instance_variable_set(:@pulse_range_start, (Time.now - 1).to_i)
      @element.pulse
      @element.should be_on
      @element.instance_variable_set(:@pulse_range_start, (Time.now - 4).to_i)
      @element.pulse
      @element.should be_off
    end
    
    it 'turns on the relay when time hits the next pulse range' do
      @element.should be_off
      @element.instance_variable_set(:@pulse_range_start, (Time.now - 6).to_i)
      @element.pulse
      @element.should be_on
    end
  end
end
