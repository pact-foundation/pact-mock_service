require 'pact/mock_service/app'
require 'rack/test'
require 'cgi'

describe Pact::Consumer::MockService do

  include Rack::Test::Methods

  let(:app) do
    Pact::MockService.new(pact_dir: 'tmp/pacts', log_file: StringIO.new)
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

  let(:pact_details) do
    {
      consumer: {name: 'Consumer'},
      provider: {name: 'Provider'}
    }.to_json
  end

  context "when an interaction is mocked that is an exact duplicate of one that has already been verified" do

    it "only writes one interaction to the pact file" do | example |
      # First time
      delete "/interactions?example_description=#{CGI::escape(example.full_description)}", nil, admin_headers
      post "/interactions", expected_interaction, admin_headers
      get "/greeting"
      expect(last_response.status).to eq 200

      # Second time in a different "test" with identical interaction
      delete "/interactions?example_description=#{CGI::escape(example.full_description)}", nil, admin_headers
      post "/interactions", expected_interaction, admin_headers
      expect(last_response.status).to eq 200
      get "/greeting"
      expect(last_response.status).to eq 200

      # Assert only one interaction written to pact
      post "/pact", pact_details, admin_headers
      expect(JSON.parse(last_response.body)['interactions'].size).to eq 1
    end
  end

  context "when an interaction is mocked that has the same description and provider state, but that has some other difference from one that has already been verified" do

    let(:slightly_different_expected_interaction) do
      {
        description: "a request for a greeting",
        provider_state: "someone is talking to us",
        request: {
          method: :get, path: '/greeting'
        },
        response: {
          status: 200, body: "Hello other world"
        }
      }.to_json
    end

    it "returns an error response" do | example |
      # First time
      delete "/interactions?example_description=#{CGI::escape(example.full_description)}", nil, admin_headers
      post "/interactions", expected_interaction, admin_headers
      get "/greeting"
      expect(last_response.status).to eq 200

      # Second time with same description and provider state, but different response
      delete "/interactions?example_description=#{CGI::escape(example.full_description)}", nil, admin_headers
      post "/interactions", slightly_different_expected_interaction, admin_headers
      expect(last_response.status).to eq 500
      expect(last_response.body).to include "An interaction with same description"
    end
  end

end
