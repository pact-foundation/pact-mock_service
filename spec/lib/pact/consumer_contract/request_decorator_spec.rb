require 'spec_helper'
require 'pact/consumer_contract/request_decorator'
require 'pact/consumer/request'

module Pact
  describe RequestDecorator do

    let(:options) { { some: 'opts' } }
    let(:body) { { some: "bod" } }
    let(:headers) { { some: "header" } }
    let(:query) { "param=foo" }
    let(:request_params) do
      {
        method: :get,
        query: query,
        headers: headers,
        path: "/",
        body: body,
        options: options
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


      context "when the path is a Pact::Term" do
        let(:request_params) do
          {
            method: :get, path: Pact::Term.new(matcher: %r{/alligators/.*}, generate: '/alligators/Mary')
          }
        end

        it "reifies the path" do
          expect(parsed_json[:path]).to eq '/alligators/Mary'
        end
      end
    end
  end
end
