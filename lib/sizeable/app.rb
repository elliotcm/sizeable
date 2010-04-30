require 'rack/response'
require 'lib/sizeable/resizer'

module Sizeable
  class App
    def call(env)
      resizer = Resizer.new(env['PATH_INFO'])
      resizer.resize!
      
      Rack::Response.new(resizer.image_blob).finish
    end
  end
end
