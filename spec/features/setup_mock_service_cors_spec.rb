require 'pact/consumer/mock_service/app'
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
      it "answsers to OPTIONS for /interactions" do
        # Make the preflight request
        options 'interactions', nil, { 'HTTP_Access_Control_Request_Headers' => 'x-pact-mock-service, application/json' }
        # Ensure it allows the browser to actually make the request
        expect(last_response.status).to eq 200
        expect(last_response.headers['Access-Control-Allow-Origin']).to eq '*'
        expect(last_response.headers['Access-Control-Allow-Headers']).to include 'x-pact-mock-service'
        expect(last_response.headers['Access-Control-Allow-Headers']).to include 'application/json'
        expect(last_response.headers['Access-Control-Allow-Methods']).to include "DELETE, POST, GET, HEAD, PUT, TRACE, CONNECT"
      end

      it "answsers to OPTIONS for /pact" do
        # Make the preflight request
        options '/pact', nil, { 'HTTP_Access_Control_Request_Headers' => 'x-pact-mock-service, application/json' }
        # Ensure it allows the browser to actually make the request
        expect(last_response.status).to eq 200
        expect(last_response.headers['Access-Control-Allow-Origin']).to eq '*'
        expect(last_response.headers['Access-Control-Allow-Headers']).to include 'x-pact-mock-service'
        expect(last_response.headers['Access-Control-Allow-Headers']).to include 'application/json'
        expect(last_response.headers['Access-Control-Allow-Methods']).to include "DELETE, POST, GET, HEAD, PUT, TRACE, CONNECT"
      end

      it "includes the CORS headers on the system interactions" do |example|
        # Clear interactions - this would typically be done in a before hook
        delete "/interactions?example_description=#{CGI::escape(example.full_description)}", nil, admin_headers
        expect(last_response.headers['Access-Control-Allow-Origin']).to eq '*'

        # Set up expected interaction - this would be done by the Pact DSL
        post "/interactions", expected_interaction, admin_headers
        expect(last_response.headers['Access-Control-Allow-Origin']).to eq '*'

        # Make the preflight request - this one will not have been created by the user
        options '/alligators/new', nil, { 'HTTP_Access_Control_Request_Headers' => 'x-pact-mock-service, application/json' }

        # Make the user request
        post "/alligators/new", { id: 123, name: 'Mary'}.to_json , { 'HTTP_ACCEPT' => 'application/json' }

        post "/pact", pact_details, admin_headers
        expect(last_response.headers['Access-Control-Allow-Origin']).to eq '*'
        expect(pact_json['interactions']).to_not be_empty

        # Verify that all the expected interactions were executed
        get "/interactions/verification?example_description=#{CGI::escape(example.full_description)}", nil, admin_headers
        expect(last_response.headers['Access-Control-Allow-Origin']).to eq '*'
      end
    end
  end
end
