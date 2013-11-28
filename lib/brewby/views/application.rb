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
            update_next_step
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
            $app.flow do
              @brew_timer = @context.caption "", top: 15, left: 15
              @step_timer = @context.caption "", top: 15, left: 250

              @next_step = $app.button "Next Step", top: 10, left: 530
              @next_step.click do
                start_next_step
              end
            end
            @next_step.hide
          end
        end
      end

      def start_next_step
        step = @application.next_step
        @application.current_step.stop_timer
        @application.start_step(step)
        $subview = Brewby::Views::Step.new @parent, step
        $subview.render
      end

      def render_recipe_overview
        $subview = Brewby::Views::RecipeOverview.new(@step_stack, @application)
        $subview.render
      end

      def update_brew_timer
        @brew_timer.replace "Brew Timer: #{@application.brew_time}"
      end

      def update_step_timer
        @step_timer.replace "Step Timer: #{@application.current_step.brew_time}"
      end

      def update_next_step
        if @application.started? && @application.next_step
          @next_step.show
        else
          @next_step.hide
        end
      end

      def update_subview
        $subview.update_scene
      end
    end
  end
end
