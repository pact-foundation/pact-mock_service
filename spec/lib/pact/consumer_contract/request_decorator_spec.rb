require 'spec_helper'
require 'pact/consumer_contract/request_decorator'
require 'pact/consumer/request'

module Pact
  describe RequestDecorator do

    let(:options) { {opts: 'someopt'} }
    let(:request) { Pact::Request::Expected.new("get", "/", {some: "things"}, {some: "things"} , "some=things", options) }

    subject { RequestDecorator.new(request) }

    describe "#to_json" do
      it "renders the keys in a sensible order" do
        expect(subject.to_json).to match(/method.*path.*query.*headers.*body/)
      end

      it "does not render the options" do
        expect(subject.to_json).to_not include('options')
      end
    end

  end
end
