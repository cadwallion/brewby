require 'ffi-ncurses'


module Brewby
  class View
    include FFI::NCurses

    def initialize
      initscr
      cbreak
      noecho
      timeout(100)
      curs_set 0
      counter = 0
    end

    def clear
      endwin
    end
  end
end
