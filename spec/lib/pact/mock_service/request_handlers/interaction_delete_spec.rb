require 'spec_helper'
require 'pact/mock_service/request_handlers/interaction_delete'

module Pact
  module MockService
    module RequestHandlers

      describe InteractionDelete do

        let(:actual_interactions) { double('Pact::Consumer::ActualInteractions') }
        let(:expected_interactions) { double('Pact::Consumer::ExpectedInteractions') }
        let(:logger) { double('Logger').as_null_object }
        let(:rack_env) do
          {
            'QUERY_STRING' => 'example_description=a+description'
          }
        end

        before do
          allow(expected_interactions).to receive(:clear)
          allow(actual_interactions).to receive(:clear)
        end

        subject { InteractionDelete.new '', logger, expected_interactions, actual_interactions }


        it "clears the expected interactions" do
          expect(expected_interactions).to receive(:clear)
          subject.respond rack_env
        end

        it "clears the actual interactions" do
          expect(actual_interactions).to receive(:clear)
          subject.respond rack_env
        end

        it "logs a message" do
          expect(logger).to receive(:info).with(/Cleared interactions.*a description/)
          subject.respond rack_env
        end
      end
    end
  end
end
