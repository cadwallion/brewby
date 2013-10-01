module Brewby
  class StepLoader
    def initialize application
      @application = application
    end

    def load_file file
      instance_eval File.read(file), file
    end

    def recipe name, &block
      @application.name = name
      yield self
    end

    def step name, &block
      step = generate_step name, &block
      @application.steps.push step
    end

    def generate_step name, &block
      step_generator = Brewby::Steps::DSL::Step.new name, @application
      step_generator.instance_eval &block
      step_generator.create!
    end
  end
end
