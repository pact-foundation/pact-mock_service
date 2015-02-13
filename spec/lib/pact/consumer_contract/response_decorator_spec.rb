require 'pact/consumer_contract/response_decorator'
require 'support/shared_examples_for_response_decorator'

module Pact
  describe ResponseDecorator do

    include_examples "response decorator to_json"

    describe "to_json" do

      let(:response_hash) { { status: 200, body: { some: Pact::SomethingLike.new('body') } } }
      let(:response) { Pact::Response.from_hash response_hash }
      let(:subject) { ResponseDecorator.new(response, pact_specification_version: pact_specification_version)}
      let(:parsed_json) { JSON.parse(subject.to_json, symbolize_names: true)}

      context "when pact_specification_version is nil" do
        let(:pact_specification_version) { nil }

        it "includes Ruby specific JSON in the output" do
          expect(subject.to_json).to include("Pact::SomethingLike")
        end

        it "does not include any matching rules" do
          expect(parsed_json).to_not include(:responseMatchingRules)
        end
      end

      context "when pact_specification_version is < 2" do
        let(:pact_specification_version) { '1.0' }

        it "includes Ruby specific JSON in the output" do
          expect(subject.to_json).to include("Pact::SomethingLike")
        end

        it "does not include any matching rules" do
          expect(parsed_json).to_not include(:responseMatchingRules)
        end
      end

      context "when pact_specification_version is >= 2" do
        let(:pact_specification_version) { '2.0' }
        let(:matching_rules) { {some: 'rules'} }

        before do
          allow(Pact::MatchingRules).to receive(:extract).and_return(matching_rules)
        end

        it "extracts the matching rules and inclues them in the json" do
          expect(parsed_json[:responseMatchingRules]).to eq matching_rules
        end

        it "does not include Ruby specific JSON in the output" do
          expect(subject.to_json).to_not include("Pact::SomethingLike")
        end

        context "when the matching rules are empty" do
          let(:matching_rules) { {} }

          it "does not include the matching rules key in the json" do
            expect(parsed_json).to_not include(:responseMatchingRules)
          end
        end
      end
    end
  end
end
