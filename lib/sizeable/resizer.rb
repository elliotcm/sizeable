require 'aws/s3'
require 'RMagick'

module Sizeable
  class Resizer
    def initialize(s3_bucket, image_name, width, height)
      connect_to_s3
      begin
        s3_object = AWS::S3::S3Object.find(image_name, s3_bucket)

        @image_blob = s3_object.value
        @image = Magick::Image.from_blob(@image_blob).first

        @content_type = s3_object.content_type
      rescue AWS::S3::NoSuchBucket, AWS::S3::NoSuchKey
        raise NoSuchImageException
      end

      @width = width
      @height = height
    end

    attr_reader :image_blob, :content_type

    def resize!
      return if missing_boundary?
      @image = @image.resize_to_fit(@width, @height)
      @image_blob = @image.to_blob
    end

    private
    def connect_to_s3
      AWS::S3::Base.establish_connection!(
        :access_key_id     => ENV['S3_KEY'],
        :secret_access_key => ENV['S3_SECRET']
      )
    end

    def missing_boundary?
      @width.nil? or @height.nil? or @width == 0 or @height == 0
    end
  end

  class NoSuchImageException < StandardError; end
end
