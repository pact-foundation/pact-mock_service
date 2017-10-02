require 'pact/mock_service/interactions/interactions_filter'

module Pact
  module MockService
    module Interactions
      describe MergingInteractionsFilter do
        let(:existing_interaction) do
          InteractionFactory.create
        end

        let(:existing_interactions) do
          [existing_interaction]
        end

        subject { MergingInteractionsFilter.new(existing_interactions) << new_interaction }

        context "when an existing identical interaction exists" do
          let(:new_interaction) do
            InteractionFactory.create
          end

          it "does not add the new interaction" do
            subject
            expect(existing_interactions.size).to eq 1
          end
        end

        context "when an interaction exists with the same provider state and description but has some other difference" do
          before do
            allow(Interactions::InteractionDiffMessage).to receive(:new).and_return("message")
          end

          let(:new_interaction) do
            InteractionFactory.create(request: {path: '/a/different/path'})
          end

          it "creates an error message" do
            expect(Interactions::InteractionDiffMessage).to receive(:new).with(existing_interaction, new_interaction)
            subject rescue SameSameButDifferentError
          end

          it "raises an exception" do
            expect { subject }.to raise_error SameSameButDifferentError, "message"
          end
        end

        context "when an interaction with the same provider state and description does not exist" do
          let(:new_interaction) do
            InteractionFactory.create(description: 'different desc')
          end

          it "adds the interaction" do
            subject
            expect(existing_interactions.size).to eq 2
          end
        end
      end
    end
  end
end
