RACK_ROOT = File.dirname(__FILE__)
$LOAD_PATH << RACK_ROOT

require "rubygems"
require "bundler/setup"

require 'rack'
require 'lib/sizeable'

use Rack::ShowExceptions
run Sizeable::App.new
