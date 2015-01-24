require 'faraday'
require 'pact/mock_service/server/wait_for_server_up'

module Pact
  module IntegrationTestSupport

    TMP = 'tmp'
    LOG_PATH = 'tmp/integration.log'
    PACT_DIR = 'tmp/pacts'

    def start_server port, options = '', wait = true
      FileUtils.rm_rf 'tmp'
      pid = fork do
        exec "bundle exec bin/pact-mock-service --port #{port} --log tmp/integration.log --pact-dir tmp/pacts #{options}"
      end

      wait_until_server_started(port) if wait
      pid
    end

    def start_control port, options = ''
      FileUtils.rm_rf 'tmp'
      pid = fork do
        exec "bundle exec bin/pact-mock-service control --port #{port} --log-dir tmp/log --pact-dir tmp/pacts #{options}"
      end
      wait_until_server_started port
      pid
    end

    def wait_until_server_started port
      Pact::MockService::Server::WaitForServerUp.(port)
    end

    def wait_until_server_started_on_ssl port
      tries = 0
      begin
        connect_via_ssl port
      rescue Faraday::ConnectionFailed => e
        sleep 0.1
        tries += 1
        retry if tries < 100
        raise "Could not connect to server"
      end
    end

    def kill_server pid
      if pid
        Process.kill "INT", pid
        Process.wait pid
      end
    end

    def clear_dirs
      FileUtils.rm_rf TMP
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
      Faraday.get "http://localhost:#{port}/greeting",
        nil,
        {'Foo' => 'Bar'}
    end

    def write_pact port
      Faraday.post "http://localhost:#{port}/pact",
        pact_details,
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
