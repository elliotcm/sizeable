require 'rack/response'
require 'rack/request'

require 'lib/sizeable/resizer'

module Sizeable
  class App

    def call(env)
      begin
        resizer = Resizer.new(*parse_request(env))
        resizer.resize!

        headers = {
          "Content-Type" => resizer.content_type,
          'Cache-Control' => "public, max-age=#{days_to_seconds(14)}"
        }

        Rack::Response.new(resizer.image_blob, 200, headers).finish
      rescue NoSuchImageException
        Rack::Response.new('The requested image was not found.', 404).finish
      end
    end

  protected

    def days_to_seconds(days)
      days * 24 * 60 * 60
    end

    def parse_request(env)
      request = Rack::Request.new(env)

      parts = request.path_info.split('/').reject{|str| str.nil? or str == ''}

      raise NoSuchImageException if parts.length < 2

      s3_bucket = preset_s3_bucket || parts.shift

      if parts[-2] =~ /^(\d+)x(\d+)$/
        parts.delete_at(-2)
        width, height = $1, $2
      end

      image_name = parts.join('/')

      return [s3_bucket, image_name, width, height]
    end

    def preset_s3_bucket
      ENV['S3_BUCKET']
    end

  end
end
