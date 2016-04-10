require 'spec_helper'

describe Brewby::Outputs do
  it "defaults output class to GPIO" do
    output_class = Brewby::Outputs.adapter_class :default
    expect(output_class).to be Brewby::Outputs::GPIO
  end

  it "outputs the RPi to GPIO" do
    output_class = (Brewby::Outputs.adapter_class(:raspberry_pi))
    expect(output_class).to be Brewby::Outputs::GPIO
  end

  it "outputs the test output class when running test" do
    output_class = Brewby::Outputs.adapter_class(:test)
    expect(output_class).to be Brewby::Outputs::Test
  end
end
