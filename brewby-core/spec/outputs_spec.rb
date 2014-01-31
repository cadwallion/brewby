require 'spec_helper'

describe Brewby::Outputs do
  it 'determines output class based on adapter' do
    Brewby::Outputs.adapter_class(:test).should == Brewby::Outputs::Test
    Brewby::Outputs.adapter_class(:raspberry_pi).should == Brewby::Outputs::GPIO
  end
end
