require 'sizeable/resizer'
require 'rack/request'

describe Sizeable::Resizer do
  before(:each) do
    AWS::S3::S3Object.stub!(:find => mock(:s3_object, :value => '', :content_type => ''))
    Magick::Image.stub!(:from_blob => [])
    
    AWS::S3::Base.stub!(:establish_connection!)
    
    @width = rand(100)
    @height = rand(100)
  end
  
  describe ".new(Rack::Request)" do
    before(:each) do
      @env = {'rack.input' => '', 'QUERY_STRING' => ''}
    
      @path = mock(:path).to_s
    end

    context "if a useful path was not provided" do
      before(:each) do
        @env.merge!({'PATH_INFO' => "/"})
      end
      
      it "raises a NoSuchImageException" do
        lambda {
          Sizeable::Resizer.new(Rack::Request.new(@env))
        }.should raise_error(Sizeable::NoSuchImageException)
      end
    end
    
    context "if a path was provided" do
      before(:each) do
        @env.merge!({'PATH_INFO' => "/#{@path}"})
      end

      it "parses the params for target size" do
        @env.merge!({'QUERY_STRING' => "width=#{@width}&height=#{@height}"})
        resizer = Sizeable::Resizer.new(Rack::Request.new(@env))

        resizer.instance_variable_get('@width').should == @width
        resizer.instance_variable_get('@height').should == @height
      end
    
      context "if the image exists" do
        before(:each) do
          @blob = mock(:blob)
          @content_type = mock(:content_type)
          s3_object = mock(:s3_object, :value => @blob, :content_type => @content_type)
          AWS::S3::S3Object.stub!(:find).with(@path, anything).and_return(s3_object)
        end
      
        it "fetches the original file and stores it as an RMagick file" do
          Magick::Image.stub!(:from_blob).with(@blob).and_return([image = mock(:image)])

          resizer = Sizeable::Resizer.new(Rack::Request.new(@env))
          resizer.instance_variable_get('@image').should == image
          resizer.instance_variable_get('@content_type').should == @content_type
        end
      end
    
      context "if the image does not exist" do
        before(:each) do
          AWS::S3::S3Object.stub!(:find).with(@path, anything).and_raise(AWS::S3::NoSuchKey.new('message', 'response'))
        end

        it "raises a NoSuchImageException" do
          lambda {
            Sizeable::Resizer.new(Rack::Request.new(@env))
          }.should raise_error(Sizeable::NoSuchImageException)
        end
      end
    end
  end
  
  describe "#resize!" do
    before(:each) do
      @image = mock(:image)

      @resizer = Sizeable::Resizer.new(mock(:request, :params => {}, :path_info => ''))
      @resizer.instance_variable_set('@width', @width)
      @resizer.instance_variable_set('@height', @height)
      @resizer.instance_variable_set('@image', @image)
    end
    
    it "confines the given image to the given height and width" do
      new_image = mock(:new_image, :to_blob => (new_image_blob = mock(:image_blob)))
      
      @image.stub!(:resize_to_fit).with(@width, @height).and_return(new_image)
      
      @resizer.resize!
      
      @resizer.instance_variable_get('@image').should == new_image
      @resizer.instance_variable_get('@image_blob').should == new_image_blob
    end
  end
end
