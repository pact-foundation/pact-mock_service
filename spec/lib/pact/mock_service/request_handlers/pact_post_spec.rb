require 'pact/mock_service/request_handlers/pact_post'

module Pact
  module MockService
    module RequestHandlers
      describe PactPost do

        let(:session) do
          instance_double('Pact::MockService::Session',
            verified_interactions: verified_interactions,
            consumer_contract_details: consumer_contract_details,
            record_pact_written: nil)
        end
        let(:verified_interactions) { double('verified_interactions') }
        let(:consumer_contract_details) do
          {
            some: 'details'
          }
        end
        let(:logger) { double('Logger').as_null_object }
        let(:rack_env) do
          {
            'rack.input' => resquest_body
          }
        end
        let(:resquest_body) { StringIO.new}
        let(:consumer_contract_writer) do
          instance_double('consumer_contract_writer', write: 'pact')
        end

        before do
          allow(ConsumerContractWriter).to receive(:new).and_return(consumer_contract_writer)
        end

        subject { PactPost.new('', logger, session).respond(rack_env) }

        describe "respond" do
          it "records the pact was written" do
            expect(session).to receive(:record_pact_written)
            subject
          end

          context "when there is no request body" do
            it "uses the session consumer_contract_details" do
              expect(ConsumerContractWriter).to receive(:new).with(
                { some: 'details', interactions: verified_interactions },
                logger
              )
              subject
            end
          end

          context "when there is a JSON body" do
            let(:resquest_body) { StringIO.new({some: 'other details'}.to_json)}
            it "merges in the body to the consumer_contract_details" do
              expect(ConsumerContractWriter).to receive(:new).with(
                { some: 'other details', interactions: verified_interactions },
                logger
              )
              subject
            end
          end
        end
      end
    end
  end
end
