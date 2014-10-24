require 'spec_helper'
require 'pact/consumer_contract/request_decorator'
require 'pact/consumer/request'

module Pact
  describe RequestDecorator do

    let(:headers) { {some: "header"} }
    let(:query) { "param=foo" }
    let(:request_params) do
      {
        method: :get,
        query: query,
        headers: headers,
        path: "/"
      }
    end

    let(:request) { Pact::Request::Expected.from_hash(request_params) }

    subject { RequestDecorator.new(request) }

    describe "#to_json" do

      let(:parsed_json) { JSON.parse subject.to_json, symbolize_names: true }

      context "query" do
        context "with a query hash containing a Pact::Term" do
          let(:query) { { param: Pact::Term.new(generate: 'apple', matcher: /a/) } }

          it "reifies the query for compatibility with pact-specification 1.0.0" do
            expect(parsed_json[:query]).to eq "param=apple"
          end
        end

        context "with a Pact::Term query" do
          let(:query) { Pact::Term.new(generate: 'param=apple', matcher: /param=a/) }

          it "reifies the query for compatibility with the pact-specification 1.0.0" do
            expect(parsed_json[:query]).to eq 'param=apple'
          end
        end

        context "when the query is not specified" do
          let(:request_params) do
            {
              method: :get,
              path: "/"
            }
          end

          it "does not include the key" do
            expect(parsed_json).to_not have_key(:query)
          end
        end

        context "when the query is nil" do
          let(:request_params) do
            {
              method: :get,
              path: "/",
              query: nil
            }
          end

          it "includes the query as nil" do
            expect(parsed_json.fetch(:query)).to be nil
          end
        end
      end

    end
  end
end
