require 'pact/mock_service/interactions/interaction_diff_message'

module Pact::MockService::Interactions
  describe InteractionDiffMessage do
    let(:interaction_1) { InteractionFactory.create }
    let(:interaction_2) { InteractionFactory.create 'request' => {'headers' => {'foo' => 'bar'}, 'query' => 'foo=bar'}, 'response' => {'status' => 400} }

    subject { InteractionDiffMessage.new(interaction_1, interaction_2).to_s }

    describe "to_s" do
      it "returns a message indicating that an interaction with the same description and provider state already exists" do
        expect(subject).to include "different request query, request headers and response status has"
      end
    end
  end
end
