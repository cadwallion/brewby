require 'brewby/cli/view'

module Brewby
  module CLI
    module Views
      class Application
        attr_reader :view, :step_view, :app
        def initialize app
          @app = app
          @view = load_parent_view
        end

        def load_parent_view
          Brewby::CLI::View.new
        end

        def current_step_index
          app.steps.index(app.current_step)+1
        end

        def step_count
          app.steps.size
        end

        def brew_timer
          app.timer_for(app.elapsed.to_i)
        end

        def render
          load_step_view app.current_step unless step_view
          view.move 1, 0
          view.addstr "BREWBY: Brewing '#{app.name}'" if app.name
          view.move 2, 0
          view.addstr "Step #{current_step_index}/#{step_count}: "
          view.move 16, 0
          view.addstr "Brew Timer: #{brew_timer}"
          view.refresh
          step_view.render
        end

        def handle_input
          if (char = view.getch) == 'q'[0].ord
            exit
          elsif char == 'n'[0].ord
            app.current_step.stop_timer
            app.ready = true
          else
            step_view.handle_input char
          end
        end

        def load_step_view step
          step_class_name = step.class.name.split("::").last
          @step_view = Brewby::CLI::Views.const_get(step_class_name).new step, view
        end
      end
    end
  end
end
