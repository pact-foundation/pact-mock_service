require 'faraday'
require 'pact/mock_service/server/wait_for_server_up'

module Pact
  module IntegrationTestSupport

    TMP = 'tmp'
    LOG_PATH = 'tmp/integration.log'
    PACT_DIR = 'tmp/pacts'

    def start_server port, options = '', wait = true
      pid = fork do
        exec "bundle exec bin/pact-mock-service --consumer Consumer --provider Provider --port #{port} --host 0.0.0.0 --log tmp/integration.log --pact-dir tmp/pacts #{options}"
      end

      wait_until_server_started(port, /--ssl/ === options) if wait
      pid
    end

    def start_stub_server port, pact_file_path, options = '', wait = true
      pid = fork do
        exec "bundle exec bin/pact-stub-service #{pact_file_path}  --port #{port} --host 0.0.0.0 --log tmp/integration.log #{options}"
      end

      wait_until_server_started(port, /--ssl/ === options) if wait
      pid
    end

    def start_control port, options = ''
      pid = fork do
        exec "bundle exec bin/pact-mock-service control --port #{port} --log-dir tmp/log --pact-dir tmp/pacts #{options}"
      end
      wait_until_server_started port
      pid
    end

    def wait_until_server_started port, ssl = false
      Pact::MockService::Server::WaitForServerUp.(port, {ssl: ssl})
    end

    def kill_server pid
      if pid
        Process.kill "INT", pid
        Process.wait pid
      end
    end

    def clear_dirs
      FileUtils.rm_rf TMP
      FileUtils.mkdir TMP
    end

    def expected_interaction
      {
        description: "a request for a greeting",
        request: {
          method: :get,
          headers: {'Foo' => 'Bar'},
          path: '/greeting'
        },
        response: {
          status: 200,
          headers: { 'Content-Type' => 'text/plain' },
          body: "Hello world"
        }
      }.to_json
    end

    def another_expected_interaction
      {
        description: "another request for a greeting",
        request: {
          method: :get,
          headers: {'Foo' => 'Bar'},
          path: '/another-greeting'
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

    def setup_another_interaction port
      Faraday.post "http://localhost:#{port}/interactions",
        another_expected_interaction,
        mock_service_headers
    end

    def invoke_expected_request port
      Faraday.get "http://localhost:#{port}/greeting",
        nil,
        {'Foo' => 'Bar'}
    end

    def invoke_another_expected_request port
      Faraday.get "http://localhost:#{port}/another-greeting",
        nil,
        {'Foo' => 'Bar'}
    end

    def write_pact port
      Faraday.post "http://localhost:#{port}/pact",
        nil,
        mock_service_headers
    end

    def connect_via_ssl port
      connection = Faraday.new "https://localhost:#{port}", ssl: { verify: false }
      connection.get "/", nil, {'X-Pact-Mock-Service' => 'true'}
    end

    def make_options_request port
      Faraday.run_request :options,
        "http://localhost:#{port}/interactions",
        nil,
        {'Access-Control-Request-Headers' => 'foo'}
    end
  end
end

module Pact
  module ControlServerTestSupport
    include IntegrationTestSupport

    def mock_service_headers
      {
        'Content-Type' => 'application/json',
        'X-Pact-Mock-Service' => 'true',
        'X-Pact-Consumer' => 'Consumer',
        'X-Pact-Provider' => 'Provider'
      }
    end

    def make_options_request port
      Faraday.run_request :options,
        "http://localhost:#{port}/interactions",
        nil,
        {'Access-Control-Request-Headers' => 'foo'}
    end
  end
end
