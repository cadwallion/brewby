require 'spec_helper'

describe Brewby::Inputs do
  it 'determines input class based on adapter' do
    Brewby::Inputs.adapter_class(:test).should == Brewby::Inputs::Test
    Brewby::Inputs.adapter_class(:raspberry_pi).should == Brewby::Inputs::DS18B20
  end
end
