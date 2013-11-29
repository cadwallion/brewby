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
          render_recipe_list
          render_recipe_steps
        end
      end

      def render_recipe_list
        $app.stack width: 0.5, height: 1.0, margin_left: 10 do
          $app.stack width: 1.0, height: 25 do
            $app.tagline "Select Recipe:"
          end
          $app.stack width: 0.75, height: 0.75 do
            $app.border $app.black, strokewidth: 2
            $app.para @application.name, left: 15, top: 5
          end
        end
      end

      def render_recipe_steps
        $app.stack width: 0.5, height: 1.0 do
          $app.stack width: 1.0, height: 25 do
            $app.tagline "Recipe Steps:" 
          end
          $app.stack width: 0.9, height: 0.75, margin_left: 10, margin_top: 5 do
            $app.border $app.black, strokewidth: 2
            @application.steps.each do |step|
              $app.caption step.name
              if step.mode == :auto
                $app.caption "   Target: #{step.target}F, Hold Duration: #{step.countdown_for(step.duration * 60)}"
              else
                $app.caption "   Manual Power Control, No Duration"
              end
            end
          end

          start = $app.button "Start Brew"
          start.click do
            start_recipe
          end
        end
      end

      def start_recipe
        @application.start_timer
        first_step = @application.steps.first
        @application.start_step(first_step)
        $subview = Brewby::Views::Step.new @parent, first_step
        $subview.render
      end

      def update_scene
        # no-op, static view
      end
    end
  end
end
