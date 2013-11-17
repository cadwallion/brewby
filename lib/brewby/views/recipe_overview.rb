require 'brewby/views/step'

module Brewby
  module Views
    class RecipeOverview
      def initialize parent, application
        @parent = parent
        @application = application
      end

      def render
        @parent.clear do
          $app.flow width: "50%" do
            @application.steps.each do |step|
              $app.caption step.name
            end
          end

          $app.flow width: "50%" do
            start = $app.button "Start Brew"
            start.click do
              start_recipe
            end
          end
        end
      end

      def start_recipe
        @application.start_timer
        first_step = @application.steps.first
        @application.start_step(first_step)
        $subview = Brewby::Views::Step.new @parent, first_step, @application
        $subview.render
      end

      def update_scene
        # no-op, static view
      end
    end
  end
end
