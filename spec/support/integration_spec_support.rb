require 'faraday'
require 'pact/mock_service/wait_for_server_up'

module Pact
  module IntegrationTestSupport

    TMP = 'tmp'
    LOG_PATH = 'tmp/integration.log'
    PACT_DIR = 'tmp/pacts'

    def wait_until_server_started port
      Pact::MockService::WaitForServerUp.(port)
    end

    def clear_dirs
      FileUtils.rm_rf TMP
    end

    def expected_interaction
      {
        description: "a request for a greeting",
        request: {
          method: :get,
          path: '/greeting'
        },
        response: {
          status: 200,
          headers: { 'Content-Type' => 'text/plain' },
          body: "Hello world"
        }
      }.to_json
    end

    def mock_service_headers
      {
        'Content-Type' => 'application/json',
        'X-Pact-Mock-Service' => 'true'
      }
    end

    def pact_details
      {
        consumer: { name: 'Consumer' },
        provider: { name: 'Provider' }
      }.to_json
    end

    def setup_interaction port
      Faraday.post "http://localhost:#{port}/interactions",
        expected_interaction,
        mock_service_headers
    end

    def invoke_expected_request port
      Faraday.get "http://localhost:#{port}/greeting"
    end

    def write_pact port
      Faraday.post "http://localhost:#{port}/pact",
        pact_details,
        mock_service_headers
    end

    def connect_via_ssl port
      connection = Faraday.new "https://localhost:#{port}", ssl: { verify: false }
      connection.delete "/interactions", nil, {'X-Pact-Mock-Service' => 'true'}
    end
  end
end
