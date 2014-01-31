module Brewby
  module CLI
    module Views
      class TempControl
        attr_reader :step, :view
        def initialize step, view
          @step = step
          @view = view
        end

        def power_level
          (step.power_level * 100.0).round(3)
        end

        def timer
          step.timer_for(step.elapsed.to_i)
        end

        def time_remaining
          step.countdown_for(step.time_remaining)
        end

        def render
          view.move 2, 10
          if step.name
            view.addstr step.name.ljust(70)
          else
            view.addstr "#{step.mode.capitalize} Temp Control".ljust(70)
          end

          view.move 6, 0
          view.addstr "Power Level: #{power_level}%".ljust(70)
          view.move 16, 50
          view.addstr "Step Timer: #{timer}"
          view.refresh

          if step.target
            view.move 4, 0
            view.addstr "Target Temp: #{step.target} F".ljust(70)
          end

          view.move 5, 0
          view.addstr "Actual Temp: #{step.last_reading} F".ljust(25)

          if step.threshold_reached
            view.move 7, 0
            view.addstr "Time Remaining: #{time_remaining}".ljust(70)
          else
            view.move 7, 0
            view.addstr "".ljust(70)
          end
        end

        def handle_input key
          case key
          when 'e'.ord
            if step.mode == :manual
              new_pct = [(step.power_level + 0.05).round(2), 1.0].min
              step.set_power_level new_pct
            end
          when 'c'.ord
            if step.mode == :manual
              new_pct = [(step.power_level - 0.05).round(2), 0.0].max
              step.set_power_level new_pct
            end
          end
        end
      end
    end
  end
end
