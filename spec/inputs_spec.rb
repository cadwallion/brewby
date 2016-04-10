require 'spec_helper'

describe Brewby::Inputs do
  it "returns the DS18B20 as default sensor type for RPi" do
    input_class = Brewby::Inputs.adapter_class(:raspberry_pi)
    expect(input_class).to be Brewby::Inputs::DS18B20
  end

  it "returns the test sensor for test mode" do
    input_class = Brewby::Inputs.adapter_class(:test)
    expect(input_class).to be Brewby::Inputs::Test
  end
end
