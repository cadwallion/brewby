module Brewby
  module Views
    class Step
      attr_reader :step
      def initialize parent, step, application
        @step = step
        @parent = parent
        @application = application
      end

      def render
        @parent.clear do
          $app.flow do
            $app.subtitle @step.name, left: 0, top: 0

            @mode = $app.para "Mode:", left: 0, top: 50

            @target = $app.para "", left: 0, top: 75
            @countdown = $app.para "", left: 0, top: 150

            @actual = $app.para "Actual: #{@step.last_reading}F", left: 0, top: 100
            $app.flow do
              @power_output_progress = $app.progress left: 0, top: 115
              @power_output_progress.fraction = 0.5
              @power_output = $app.para "Power Output: 0.0%", left: 0, top: 130
            end

            if @application.next_step
              @next_step = $app.button "Next Step", left: 550, top: 300
              @next_step.click do
                start_next_step
              end
            end

            if @step.mode == :manual
              increase_power = $app.button "+5% Power", left: 500, top: 150
              increase_power.click do
                new_pct = [(@step.power_level + 0.05).round(2), 1.0].min
                @step.set_power_level new_pct
              end

              decrease_power = $app.button "-5% Power", left: 500, top: 175
              decrease_power.click do
                new_pct = [(@step.power_level - 0.05).round(2), 0.0].max
                @step.set_power_level new_pct
              end
            end
          end
        end
      end

      def start_next_step
        next_step = @application.next_step
        @application.current_step.stop_timer
        @application.start_step(next_step)
        $subview = Brewby::Views::Step.new @parent, next_step, @application
        $subview.render
      end

      def update_scene
        @mode.replace "Mode: #{@step.mode}"
        @target.replace "Target: #{@step.target}F"
        @actual.replace "Actual: #{@step.last_reading}F"

        @power_output.replace "Power Output: #{(@step.power_level * 100.0).round(3)}%"
        @power_output_progress.fraction = @step.power_level

        if @step.threshold_reached
          @countdown.replace "Time Remaining: #{@step.countdown_for(@step.time_remaining)}"
        end
      end
    end
  end
end
