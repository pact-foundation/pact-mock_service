require 'pact/mock_service/app'
require 'rack/test'

describe Pact::Consumer::MockService do

  include Rack::Test::Methods

  let(:log) {  StringIO.new }
  let(:app) do
    Pact::MockService.new(log_file: log)
  end

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
    }
  end

  let(:another_expected_interaction) do
    {
      description: "a request for zebras",
      provider_state: "there are zebras",
      request: {
        method: :get,
        path: '/zebras',
        headers: { 'Accept' => 'application/json' },
      },
      response: {
        status: 200,
        headers: { 'Content-Type' => 'application/json' },
        body: [{ name: 'Xena Zebra' }]
      }
    }
  end

  let(:interactions) do
    {
      example_description: 'example_description',
      interactions: [expected_interaction, another_expected_interaction]
    }.to_json
  end

  context "when more than one response has been mocked" do
    context "when the actual request matches one expected request" do

      it "returns the expected response" do | example |

        # Set up expected interaction - this would be done by the Pact DSL
        put "/interactions", interactions, admin_headers

        # Invoke the actual request - this would be done by the class under test
        get "/alligators", nil, { 'HTTP_ACCEPT' => 'application/json' }

        # Ensure that the response we get back was the one we expected
        # A test using pact would normally check the object returned from the class under test
        # eg. expect(client.alligators).to eq [Alligator.new(name: 'Mary')]
        expect(last_response.status).to eq 200
        expect(last_response.headers['Content-Type']).to eq 'application/json'
        expect(JSON.parse(last_response.body)).to eq([{ 'name' => 'Mary' }])

        # Invoke the /zebras request - this would be done by the class under test
        get "/zebras", nil, { 'HTTP_ACCEPT' => 'application/json' }

        # Ensure we got the zebra response back
        expect(JSON.parse(last_response.body)).to eq([{ 'name' => 'Xena Zebra' }])

        # Verify
        # This would typically be done in an after hook
        get "/interactions/verification?example_description=#{CGI::escape(example.full_description)}", nil, admin_headers
        expect(last_response.status).to eq 200
      end
    end
  end
end
