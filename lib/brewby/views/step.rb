module Brewby
  module Views
    class Step
      attr_reader :step
      def initialize parent, step
        @step = step
        @parent = parent
      end

      def render
        @parent.clear do
          $app.flow do
            $app.subtitle @step.name, left: 0, top: 0

            $app.rect width: 350, height: 250, left: 15, top: 100
            @mode = $app.para "", left: 400, top: 75
            @target = $app.para "", left: 400, top: 75
            @actual = $app.para "", left: 400, top: 100
            @countdown = $app.para "", left: 400, top: 230
            @duration = $app.para "", left: 400, top: 215

            $app.flow do
              @power_output_progress = $app.progress left: 400, top: 175
              @power_output_progress.fraction = 0.5
              @power_output = $app.para "Power Output: 0.0%", left: 400, top: 190
            end

            if @step.mode == :manual
              increase_power = $app.button "+5% Power", left: 400, top: 300
              increase_power.click do
                new_pct = [(@step.power_level + 0.05).round(2), 1.0].min
                @step.set_power_level new_pct
              end

              decrease_power = $app.button "-5% Power", left: 500, top: 300
              decrease_power.click do
                new_pct = [(@step.power_level - 0.05).round(2), 0.0].max
                @step.set_power_level new_pct
              end
            end
          end
        end
      end

      def update_scene
        if @step.mode == :auto
          @target.replace "Target Temperature: #{@step.target}F"
          @mode.replace ""
          @duration.replace "Hold Duration: #{@step.countdown_for(@step.duration * 60)}"
        else
          @mode.replace "Manual Power Control"
          @target.replace ""
          @duration.replace ""
        end

        @actual.replace "Current Temperature: #{@step.last_reading}F"

        @power_output.replace "Power Output: #{(@step.power_level * 100.0).round(3)}%"
        @power_output_progress.fraction = @step.power_level

        if @step.threshold_reached
          @countdown.replace "Hold Duration Remaining: #{@step.countdown_for(@step.time_remaining)}"
        end
      end
    end
  end
end
