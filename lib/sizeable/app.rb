require 'rack/response'
require 'rack/request'

require 'lib/sizeable/resizer'

module Sizeable
  class App
    def call(env)
      resizer = Resizer.new(Rack::Request.new(env))
      resizer.resize!
      
      Rack::Response.new(resizer.image_blob).finish
    end
  end
end
