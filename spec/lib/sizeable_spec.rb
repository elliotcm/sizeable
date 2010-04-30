require 'sizeable'

describe Sizeable do
  describe "#call(env)" do
    context "lint tests" do
      before(:each) do
        @response = Sizeable.new.call(mock(:env))
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
end
