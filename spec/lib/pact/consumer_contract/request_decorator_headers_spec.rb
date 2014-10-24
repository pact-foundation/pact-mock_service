require 'spec_helper'
require 'pact/consumer_contract/request_decorator'
require 'pact/consumer/request'

module Pact
  describe RequestDecorator do

    let(:headers) { { some: "header" } }
    let(:request_params) do
      {
        method: :get,
        headers: headers,
        path: "/"
      }
    end

    let(:request) { Pact::Request::Expected.from_hash(request_params) }

    subject { RequestDecorator.new(request) }

    describe "#to_json" do

      let(:parsed_json) { JSON.parse subject.to_json, symbolize_names: true }

      context "headers" do

        it "renders the headers" do
          expect(parsed_json[:headers][:some]).to eq "header"
        end

        context "with a Pact::Term in the headers" do
          let(:headers) { { 'X-Zebra' => Pact::Term.new(generate: 'zebra', matcher: /z/) } }

          it "reifies the headers" do
            expect(parsed_json[:headers][:'X-Zebra']).to eq 'zebra'
          end
        end

        context "with no headers specified" do
          let(:request_params) do
            {
              method: :get,
              path: "/"
            }
          end

          it "does not include the key" do
            expect(parsed_json).to_not have_key(:headers)
          end
        end

       context "with nil headers specified" do
         let(:request_params) do
           {
             method: :get,
             path: "/",
             headers: nil
           }
         end

         it "renders the headers as nil, but this would really be silly and will probably cause problems down the line" do
           expect(parsed_json.fetch(:headers)).to be nil
         end
       end

      end
    end
  end
end
