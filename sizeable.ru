require 'rack'
require 'lib/sizeable'

use Rack::ShowExceptions
run Sizeable::App.new
