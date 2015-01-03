require 'pact/consumer/mock_service/interaction_post'

module Pact
  module Consumer
    describe InteractionPost do

      let(:verified_interactions) { double('Pact::Consumer::VerifiedInteractions') }
      let(:interaction_list) { double('Pact::Consumer::InteractionList') }
      let(:logger) { double('Logger').as_null_object }
      let(:interaction_1) { InteractionFactory.create }
      let(:interaction_2) { InteractionFactory.create }
      let(:rack_env) do
        {
          'rack.input' => StringIO.new('{}')
        }
      end

      before do
        allow(Interaction).to receive(:from_hash).and_return(interaction_1)
        allow(interaction_list).to receive(:add)
      end

      subject { InteractionPost.new('', logger, interaction_list, verified_interactions) }

      context "when there is no already verified interaction with the same description and provider state" do
        before do
          allow(verified_interactions).to receive(:find_matching_description_and_provider_state).and_return(nil)
        end

        it "adds the new interaction to the interaction list" do
          expect(interaction_list).to receive(:add).with(interaction_1)
          subject.respond rack_env
        end

        it "returns a 200 response" do
          expect(subject.respond(rack_env).first).to eq 200
        end
      end

      context "when there is an identical already verified interaction" do
        before do
          allow(verified_interactions).to receive(:find_matching_description_and_provider_state).and_return(interaction_2)
          allow(interaction_2).to receive(:!=).and_return(false)
        end

        it "adds the new interaction to the interaction list" do
          expect(interaction_list).to receive(:add).with(interaction_1)
          subject.respond rack_env
        end

        it "returns a 200 response" do
          expect(subject.respond(rack_env).first).to eq 200
        end
      end

      context "when there is an already verified interaction with the same description and provider state, but a different request or response" do
        before do
          allow(verified_interactions).to receive(:find_matching_description_and_provider_state).and_return(interaction_2)
          allow(interaction_2).to receive(:!=).and_return(true)
        end

        it "does not add the new interaction to the interaction list" do
          expect(interaction_list).to_not receive(:add).with(interaction_1)
          subject.respond rack_env
        end

        it "returns a 500 response" do
          expect(subject.respond(rack_env).first).to eq 500
        end
      end
    end
  end
end
