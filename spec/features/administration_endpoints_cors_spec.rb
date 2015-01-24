require 'pact/consumer/mock_service'
require 'rack/test'
require 'cgi'

describe Pact::Consumer::MockService do

  include Rack::Test::Methods

  SETUP_MOCK_SERVICE_CORS_LOG_PATH = File.join File.dirname(__FILE__), 'log', 'setup_mock_service_cors_spec.log'

  before :all do
    FileUtils.rm SETUP_MOCK_SERVICE_CORS_LOG_PATH if File.exist?(SETUP_MOCK_SERVICE_CORS_LOG_PATH)
  end

  let(:log_file) { File.open SETUP_MOCK_SERVICE_CORS_LOG_PATH, 'a' }
  let(:app) { Pact::Consumer::MockService.new(log_file: log_file, pact_dir: pact_dir)  }

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

  let(:pact_details) do
    {
        consumer: { name: 'A Consumer'},
        provider: { name: 'A Provider'},
    }.to_json
  end
  let(:pact_dir) { './tmp/pacts' }
  let(:pact_file_path) { File.join(pact_dir, "a_consumer-a_provider.json") }
  let(:pact_json) { JSON.parse(File.read(pact_file_path)) }

  before do
    FileUtils.rm_rf pact_dir
    FileUtils.mkdir_p pact_dir
  end


  context "when in a cross domain environment (CORS)" do
    context "pact mock service is setup" do

      it "responds to OPTIONS for /interactions" do
        options 'interactions', nil, { 'HTTP_ACCESS_CONTROL_REQUEST_HEADERS' => 'X-Pact-Mock-Service, Content-Type' }
        expect(last_response.status).to eq 200
        expect(last_response.headers['Access-Control-Allow-Origin']).to eq '*'
        expect(last_response.headers['Access-Control-Allow-Headers']).to include 'X-Pact-Mock-Service'
        expect(last_response.headers['Access-Control-Allow-Headers']).to include 'Content-Type'
        expect(last_response.headers['Access-Control-Allow-Methods']).to include "DELETE, POST, GET, HEAD, PUT, TRACE, CONNECT"
      end

      it "responds to OPTIONS for /pact" do
        options '/pact', nil, { 'HTTP_ACCESS_CONTROL_REQUEST_HEADERS' => 'X-Pact-Mock-Service, Content-Type' }
        expect(last_response.status).to eq 200
        expect(last_response.headers['Access-Control-Allow-Origin']).to eq '*'
        expect(last_response.headers['Access-Control-Allow-Headers']).to include 'X-Pact-Mock-Service'
        expect(last_response.headers['Access-Control-Allow-Headers']).to include 'Content-Type'
        expect(last_response.headers['Access-Control-Allow-Methods']).to include "DELETE, POST, GET, HEAD, PUT, TRACE, CONNECT"
      end

      it "ignores the case of the HTTP-Access-Control-Request-Headers value" do
        options '/pact', nil, { 'HTTP_ACCESS_CONTROL_REQUEST_HEADERS' => 'x-pact-mock-service' }
        expect(last_response.status).to eq 200
        expect(last_response.headers['Access-Control-Allow-Origin']).to eq '*'
        expect(last_response.headers['Access-Control-Allow-Headers']).to include 'x-pact-mock-service'
        expect(last_response.headers['Access-Control-Allow-Methods']).to include "DELETE, POST, GET, HEAD, PUT, TRACE, CONNECT"
      end

      it "includes the CORS headers in the response to DELETE /interactions" do | example |
        delete "/interactions", nil, admin_headers
        expect(last_response.headers['Access-Control-Allow-Origin']).to eq '*'
      end

      it "includes the CORS headers in the response to POST /interactions" do | example |
        post "/interactions", expected_interaction, admin_headers
        expect(last_response.headers['Access-Control-Allow-Origin']).to eq '*'
      end

      it "includes the CORS headers in the response to POST /pact" do | example |
        post "/pact", pact_details, admin_headers
        expect(last_response.headers['Access-Control-Allow-Origin']).to eq '*'
      end

      it "includes the CORS headers in the response to GET /interactions/verification" do | example |
        get "/interactions/verification", nil, admin_headers
        expect(last_response.headers['Access-Control-Allow-Origin']).to eq '*'
      end

      context "when the Origin header is set" do
        it "sets the Access-Control-Allow-Origin header to be the Origin" do
          options '/pact', nil, { 'HTTP_ACCESS_CONTROL_REQUEST_HEADERS' => 'X-Pact-Mock-Service, Content-Type', 'HTTP_ORIGIN' => 'http://localhost:1234' }
          expect(last_response.headers['Access-Control-Allow-Origin']).to eq 'http://localhost:1234'
        end
      end
    end
  end
end
