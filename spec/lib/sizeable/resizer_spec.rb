require 'sizeable/resizer'
require 'rack/request'

describe Sizeable::Resizer do
  describe ".new(Rack::Request)" do
    before(:each) do
      @width = rand(100)
      @height = rand(100)
      
      @env = {'rack.input' => '', 'QUERY_STRING' => ''}
      
      AWS::S3::S3Object.stub!(:value)
      Magick::Image.stub!(:from_blob)
    end
    
    it "parses the params for target size" do
      @env.merge!({'QUERY_STRING' => "width=#{@width}&height=#{@height}"})
      resizer = Sizeable::Resizer.new(Rack::Request.new(@env))
      
      resizer.instance_variable_get('@width').should == @width
      resizer.instance_variable_get('@height').should == @height
    end
    
    it "fetches the original file and stores it as an RMagick file" do
      path = mock(:path).to_s
      @env.merge!({'PATH_INFO' => path})
      
      AWS::S3::S3Object.stub!(:value).with(path, anything).and_return(blob = mock(:blob))
      Magick::Image.stub!(:from_blob).with(blob).and_return(image = mock(:image))
      
      resizer = Sizeable::Resizer.new(Rack::Request.new(@env))
      resizer.instance_variable_get('@image').should == image
    end
  end
  
  describe "#resize!" do
    
  end
  
  describe "#image_blob" do
    
  end
end