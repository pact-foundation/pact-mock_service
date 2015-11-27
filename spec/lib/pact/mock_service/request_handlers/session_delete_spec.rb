require 'spec_helper'
require 'pact/mock_service/request_handlers/session_delete'

module Pact
  module MockService
    module RequestHandlers

      describe SessionDelete do

        let(:session) { instance_double('Pact::MockService::Session', clear_all: nil)}
        let(:logger) { double('Logger').as_null_object }
        let(:rack_env) do
          {}
        end

        subject { SessionDelete.new '', logger, session }

        it "clears the entire session" do
          expect(session).to receive(:clear_all)
          subject.respond rack_env
        end

      end
    end
  end
end
