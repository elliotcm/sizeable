require 'aws/s3'
require 'RMagick'

module Sizeable
  class Resizer

    def initialize(s3_bucket, image_name, options={})
      connect_to_s3
      begin
        s3_object = AWS::S3::S3Object.find(image_name, s3_bucket)

        @image = Magick::Image.from_blob(s3_object.value).first

        @content_type = s3_object.content_type
      rescue AWS::S3::NoSuchBucket, AWS::S3::NoSuchKey
        raise NoSuchImageException
      end

      @options = options
      @width = options[:width]
      @height = options[:height]
    end

    attr_reader :content_type

    def resize!
      return if missing_boundary?
      @image.resize_to_fit!(@width, @height)
    end

    def reflect!
      return unless @options[:reflect]

      @image.format = 'PNG'
      @content_type = @image.mime_type

      mask = Magick::Image.new(@image.columns, @image.rows, Magick::GradientFill.new(0, 0, @image.columns, 0, "white", "black"))
      mask.matte = false

      reflection = @image.flip
      reflection.matte = true

      reflection.composite!(mask, Magick::CenterGravity, Magick::CopyOpacityCompositeOp)

      components = Magick::ImageList.new
      components << @image
      components << reflection

      @image = components.append(true)
    end

    def image_blob
      @image.to_blob
    end

  protected

    def connect_to_s3
      AWS::S3::Base.establish_connection!(
        :access_key_id     => ENV['S3_KEY']    || s3_config[:aws_access_key_id],
        :secret_access_key => ENV['S3_SECRET'] || s3_config[:aws_secret_access_key]
      )
    end

    def missing_boundary?
      @width.nil? or @height.nil? or @width == 0 or @height == 0
    end

    def s3_config
      @s3_config ||= YAML.load_file(RACK_ROOT + '/config/ec2.yml')
    end

  end

  class NoSuchImageException < StandardError; end
end
