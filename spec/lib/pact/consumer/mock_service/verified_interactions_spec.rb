require 'spec_helper'
require 'pact/consumer/mock_service/verified_interactions'

module Pact
  module Consumer
    describe VerifiedInteractions do

      let(:interaction_1) { InteractionFactory.create }
      let(:interaction_2) { InteractionFactory.create description: 'another description' }
      let(:interaction_3) { InteractionFactory.create response: { status: 404 } }

      describe "<<" do
        context "when an interaction with the same description and provider state does not exist" do
          it "adds the interaction" do
            subject << interaction_1
            subject << interaction_2
            expect(subject.size).to eq 2
          end
        end

        context "when an interaction with the same description and provider state already exists" do
          it "will not add the second interaction" do
            subject << interaction_1
            subject << interaction_1
            expect(subject.size).to eq 1
          end
        end
      end

      describe "#find_matching_description_and_provider_state" do
        context "when an interaction with the same description and provider state does not exist" do
          it "returns nil" do
            subject << interaction_1
            expect(subject.find_matching_description_and_provider_state(interaction_2)).to eq nil
          end
        end

        context "when an interaction with the same description and provider state does exists" do
          it "returns the interaction" do
            subject << interaction_1
            expect(subject.find_matching_description_and_provider_state(interaction_3)).to eq interaction_1
          end
        end
      end
    end
  end
end
