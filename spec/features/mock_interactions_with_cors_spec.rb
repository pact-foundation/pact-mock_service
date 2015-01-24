require 'pact/consumer/mock_service'
require 'rack/test'
require 'cgi'

describe Pact::Consumer::MockService do

  include Rack::Test::Methods

  CORS_LOG_PATH = File.join File.dirname(__FILE__), 'log', 'mock_cors_spec.log'

  before :all do
    FileUtils.rm CORS_LOG_PATH if File.exist?(CORS_LOG_PATH)
  end

  let(:log_file) { File.open CORS_LOG_PATH, 'a' }

  # NOTE: the admin_headers are Rack headers, they will be converted
  # to X-Pact-Mock-Service and Content-Type by the framework
  let(:admin_headers) { {'HTTP_X_PACT_MOCK_SERVICE' => 'true', 'CONTENT_TYPE' => 'application/json'} }

  let(:expected_interaction) do
    {
      description: "a request for alligators",
      provider_state: "alligators exist",
      request: {
        method: :post,
        path: '/alligators/new',
        headers: { 'Accept' => 'application/json' },
        body: { id: 123, name: 'Mary'}.to_json
      },
      response: {
        status: 200,
        headers: { 'Content-Type' => 'application/json' },
        body: [{ name: 'Mary' }]
      }
    }.to_json
  end

  let(:actual_request) do
    {
      id: 123,
      name: 'Mary'
    }.to_json
  end

  context "when in a cross domain environment (CORS)" do
    let(:app) { Pact::Consumer::MockService.new(log_file: log_file, cors_enabled: true) }
    context "when a request has been mocked" do

      it "answers the OPTIONS request, and then appropiately mocks the actual request" do | example |
        # The browser would be sending OPTIONS requests for the mock service administration endpoints as well,
        # however, for clarity, those requests are tested elsewhere.

        # Set up expected interaction - this would be done by the Pact DSL
        post "/interactions", expected_interaction, admin_headers
        expect(last_response.status).to be 200

        # OPTIONS request from the browser for the request under test
        options '/alligators/new', nil, { 'HTTP_ACCESS_CONTROL_REQUEST_HEADERS' => 'accept', 'HTTP_ORIGIN' => 'http://localhost:1234' }

        # Ensure it allows the browser to actually make the request
        expect(last_response.status).to eq 200
        expect(last_response.headers['Access-Control-Allow-Origin']).to eq 'http://localhost:1234'
        expect(last_response.headers['Access-Control-Allow-Headers']).to include 'accept'
        expect(last_response.headers['Access-Control-Allow-Methods']).to include "DELETE, POST, GET, HEAD, PUT, TRACE, CONNECT"

        # Make the request
        post "/alligators/new", actual_request, { 'HTTP_ACCEPT' => 'application/json', 'HTTP_ORIGIN' => 'http://localhost:1234' }

        # Ensure that the response we get back was the one we expected
        # and includes the CORS header
        expect(last_response.headers['Access-Control-Allow-Origin']).to eq 'http://localhost:1234'
        expect(last_response.headers['Content-Type']).to eq 'application/json'
        expect(JSON.parse(last_response.body)).to eq([{ 'name' => 'Mary' }])
      end
    end
  end

  context "when the CORS flag is not set" do
    let(:app) { Pact::Consumer::MockService.new(log_file: log_file) }
    context "when a request has been mocked" do

      it "does not mock the OPTIONS response for the request under test" do | example |
        post "/interactions", expected_interaction, admin_headers
        options '/alligators/new', nil, { 'HTTP_ACCESS_CONTROL_REQUEST_HEADERS' => 'accept' }
        expect(last_response.status).to eq 500
        expect(last_response.body).to include 'No interaction found'
      end

      it "does not add CORS headers to the response for the request under test" do |example|
        post "/interactions", expected_interaction, admin_headers
        post "/alligators/new", actual_request, { 'HTTP_ACCEPT' => 'application/json' }
        expect(last_response.status).to eq 200
        expect(last_response.headers['Access-Control-Allow-Origin']).to be nil
        expect(last_response.headers['Access-Control-Allow-Headers']).to be nil
        expect(last_response.headers['Access-Control-Allow-Headers']).to be nil
        expect(last_response.headers['Access-Control-Allow-Methods']).to be nil
      end
    end
  end
end
