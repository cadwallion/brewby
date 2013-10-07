recipe 'Honey Ale' do
  step 'Strike Water' do
    type :temp_control
    mode :auto
    target 168.0
    hold_duration 5
    input :hlt
    output :hlt
  end

  step 'Infusion Mash Step' do
    type :temp_control
    mode :auto
    target 150.0
    hold_duration 60
    input :mlt
    output :hlt
  end

  step 'Fly Sparge' do
    type :temp_control
    mode :auto
    target 168.0
    hold_duration 45
    input :hlt
    output :hlt
  end

  step 'Boil' do
    type :temp_control
    mode :manual
    input :bk
    output :bk
  end
end
