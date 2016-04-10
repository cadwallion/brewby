require 'spec_helper'

describe Brewby::HeatingElement do
  def millis_from_now i
    (Time.now.to_i + i) * 1000
  end

  before do
    adapter = Brewby::Outputs::Test.new
    @element = Brewby::HeatingElement.new(adapter, pulse_range: 5000)
    @element.pulse_width = 3000
  end

  describe 'relay pulsing' do
    it 'turn on the relay when first pulsed' do
      expect(@element.off?).to be true
      @element.pulse
      expect(@element.off?).to be false
    end

    it 'turns on the relay while within pulse width' do
      expect(@element.off?).to be true
      @element.instance_variable_set(:@pulse_range_end, millis_from_now(4))
      @element.pulse
      expect(@element.on?).to be true
    end

    it 'turns off the relay when time exceeds pulse width' do
      @element.instance_variable_set(:@pulse_range_end, millis_from_now(5))
      @element.pulse
      expect(@element.on?).to be true
      @element.instance_variable_set(:@pulse_range_end, millis_from_now(1))
      @element.pulse
      expect(@element.off?).to be true
    end

    it 'turns on the relay when time hits the next pulse range' do
      expect(@element.off?).to be true
      @element.instance_variable_set(:@pulse_range_end, millis_from_now(-1))
      @element.pulse
      expect(@element.on?).to be true
    end
  end
end
