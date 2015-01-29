require 'spec_helper'
require 'pact/mock_service/request_handlers/interaction_delete'

module Pact
  module MockService
    module RequestHandlers

      describe InteractionDelete do

        let(:session) { instance_double('Pact::MockService::Session', clear_expected_and_actual_interactions: nil)}
        let(:logger) { double('Logger').as_null_object }
        let(:rack_env) do
          {
            'QUERY_STRING' => 'example_description=a+description'
          }
        end

        subject { InteractionDelete.new '', logger, session }


        it "clears the expected and actual interactions" do
          expect(session).to receive(:clear_expected_and_actual_interactions)
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
