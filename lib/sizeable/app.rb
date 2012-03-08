require 'rack/response'
require 'rack/request'

require 'lib/sizeable/resizer'

require 'time'

module Sizeable
  class App

    def call(env)
      begin
        resizer = Resizer.new(*parse_request(env))
        resizer.resize!
        resizer.reflect!

        headers = {
          "Content-Type" => resizer.content_type,
          'Cache-Control' => "public, max-age=#{days_to_seconds(14)}",
          'Last-Modified' => resizer.last_modified.httpdate
        }

        Rack::Response.new(resizer.image_blob, 200, headers).finish
      rescue NoSuchImageException
        Rack::Response.new('The requested image was not found.', 404).finish
      rescue
        Rack::Response.new('There was an error requesting your image.  Please check the URL and try again.', 500).finish
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

      options = {}
      parts.each_with_index do |part, index|
        if part == 'reflect'
          parts[index] = nil
          options[:reflect] = true
        elsif part =~ /^(\d+)x(\d+)$/
          parts[index] = nil
          options.merge!(:width => $1, :height => $2)
        end
      end

      image_name = parts.compact.join('/')

      return [s3_bucket, image_name, options]
    end

    def preset_s3_bucket
      ENV['S3_BUCKET']
    end

  end
end
