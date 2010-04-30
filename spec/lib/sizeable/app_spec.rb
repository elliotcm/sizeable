require 'sizeable/app'

shared_examples_for 'a valid rack app' do
  context "lint tests" do
    before(:each) do
      @response = Sizeable::App.new.call(mock(:env, :[] => {}))
    end

    it "returns a valid status" do
      @response[0].to_i.should be >= 100
    end

    it "returns valid headers" do
      headers = @response[1]

      headers.should respond_to(:each)
      headers.each do |key, value|
        key.should_not be_nil
        value.should_not be_nil
      end 
    end

    it "returns a valid body" do
      @response[2].each do |body_line|
        body_line.should be_a(String)
      end
    end
  end
end

describe Sizeable::App do
  describe "#call(env)" do
    def do_request
      Sizeable::App.new.call({})
    end

    context "when a valid image is requested" do
      before(:each) do
        Sizeable::Resizer.stub!(:new => mock(:resizer, :resize! => true, :image_blob => '', :content_type => ''))
      end
    
      it_should_behave_like 'a valid rack app'
    
      before(:each) do
        @resizer = Sizeable::Resizer.new(mock(:request))
        Sizeable::Resizer.stub!(:new => @resizer)
      end

      it "converts the requested request to a (potentially resized) image" do
        @resizer.should_receive(:resize!)
        do_request
      end

      it "returns the new image as the body of the response" do
        @resizer.stub!(:image_blob => (@image_blob = mock(:image_blob).to_s))
        do_request[2].body.should == [@image_blob]
      end

      it "returns the content type of the new image in the headers of the response" do
        @resizer.stub!(:content_type => (@content_type = mock(:content_type).to_s))
        do_request[1]['Content-Type'].should == @content_type
      end
    end
    
    context "when an invalid image is requested" do
      before(:each) do
        Sizeable::Resizer.stub!(:new).and_raise(Sizeable::NoSuchImageException)
      end
    
      it_should_behave_like 'a valid rack app'
      
      it "responds with a 404" do
        do_request[0].to_i.should == 404
      end
    end
  end
end
