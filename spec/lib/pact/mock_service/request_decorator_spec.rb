require 'spec_helper'
require 'pact/mock_service/request_decorator'
require 'pact/consumer_contract/request'


module Pact
  module MockService
    describe RequestDecorator do

      let(:options) { {} }
      let(:request) { Pact::Request::Expected.new("get", "/", {some: "things"}, {some: "things"} , "some=things", options) }

      subject { RequestDecorator.new(request) }

      describe "#to_json" do
        it "renders the keys in a sensible order" do
          expect(subject.to_json).to match(/method.*path.*query.*headers.*body/)
        end
      end

      describe "#as_json" do
        context "without options" do
          it "does not include the options key" do
            expect(subject.as_json.key?(:options)).to be false
          end
        end

        context "with options" do
          let(:options) { {:opts => 'blah'} }
          it "includes the options in the request hash" do
            expect(subject.as_json[:options]).to eq options
          end
        end
      end

    end
  end
end
