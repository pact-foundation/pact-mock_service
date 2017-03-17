require 'spec_helper'
require 'pact/consumer_contract/request_decorator'
require 'pact/consumer/request'

module Pact
  describe RequestDecorator do

    let(:headers) { {some: Pact::Term.new(generate: 'header', matcher: /header/ )} }
    let(:request_params) do
      {
        method: :get,
        headers: headers,
        path: "/"
      }
    end
    let(:request) { Pact::Request::Expected.from_hash(request_params) }
    let(:parsed_json) { JSON.parse subject.to_json, symbolize_names: true }

    describe "#to_json" do
      subject { RequestDecorator.new(request) }

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

    describe '#to_json pact spec v2' do
      subject { RequestDecorator.new(request, { pact_specification_version: '2.0.0' }) }

      context 'headers' do

        context 'as a Hash containing param Term' do
          it 'returns a Hash and generated matchingRules' do
            expect(parsed_json[:headers][:some]).to eq 'header'
            expect(parsed_json[:matchingRules][:"$.headers.some"][:match]).to eq 'regex'
            expect(parsed_json[:matchingRules][:"$.headers.some"][:regex]).to eq 'header'
          end
        end

        context 'as a Hash with no Terms' do
          let(:headers) { {some: 'header'} }

          it 'returns a Hash with no generated matchingRules' do
            expect(parsed_json[:headers][:some]).to eq 'header'
            expect(parsed_json[:matchingRules]).to eq nil
          end
        end

      end

    end

  end
end
