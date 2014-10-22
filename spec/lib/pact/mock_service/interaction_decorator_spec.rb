require 'spec_helper'
require 'pact/mock_service/interaction_decorator'

module Pact
  module MockService
    describe InteractionDecorator do

      describe "#to_json" do

        let(:request) do
          {
            method: 'post',
            path: '/foo',
            body: Term.new(generate: 'waffle', matcher: /ffl/),
            headers: { 'Content-Type' => 'application/json' },
            query: '',
          }
        end

        let(:response) do
          { body: { baz: /qux/, wiffle: Term.new(generate: 'wiffle', matcher: /iff/) } }
        end

        let(:interaction) do
          Interaction.from_hash(
            'description' => 'description',
            'provider_state' => 'provider_state',
            'response' => response,
            'request' => request)
        end

        subject { InteractionDecorator.new(interaction)  }

        let(:parsed_result) do
          JSON.load(subject.to_json)
        end

        it "contains the request" do
          expect(parsed_result).to have_key('request')
        end

        it "contains the response" do
          expect(parsed_result).to have_key('request')
        end

        it "contains the description" do
          expect(parsed_result['description']).to eq 'description'
        end

        context "with a provider state" do
          it "contains the provider_state" do
            expect(parsed_result['provider_state']).to eq 'provider_state'
          end
        end

        context "without a provider state" do

          let(:interaction) do
            Interaction.from_hash(
              'description' => 'description',
              'response' => response,
              'request' => request)
          end

          it "does not contain the provider_state" do
            expect(parsed_result).to_not have_key 'provider_state'
          end
        end

      end

    end
  end
end
