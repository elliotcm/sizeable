require 'rack/response'

class Sizeable
  def call(env)
    Rack::Response.new.finish
  end
end