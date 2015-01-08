require 'pact/mock_service/run'
require 'pact/mock_service/control_server/delegator'
require 'find_a_port'

module Pact
  module MockService
    module ControlServer

      class MockServiceCreator

        attr_reader :options

        def initialize mock_services, options
          @mock_services = mock_services
          @options = options
        end

        def call env
          consumer_name = env['HTTP_X_PACT_CONSUMER']
          provider_name = env['HTTP_X_PACT_PROVIDER']
          port = FindAPort.available_port
          mock_service = Pact::MockService::Run.(consumer_name, provider_name, port, options)
          delegator = Delegator.new(mock_service, "http://localhost:#{port}", consumer_name, provider_name)
          @mock_services.add(delegator)
          delegator.call(env)
        end
      end
    end
  end
end
