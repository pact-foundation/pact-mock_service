require 'pact/mock_service/app'
require 'rack/test'
require 'cgi'

describe Pact::Consumer::MockService do

  include Rack::Test::Methods

  let(:app) do
    Pact::MockService.new(pact_dir: 'tmp/pacts', log_file: StringIO.new, pact_specification_version: "2")
  end

  # NOTE: the admin_headers are Rack headers, they will be converted
  # to X-Pact-Mock-Service and Content-Type by the framework
  let(:admin_headers) { {'HTTP_X_PACT_MOCK_SERVICE' => 'true', 'CONTENT_TYPE' => 'application/json'} }

  let(:expected_interaction) do
    {
      description: "a request for a greeting",
      provider_state: "someone is talking to us",
      request: {
        method: :get, path: '/greeting'
      },
      response: {
        status: 200, body: "Hello world"
      }
    }.to_json
  end

  context "when some expected interactions have not been executed" do
    context "/interactions/missing" do
      it "returns the number of missing interactions so we can poll to determine when the test is finished" do | example |
        post "/interactions", expected_interaction, admin_headers
        get "/interactions/missing", nil, admin_headers
        expect(JSON.parse(last_response.body)['size']).to eq 1
      end
    end
  end
end
