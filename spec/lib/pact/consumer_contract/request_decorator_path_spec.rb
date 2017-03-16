require 'spec_helper'
require 'pact/consumer_contract/request_decorator'
require 'pact/consumer/request'

module Pact
  describe RequestDecorator do

    let(:path) { Pact::Term.new(generate: 'testpath', matcher: /testpath/ ) }
    let(:request_params) do
      {
          method: :get,
          path: path
      }
    end
    let(:request) { Pact::Request::Expected.from_hash(request_params) }
    let(:parsed_json) { JSON.parse subject.to_json, symbolize_names: true }

    describe '#to_json pact spec v1' do
      subject { RequestDecorator.new(request, { pact_specification_version: '1.0.0' }) }

      context 'path' do

        context 'as a Term' do
          it 'returns a String' do
            expect(parsed_json[:path]).to eq 'testpath'
          end
        end

        context 'as a String' do
          let(:path) { 'testpath' }

          it 'returns a String' do
            expect(parsed_json[:path]).to eq 'testpath'
          end
        end

      end

    end

    describe '#to_json pact spec v2' do
      subject { RequestDecorator.new(request, { pact_specification_version: '2.0.0' }) }

      context 'path' do

        context 'as a Term' do
          it 'returns a String with generated matching rules' do
            expect(parsed_json[:path]).to eq 'testpath'
            expect(parsed_json[:matchingRules][:"$.path"][:match]).to eq 'regex'
            expect(parsed_json[:matchingRules][:"$.path"][:regex]).to eq 'testpath'
          end
        end

        context 'as a String' do
          let(:path) { 'testpath' }

          it 'returns a String' do
            expect(parsed_json[:path]).to eq 'testpath'
            expect(parsed_json[:matchingRules]).to eq nil
          end
        end

      end

    end

  end
end
