require 'pact/mock_service/app'
require 'rack/test'

describe Pact::Consumer::MockService do

  include Rack::Test::Methods

  MULTIPLE_LOG_PATH = File.join File.dirname(__FILE__), 'log', 'mock_multiple_responses_spec.log'

  before :all do
    FileUtils.rm MULTIPLE_LOG_PATH
  end

  let(:log_file) { File.open MULTIPLE_LOG_PATH, 'a' }
  let(:log_formatter_without_date) do
    proc { |severity, datetime, progname, msg| severity + " -- : " + msg + "\n" }
  end
  let(:app) do
    Pact::MockService.new(log_file: log_file, log_formatter: log_formatter_without_date)
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
    }.to_json
  end

  context "when more than one response has been mocked" do
    context "when the actual request matches one expected request" do

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
        }.to_json
      end

      it "returns the expected response" do | example |
        # Clear interactions - this would typically be done in a before hook
        delete "/interactions?example_description=#{CGI::escape(example.full_description)}", nil, admin_headers

        # Set up expected interaction - this would be done by the Pact DSL
        post "/interactions", expected_interaction, admin_headers

        # Set up another expected interaction - this would be done by the Pact DSL
        post "/interactions", another_expected_interaction, admin_headers

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

    context "when the actual request matches more than one expected request" do

      let(:another_expected_interaction) do
        {
          description: "a request for alligators",
          provider_state: "there are no alligators",
          request: {
            method: :get,
            path: '/alligators',
            headers: { 'Accept' => 'application/json' },
          },
          response: {
            status: 200,
            headers: { 'Content-Type' => 'application/json' },
            body: []
          }
        }.to_json
      end

      it "returns an error response" do | example |
        # Clear interactions - this would typically be done in a before hook
        delete "/interactions?example_description=#{CGI::escape(example.full_description)}", nil, admin_headers

        # Set up expected interaction - this would be done by the Pact DSL
        post "/interactions", expected_interaction, admin_headers

        # Set up another expected interaction - this would be done by the Pact DSL
        post "/interactions", another_expected_interaction, admin_headers

        # Invoke the actual request - this would be done by the class under test
        get "/alligators", nil, { 'HTTP_ACCEPT' => 'application/json' }

        # A 500 is returned as both interactions match the actual request
        # An actual test should fail at this point as the class under test would probably raise an exception
        expect(last_response.status).to eq 500
        expect(last_response.body).to include 'Multiple interaction found'

        # Verification will return an error
        # This would typically be done in an after hook, which should fail the test if it hasn't already failed
        get "/interactions/verification?example_description=#{CGI::escape(example.full_description)}", nil, admin_headers
        expect(last_response.status).to eq 500
        expect(last_response.body).to include 'Actual interactions do not match expected interactions'
      end
    end
  end
end
