require 'spec_helper'
require 'pact/consumer_contract/request_decorator'
require 'pact/consumer/request'

module Pact
  describe RequestDecorator do

    let(:options) { {some: 'opts'} }
    let(:body) { {some: "bod"} }
    let(:headers) { {some: "header"} }
    let(:query) { "param=foo" }
    let(:request_params) do
      {
        method: :get,
        query: query,
        headers: headers,
        path: "/",
        body: body
      }
    end

    let(:request) { Pact::Request::Expected.from_hash(request_params) }

    subject { RequestDecorator.new(request) }

    describe "#to_json" do

      let(:parsed_json) { JSON.parse subject.to_json, symbolize_names: true }

      it "renders the keys in a meaningful order" do
        expect(subject.to_json).to match(/method.*path.*query.*headers.*body/)
      end

      it "does not render the options" do
        expect(subject.to_json).to_not include('options')
      end

      context "with a query hash containing a Pact::Term" do
        let(:query) { { param: Pact::Term.new(generate: 'apple', matcher: /a/) } }

        it "reifies the query for backwards compatibility with pact-specification 1.0.0" do
          expect(parsed_json[:query]).to eq "param=apple"
        end
      end

      context "with a Pact::Term query" do
        let(:query) { Pact::Term.new(generate: 'param=apple', matcher: /param=a/) }

        it "serialises the Pact::Term to Ruby specific JSON that is not compatible with pact-specification 1.0.0" do
          expect(subject.to_json).to include "Pact::Term"
        end
      end

      context "with a Content-Type of form and body specified as a hash with a Pact::Term" do
        let(:headers) { { 'Content-Type' => 'application/x-www-form-urlencoded' } }
        let(:body) { {"param" => Pact::Term.new(generate: 'apple', matcher: /a/ )} }

        it "reifies the body for backwards compatibility with pact-specification 1.0.0" do
          expect(parsed_json[:body]).to eq "param=apple"
        end
      end

      context "with a Content-Type of form and body specified as a hash with an array value" do
        let(:headers) { { 'Content-Type' => 'application/x-www-form-urlencoded' } }
        let(:body) { {"param" => ['pear', Pact::Term.new(generate: 'apple', matcher: /a/ )] } }

        it "reifies the body for backwards compatibility with pact-specification 1.0.0" do
          expect(parsed_json[:body]).to eq "param=pear&param=apple"
        end
      end

      context "with no Content-Type and a body specified as a Hash" do
        it "renders the body as JSON" do
          expect(parsed_json[:body]).to eq body
        end
      end
    end

  end
end
