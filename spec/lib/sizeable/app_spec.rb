require 'sizeable'

describe Sizeable::App do
  describe "#call(env)" do
    context "lint tests" do
      before(:each) do
        @response = Sizeable::App.new.call(mock(:env))
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
    
    def request_path(path)
      Sizeable::App.new.call({'PATH_INFO' => path})
    end
    
    it "converts the requested path to a (potentially resized image)" do
      path = mock(:path)
      
      
      
      request_path(path)
    end
  end
end
