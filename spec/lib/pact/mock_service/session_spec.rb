require 'pact/mock_service/session'

module Pact::MockService

  describe Session do

    let(:logger) { double('Logger').as_null_object }

    describe "set_expected_interactions" do

      let(:interaction_1) { InteractionFactory.create }
      let(:interaction_2) { InteractionFactory.create }
      let(:interactions) { [interaction_1, interaction_2] }
      let(:expected_interactions) { instance_double('Interactions::ExpectedInteractions', clear: nil, :<< => nil) }
      let(:actual_interactions) { instance_double('Interactions::ActualInteractions', clear: nil) }

      before do
        allow(Interactions::ExpectedInteractions).to receive(:new).and_return(expected_interactions)
        allow(Interactions::ActualInteractions).to receive(:new).and_return(actual_interactions)
      end

      subject { Session.new(logger: logger).set_expected_interactions interactions }

      it "clears the expected interactions" do
        expect(expected_interactions).to receive(:clear)
        subject
      end

      it "clears the actual interactions" do
        expect(actual_interactions).to receive(:clear)
        subject
      end

      it "adds the new expected interactions" do
        expect(expected_interactions).to receive(:<<).with(interaction_1)
        expect(expected_interactions).to receive(:<<).with(interaction_2)
        subject
      end

    end

    describe "clear_all" do

      let(:expected_interactions) { instance_double('Interactions::ExpectedInteractions', clear: nil, :<< => nil) }
      let(:actual_interactions) { instance_double('Interactions::ActualInteractions', clear: nil) }
      let(:verified_interactions) { instance_double('Interactions::VerifiedInteractions', clear: nil) }

      before do
        allow(Interactions::ExpectedInteractions).to receive(:new).and_return(expected_interactions)
        allow(Interactions::ActualInteractions).to receive(:new).and_return(actual_interactions)
        allow(Interactions::VerifiedInteractions).to receive(:new).and_return(verified_interactions)
      end

      subject { Session.new(logger: logger).clear_all }

      it "clears the expected interactions" do
        expect(expected_interactions).to receive(:clear)
        subject
      end

      it "clears the actual interactions" do
        expect(actual_interactions).to receive(:clear)
        subject
      end

      it "clears the verified interactions" do
        expect(verified_interactions).to receive(:clear)
        subject
      end

    end

    describe "add_expected_interaction" do
      let(:interaction_1) { InteractionFactory.create }
      let(:interaction_2) { InteractionFactory.create }
      let(:expected_interactions) { instance_double('Interactions::ExpectedInteractions', :<< => nil) }
      let(:actual_interactions) { instance_double('Interactions::ActualInteractions') }
      let(:verified_interactions) { instance_double('Interactions::VerifiedInteractions') }

      before do
        allow(Interactions::ExpectedInteractions).to receive(:new).and_return(expected_interactions)
        allow(Interactions::ActualInteractions).to receive(:new).and_return(actual_interactions)
        allow(Interactions::VerifiedInteractions).to receive(:new).and_return(verified_interactions)
        allow(verified_interactions).to receive(:find_matching_description_and_provider_state).and_return(matching_interaction)
      end

      subject { Session.new(logger: logger) }

      context "when there is no already verified interaction with the same description and provider state" do
        let(:matching_interaction) { nil }

        it "adds the new interaction to the interaction list" do
          expect(expected_interactions).to receive(:<<).with(interaction_1)
          subject.add_expected_interaction interaction_1
        end
      end

      context "when there is an identical already verified interaction" do
        let(:matching_interaction) { interaction_2 }

        before do
          allow(interaction_2).to receive(:!=).and_return(false)
        end

        it "adds the new interaction to the interaction list" do
          expect(expected_interactions).to receive(:<<).with(interaction_1)
          subject.add_expected_interaction interaction_1
        end
      end

      context "when there is an already verified interaction with the same description and provider state, but a different request or response" do

        let(:diff_message) { 'a diff message'}
        let(:matching_interaction) { interaction_2 }

        before do
          allow(interaction_2).to receive(:!=).and_return(true)
          allow_any_instance_of(Interactions::InteractionDiffMessage).to receive(:to_s).and_return(diff_message)
        end

        it "does not add the new interaction to the interaction list" do
          expect(expected_interactions).to_not receive(:<<).with(interaction_1)
          begin
            subject.add_expected_interaction interaction_1
          rescue SameSameButDifferentError
          end
        end

        it "raises an SameSameButDifferentError" do
          expect { subject.add_expected_interaction interaction_1 }.to raise_error SameSameButDifferentError, diff_message
        end
      end
    end
  end
end
