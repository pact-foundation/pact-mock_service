require 'pact/consumer/mock_service/app'
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

  context "when in a cross domain environment (CORS)" do
    let(:app) { Pact::Consumer::MockService.new(log_file: log_file, cors_enabled: true) }
    context "when a request has been mocked" do

      it "answers the OPTIONS request, and then appropiately mocks the actual request" do | example |

        # Clear interactions
        delete "/interactions?example_description=#{CGI::escape(example.full_description)}", nil, admin_headers
        expect(last_response.status).to be 200

        # Set up expected interaction - this would be done by the Pact DSL
        post "/interactions", expected_interaction, admin_headers
        expect(last_response.status).to be 200

        # OPTIONS request from the browser for the request under test
        options '/alligators/new', nil, { 'HTTP_ACCESS_CONTROL_REQUEST_HEADERS' => 'x-pact-mock-service, content-type' }

        # Ensure it allows the browser to actually make the request
        expect(last_response.status).to eq 200
        expect(last_response.headers['Access-Control-Allow-Origin']).to eq '*'
        expect(last_response.headers['Access-Control-Allow-Headers']).to include 'x-pact-mock-service'
        expect(last_response.headers['Access-Control-Allow-Headers']).to include 'content-type'
        expect(last_response.headers['Access-Control-Allow-Methods']).to include "DELETE, POST, GET, HEAD, PUT, TRACE, CONNECT"

        # Make the request
        post "/alligators/new", { id: 123, name: 'Mary'}.to_json , { 'HTTP_ACCEPT' => 'application/json' }

        # Ensure that the response we get back was the one we expected
        # and includes the CORS header
        expect(last_response.headers['Access-Control-Allow-Origin']).to eq '*'
        expect(last_response.headers['Content-Type']).to eq 'application/json'
        expect(JSON.parse(last_response.body)).to eq([{ 'name' => 'Mary' }])

        # GET does not need an OPTIONS request
        get "/interactions/verification?example_description=#{CGI::escape(example.full_description)}", nil, admin_headers
        expect(last_response.status).to eq 200
      end
    end

    context "when the actual request does not match the expected request" do
      it "successfully answers the OPTIONS request, and then returns an error message on the request per say" do | example |
        # Clear interactions - called by the Pact DSL
        delete "/interactions?example_description=#{CGI::escape(example.full_description)}", nil, admin_headers

        # Set up expected interaction - this would be done by the Pact DSL
        post "/interactions", expected_interaction, admin_headers

        # Make the preflight request - this one will not have been created by the user
        options '/alligators/new', nil, { 'HTTP_ACCESS_CONTROL_REQUEST_HEADERS' => 'x-pact-mock-service, content-type' }

        # Ensure it allows the browser to actually make the request
        expect(last_response.status).to eq 200
        expect(last_response.headers['Access-Control-Allow-Origin']).to eq '*'
        expect(last_response.headers['Access-Control-Allow-Headers']).to include 'x-pact-mock-service'
        expect(last_response.headers['Access-Control-Allow-Headers']).to include 'content-type'
        expect(last_response.headers['Access-Control-Allow-Methods']).to include "DELETE, POST, GET, HEAD, PUT, TRACE, CONNECT"

        # Make the request
        post "/alligators/new", { id: 124, name: 'John'}.to_json , { 'HTTP_ACCEPT' => 'application/json' }

        # A 500 is returned as the headers don't match
        # An actual test should fail at this point as the class under test would probably raise an exception
        expect(last_response.status).to eq 500
        expect(last_response.body).to include 'No interaction found'

        # Verification will return an error
        # This would typically be done in an after hook, which should fail the test if it hasn't already failed
        get "/interactions/verification?example_description=#{CGI::escape(example.full_description)}", nil, admin_headers
        expect(last_response.status).to eq 500
        expect(last_response.body).to include 'Actual interactions do not match expected interactions'
      end
    end
  end

  context "when the cors flag is not set" do
    let(:app) { Pact::Consumer::MockService.new(log_file: log_file) }
    context "when a request has been mocked" do

      it "does not mock the OPTIONS response for the request under test" do | example |

        # Clear interactions - this would typically be done in a before hook
        delete "/interactions?example_description=#{CGI::escape(example.full_description)}", nil, admin_headers

        # Set up expected interaction - this would be done by the Pact DSL
        post "/interactions", expected_interaction, admin_headers

        # Make the preflight request - this one will not have been created by the user
        options '/alligators/new', nil, { 'HTTP_ACCESS_CONTROL_REQUEST_HEADERS' => 'x-pact-mock-service, content-type' }
        expect(last_response.status).to eq 500
        expect(last_response.body).to include 'No interaction found'
      end

      it "does not add CORS headers to the response for the request under test" do |example|
        # Clear interactions - this would typically be done in a before hook
        delete "/interactions?example_description=#{CGI::escape(example.full_description)}", nil, admin_headers
        # Set up expected interaction - this would be done by the Pact DSL
        post "/interactions", expected_interaction, admin_headers

        post "/alligators/new", { id: 123, name: 'Mary'}.to_json , { 'HTTP_ACCEPT' => 'application/json' }
        expect(last_response.status).to eq 200
        expect(last_response.headers['Access-Control-Allow-Origin']).to be nil
        expect(last_response.headers['Access-Control-Allow-Headers']).to be nil
        expect(last_response.headers['Access-Control-Allow-Headers']).to be nil
        expect(last_response.headers['Access-Control-Allow-Methods']).to be nil
      end
    end
  end

end
