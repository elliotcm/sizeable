require 'rack/response'
require 'rack/request'

require 'lib/sizeable/resizer'

module Sizeable
  class App

    def call(env)
      begin
        resizer = Resizer.new(Rack::Request.new(env))
        resizer.resize!

        headers = {
          "Content-Type" => resizer.content_type,
          'Cache-Control' => "public, max-age=#{days_to_seconds(14)}"
        }

        Rack::Response.new(resizer.image_blob, 200, headers).finish
      rescue NoSuchImageException => e
        Rack::Response.new('The requested image was not found.', 404).finish
      end
    end

  protected

    def days_to_seconds(days)
      days * 24 * 60 * 60
    end

  end
end
