require 'brewby/views/recipe_overview'

module Brewby
  module Views
    class Application
      def initialize(context, application)
        @application = application
        @context = context
        $app = @context
      end

      def render
        render_frame
        render_recipe_overview

        @context.animate(60) do
          if @application.started?
            @application.tick
            update_brew_timer
            update_step_timer
            update_subview
          end
        end
      end

      def render_frame
        @frame_stack = @context.flow width: 640, height: 480 do
          @top_stack = @context.flow width: 640, height: 50 do
            @context.background @context.gray
            quit = @context.button "QUIT", left: 570, top: 5
            quit.click do
              exit
            end

            @context.title "Brewby: #{@application.name}"
          end

          @step_stack = @context.flow width: 640, height: 380

          @bottom_stack = @context.flow width: 640, height: 50 do
            @context.background @context.gray
          end
        end
      end

      def render_recipe_overview
        $subview = Brewby::Views::RecipeOverview.new(@step_stack, @application)
        $subview.render
      end

      def update_brew_timer
        unless @brew_timer
          @bottom_stack.append do
            @brew_timer = @context.caption "", top: 15
          end
        end

        @brew_timer.replace "Brew Timer: #{@application.brew_time}"
      end

      def update_step_timer
        unless @step_timer
          @bottom_stack.append do
            @step_timer = @context.caption "", top: 15, left: 450
          end
        end

        @step_timer.replace "Step Timer: #{@application.current_step.brew_time}"
      end

      def update_subview
        $subview.update_scene
      end
    end
  end
end
