require 'sizeable/app'

describe Sizeable::App do
  describe "#call(env)" do
    before(:each) do
      Sizeable::Resizer.stub!(:new => mock(:resizer, :resize! => true, :image_blob => ''))
    end
    
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
    
    context "image resizing" do
      def do_request
        Sizeable::App.new.call({})
      end
      
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
    end
  end
end
