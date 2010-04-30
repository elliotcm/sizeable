require 'rack/response'
require 'rack/request'

require 'lib/sizeable/resizer'

module Sizeable
  class App
    def call(env)
      begin
        resizer = Resizer.new(Rack::Request.new(env))
        resizer.resize!
        
        Rack::Response.new(resizer.image_blob, 200, {"Content-Type" => resizer.content_type}).finish
      rescue NoSuchImageException => e
        Rack::Response.new('The requested image was not found.', 404).finish
      end
    end
  end
end
