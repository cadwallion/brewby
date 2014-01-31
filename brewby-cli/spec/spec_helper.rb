$:.push File.join(File.dirname(__FILE__), '..', 'lib')

require 'brewby/cli'
require 'pry'

load './spec/support/virtual_view.rb'
