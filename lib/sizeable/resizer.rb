require 'rubygems'
require 'aws/s3'
require 'rmagick'

module Sizeable
  class Resizer
    def initialize(request)
      @width = request.params['width'].to_i
      @height = request.params['height'].to_i
      
      @image_blob = AWS::S3::S3Object.value(request.path_info, 'bucket_name')
      @image = Magick::Image.from_blob(@image_blob)
      
      connect_to_s3
    end
    
    def resize!
      
    end
    
    def image_blob
      
    end
    
    private
    def connect_to_s3
      AWS::S3::Base.establish_connection!(
        :access_key_id     => ENV['S3_KEY'],
        :secret_access_key => ENV['S3_SECRET']
      )
    end
  end
end