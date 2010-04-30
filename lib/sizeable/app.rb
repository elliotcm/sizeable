require 'rack/response'

module Sizeable
  class App
    def call(env)
      Rack::Response.new.finish
    end
  end
end
