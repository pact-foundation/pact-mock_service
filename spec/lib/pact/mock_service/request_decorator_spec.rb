require 'spec_helper'
require 'pact/mock_service/request_decorator'
require 'pact/consumer_contract/request'


module Pact
  module MockService
    describe RequestDecorator do

      let(:options) { {} }
      let(:body) { {some: "bod"} }
      let(:headers) { {some: "header"} }
      let(:request_params) do
        {
          method: :get,
          query: "param=foo",
          headers: headers,
          path: "/",
          body: body
        }
      end

      let(:request) { Pact::Request::Expected.from_hash(request_params) }

      subject { RequestDecorator.new(request) }

      describe "#to_json" do

        let(:parsed_json) { JSON.parse subject.to_json, symbolize_names: true}

        it "renders the keys in a meaningful order" do
          expect(subject.to_json).to match(/method.*path.*query.*headers.*body/)
        end

        context "with a body specified as a Hash" do
          it "serialises the body as a Hash" do
            expect(parsed_json[:body]).to eq body
          end
        end

        context "with a body specified as a Hash containing a Pact::Term" do
          let(:body) { { some: Pact::Term.new(generate: 'apple', matcher: /a/) } }

          it "serialises the Pact::Term to Ruby specific JSON that is not compatible with pact-specification 1.0.0" do
            expect(subject.to_json).to include "Pact::Term"
          end
        end
      end

      describe "#as_json" do
        context "without options" do
          it "does not include the options key" do
            expect(subject.as_json.key?(:options)).to be false
          end
        end

        context "with options" do
          let(:request_params) do
            {
              method: :get,
              path: "/",
              options: options
            }
          end

          let(:options) { {:opts => 'blah'} }

          it "includes the options in the request hash" do
            expect(subject.as_json[:options]).to eq options
          end
        end
      end

    end
  end
end
