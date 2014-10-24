require 'spec_helper'
require 'pact/consumer_contract/request_decorator'
require 'pact/consumer/request'

module Pact
  describe RequestDecorator do

    let(:path) { "/zebras/1" }
    let(:request_params) do
      {
        method: :get,
        path: path
      }
    end

    let(:request) { Pact::Request::Expected.from_hash(request_params) }

    subject { RequestDecorator.new(request) }

    describe "#to_json" do

      let(:parsed_json) { JSON.parse subject.to_json, symbolize_names: true }

      context "path" do

        context "with a String path" do
          it "renders the path" do
            expect(parsed_json[:path]).to eq path
          end
        end

        context "with a Pact::Term path", pending: "Pact::Terms for paths are not implemented yet"  do
          let(:path) { Pact::Term.new(generate: "/zebras/1", matcher: %r{/zebras/\d})  }

          it "reifies the path for compatibility with pact-specification 1.0.0" do
            expect(parsed_json[:path]).to eq path
          end
        end
      end
    end
  end
end
