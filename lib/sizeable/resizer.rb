require 'rubygems'
require 'aws/s3'
require 'rmagick'

module Sizeable
  class Resizer
    def initialize(request)
      @width = request.params['width'].to_i
      @height = request.params['height'].to_i
      
      connect_to_s3
      begin
        s3_object = AWS::S3::S3Object.find(image_name(request.path_info), s3_bucket)
        
        @image_blob = s3_object.value
        @image = Magick::Image.from_blob(@image_blob).first
        
        @content_type = s3_object.content_type
      rescue AWS::S3::NoSuchKey => e
        raise NoSuchImageException.new
      end
    end
    
    attr_reader :image_blob, :content_type
    
    def resize!
      return if missing_boundary
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
    
    def s3_bucket
      ENV['S3_BUCKET']
    end
    
    def image_name(path)
      path.slice(1, path.length)
    end
    
    def missing_boundary
      @width.nil? or @height.nil? or @width == 0 or @height == 0
    end
  end
  
  class NoSuchImageException < StandardError; end
end