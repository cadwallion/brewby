require 'brewby'
require 'brewby/cli/views/application'

module Brewby
  module CLI
    class Application < Brewby::Application
      attr_accessor :ready
      attr_reader :view
      def initialize options = {}
        super  
        configure_view
      end

      def configure_view
        @view = Brewby::CLI::Views::Application.new self
      end

      def start
        super
      ensure
        view.clear if view
      end

      def start_step step
        super 
        view.load_step_view step
      end

      def tick
        super
        view.render
        view.handle_input
      end
    end
  end
end
