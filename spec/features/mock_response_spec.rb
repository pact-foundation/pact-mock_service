require 'pact/consumer/mock_service/app'
require 'rack/test'

describe Pact::Consumer::MockService do

  include Rack::Test::Methods

  let(:app) { Pact::Consumer::MockService.new(log_file: StringIO.new) }

  # NOTE: the admin_headers are Rack headers, they will be converted
  # to X-Pact-Mock-Service and Content-Type by the framework
  let(:admin_headers) { {'HTTP_X_PACT_MOCK_SERVICE' => 'true', 'CONTENT_TYPE' => 'application/json'} }

  let(:expected_interaction) do
    {
      description: "a request for alligators",
      provider_state: "alligators exist",
      request: {
        method: :get,
        path: '/alligators',
        headers: { 'Accept' => 'application/json' },
      },
      response: {
        status: 200,
        headers: { 'Content-Type' => 'application/json' },
        body: [{ name: 'Mary' }]
      }
    }.to_json
  end

  context "when a response has been mocked" do
    context "when the actual request matches the expected request" do
      it "returns the expected response" do
        # Set up expected interaction
        post "/interactions", expected_interaction, admin_headers

        # Invoke the actual request
        get "/alligators", nil, { 'HTTP_ACCEPT' => 'application/json' }

        # Ensure that the response we get back was the one we expected
        expect(last_response.status).to eq 200
        expect(last_response.headers['Content-Type']).to eq 'application/json'
        expect(JSON.parse(last_response.body)).to eq([{ 'name' => 'Mary' }])

        # Verify that all the expected interactions were executed, and no extras were made
        get "/interactions/verification", nil, admin_headers
        expect(last_response.status).to eq 200
      end
    end

    context "when the actual request does not match the expected request" do
      it "returns an error response" do
        # Set up expected interaction
        post "/interactions", expected_interaction, admin_headers

        # Invoke the actual request
        get "/alligators", nil, { 'HTTP_ACCEPT' => 'application/xml' }

        # A 500 is returned as the headers don't match
        expect(last_response.status).to eq 500
        expect(last_response.body).to include 'No interaction found'

        # Verification will be false
        get "/interactions/verification", nil, admin_headers
        expect(last_response.status).to eq 500
        expect(last_response.body).to include 'Actual interactions do not match expected interactions'
      end
    end
  end

end