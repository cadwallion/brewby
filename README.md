# Brewby - Brewery Automation with Ruby

Brewby is a brewery automation library designed to break the steps of the brewing process into isolated,
automated components, giving the brewer the opportunity to focus on recipe creation and achieve a more
consistent finished product.  To accomplish this, Brewby is broken up into three separate components:

* The equipment profile, a config file that defines the IO adapters
* The recipe file, a per-recipe file that uses Brewby's DSL to define process steps
* The executable, which maps the equipment to the recipe and guides the user through the steps

# Recipes

Brewby uses its recipe DSL to easily describe the steps in a brew day, and easily map to one's equipment
profile.  Take for example this Blonde Ale recipe:

``` ruby

recipe "Blonde Ale" do
  step "Heat strike water" do
    type :temp_control
    mode :auto
    target 163.9 # *F, sorry rest of the world. :(
    input :hot_liquor_tank
    output :hot_liquor_tank
  end

  step "Infusion Mash" do
    type :temp_control
    mode :auto
    target :148.0
    duration 60 # minutes
    input :mash_tun
    output :hot_liquor_tank
  end

  step "Fly Sparge" do
    type :temp_control, mode: :auto, target: 165.0, duration: 45
    input :hot_liquor_tank
    output :hot_liquor_tank
  end

  step "Boil" do
    type :temp_control
    mode :manual
    power_level 0.75
    input :boil_kettle
    output :boil_kettle
  end
end
```

Here we see our recipe consists of four steps: Heat strike water, Infusion Mash, Fly Sparge, and Boil.
Each step uses the `type` keyword to specify the type of control desired.  This step type is registered with
Brewby on startup, and can takes an options hash of configurations or use the DSL to define them.  For 
more information on Steps and the TempControl step, see [Steps](#).  Note the `input` and `output` keywords:
these map the names of input and output adapters defined in one's Equipment Profile. 

# Equipment Profile

The equipment profile is the configuration file that customizes Brewby to specific brewery equipment.  This
configuration file, which typically lives at `~/.brewbyrc`, details all of the inputs and outputs and their
adapter configurations.  Brewby comes with several IO adapters, and can have more custom adapters registered
on startup.  On startup, Brewby instantiates an instance of the IO adapters listed in the Equipment Profile.
When a Recipe step calls for a specific IO adapter, it references the adapter for manipulation.

Here is an example of an eHERMS system that uses GPIO for outputs and DS18B20 with 1wire protocol for inputs:

```
{
  "inputs":[
    { "name":"mash_tun", "adapter":"ds18b20", "hardware_id":"28-12345" },
    { "name":"hot_liquor_tank", "adapter":"ds18b20", "hardware_id":"28-67891" },
    { "name":"boil_kettle",  "adapter":"ds18b20", "hardware_id":"28-01983" }
  ],
  "outputs":[
    { "name":"hot_liquor_tank", "adapter":"gpio", "pin":17 },
    { "name":"boil_kettle", "adapter":"gpio", "pin":19 }
  ]
}
```

Brewby uses the `name` and `adapter` values to lookup the class and store for access in recipes, and all 
other keys are passed to the adapter's constructor.
