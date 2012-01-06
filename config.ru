$LOAD_PATH << File.dirname(__FILE__)

require "rubygems"
require "bundler/setup"

require 'rack'
require 'lib/sizeable'

use Rack::ShowExceptions
run Sizeable::App.new
