require 'stringio'

module Brewby
  class VirtualView
    def initialize
      @output = []
    end

    def move row, col
      @output[row] ||= StringIO.new("".ljust(70))
      @output[row].pos = col
      @current_row = row
    end

    def addstr string
      @output[@current_row].write string
    end

    def readline lineno
      @output[lineno].string
    end

    def refresh
      # no-op
    end
  end
end
