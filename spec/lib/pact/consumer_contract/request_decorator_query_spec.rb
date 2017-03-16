require 'spec_helper'
require 'pact/consumer_contract/request_decorator'
require 'pact/consumer/request'

module Pact
  describe RequestDecorator do

    let(:headers) { {some: "header"} }
    let(:query) { {param: Pact::Term.new(generate: 'foo', matcher: /foo/ )} }
    let(:request_params) do
      {
        method: :get,
        query: query,
        headers: headers,
        path: "/"
      }
    end
    let(:request) { Pact::Request::Expected.from_hash(request_params) }
    let(:parsed_json) { JSON.parse subject.to_json, symbolize_names: true }

    describe "#to_json" do
      subject { RequestDecorator.new(request) }

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

    describe '#to_json pact spec v2' do
      subject { RequestDecorator.new(request, { pact_specification_version: '2.0.0' }) }

      context 'query' do

        context 'as a Hash containing param Term' do
          it 'returns a Hash and generated matchingRules' do
            expect(parsed_json[:query][:param]).to eq 'foo'
            expect(parsed_json[:matchingRules][:"$.query.param"][:match]).to eq 'regex'
            expect(parsed_json[:matchingRules][:"$.query.param"][:regex]).to eq 'foo'
          end
        end

        context 'as a Hash with no Terms' do
          let(:query) { {param: 'foo'} }

          it 'returns a Hash with no generated matchingRules' do
            expect(parsed_json[:query][:param]).to eq 'foo'
            expect(parsed_json[:matchingRules]).to eq nil
          end
        end

      end

    end

  end
end
