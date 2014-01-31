$: << File.join(File.dirname(__FILE__), '..', 'lib')
require 'brewby'

class RecipeLoader < Brewby::Application
  def tick
    super
    render_status
  end

  def render_status
    @last_output ||= Time.now
    if @last_output < (Time.now - 1)
      puts "Target: #{current_step.target}F\tActual: #{current_step.last_reading}F\tPower Level: #{current_step.power_level * 100}%"
      @last_output = Time.now
    end
  end
end

app = RecipeLoader.new({
  adapter: 'test', 
  inputs: [{ name: 'hlt' }, { name: 'bk' }], 
  outputs: [{ name: 'hlt' }, { name: 'bk' }]
})

file = ARGV[0] || "examples/brewby_recipe.rb"
puts "Loading Recipe #{file}"
app.load_recipe File.expand_path(file)
app.start
