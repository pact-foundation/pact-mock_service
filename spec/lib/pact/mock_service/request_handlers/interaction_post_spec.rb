require 'pact/mock_service/request_handlers/interaction_post'

module Pact
  module MockService
    module RequestHandlers
      describe InteractionPost do
        let(:session) { instance_double('Pact::MockService::Session') }
        let(:logger) { double('Logger').as_null_object }
        let(:interaction_json) {
          {
            description: "some description",
            provider_state: "some state",
            request: { method: "put", path: "/" },
            response: { status: 200, headers: {} }
          }.to_json
        }

        let(:rack_env) do
          {
            'rack.input' => StringIO.new(interaction_json)
          }
        end

        subject { described_class.new '', logger, session }

        context "adding the interaction will raise SameSameButDifferentError" do
          let(:message) { "my message" }

          before(:each) do
            allow(session).to receive(:add_expected_interaction).and_raise(SameSameButDifferentError.new(message))
          end

          it "has 500 status" do
            status, _, _ = subject.respond(rack_env)
            expect(status).to eq(500)
          end

          it "returns a valid rack response with an error message" do
            _, _, body_iterable = subject.respond(rack_env)
            expect(body_iterable).to respond_to(:each)
            expect(body_iterable.join).to eq(message)
          end
        end
      end
    end
  end
end
