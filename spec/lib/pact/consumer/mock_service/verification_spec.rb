require 'spec_helper'
require 'pact/mock_service/interactions/expected_interactions'
require 'pact/mock_service/interactions/actual_interactions'
require 'pact/mock_service/interactions/verification'

module Pact::MockService::Interactions

  describe Verification do
    shared_context "unexpected requests and missed interactions" do
      let(:expected_interaction) { InteractionFactory.create }
      let(:unexpected_request) { RequestFactory.create_actual method: 'put' }
      let(:candidate_interaction) { double("Pact::Interaction") }
      let(:candidate_interactions) { [candidate_interaction] }
      let(:interaction_mismatch) { instance_double("Pact::Consumer::InteractionMismatch", :short_summary => 'blah', :candidate_interactions => candidate_interactions)}

      subject do
        expected_interactions = Pact::MockService::Interactions::ExpectedInteractions.new
        actual_interactions = Pact::MockService::Interactions::ActualInteractions.new
        expected_interactions << expected_interaction
        actual_interactions.register_unexpected_request unexpected_request
        actual_interactions.register_interaction_mismatch interaction_mismatch

        Verification.new(expected_interactions, actual_interactions)
       end
    end

    shared_context "no unexpected requests or missed interactions exist" do
      let(:expected_interaction) { InteractionFactory.create }

      subject do
        expected_interactions = Pact::MockService::Interactions::ExpectedInteractions.new
        actual_interactions = Pact::MockService::Interactions::ActualInteractions.new
        expected_interactions << expected_interaction
        actual_interactions.register_matched expected_interaction
        Verification.new(expected_interactions, actual_interactions)
       end
    end

    describe "interaction_diffs" do
      context "when unexpected requests and missed interactions exist" do
        include_context "unexpected requests and missed interactions"

        let(:expected_diff) do
          {:missing_interactions=>["GET /path"],
            :unexpected_requests=>["PUT /path?query"],
            :interaction_mismatches => ['blah']}
        end

        it "returns the unexpected requests and missed interactions" do
          expect(subject.interaction_diffs).to eq expected_diff
        end
      end

      context "when no unexpected requests or missed interactions exist" do
        include_context "no unexpected requests or missed interactions exist"

        let(:expected_diff) do
          {}
        end

        it "returns an empty hash" do
          expect(subject.interaction_diffs).to eq expected_diff
        end
      end
    end

    describe "all_matched?" do
      context "when unexpected requests or missed interactions exist" do
        include_context "unexpected requests and missed interactions"

        it "returns false" do
          expect(subject.all_matched?).to be false
        end
      end

      context "when unexpected requests or missed interactions do not exist" do
        include_context "no unexpected requests or missed interactions exist"

        it "returns false" do
          expect(subject.all_matched?).to be true
        end
      end
    end

    describe "missing_interactions_summaries" do
      include_context "unexpected requests and missed interactions"

      it "returns a list of the method and paths for each missing interaction" do
        expect(subject.missing_interactions_summaries).to eq ["GET /path"]
      end
    end
  end
end
