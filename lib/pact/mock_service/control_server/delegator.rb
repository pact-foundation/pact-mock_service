# Delegates the incoming request that was sent to the control server
# to the underlying MockService
# if the X-Pact-Consumer and X-Pact-Provider headers match
# the consumer and provider for this MockService.

module Pact
  module MockService
    module ControlServer

      class Delegator

        HTTP_X_PACT_CONSUMER = 'HTTP_X_PACT_CONSUMER'.freeze
        HTTP_X_PACT_PROVIDER = 'HTTP_X_PACT_PROVIDER'.freeze
        LOCATION = 'X-Pact-Mock-Service-Location'.freeze
        PACT_MOCK_SERVICE_HEADER = {'HTTP_X_PACT_MOCK_SERVICE' => 'true'}.freeze
        NOT_FOUND_RESPONSE = [404, {}, []].freeze

        def initialize app, base_url, consumer_name, provider_name
          @app = app
          @base_url = base_url
          @consumer_name = consumer_name
          @provider_name = provider_name
          @location_header = {LOCATION => @base_url}.freeze
        end

        def call env
          return NOT_FOUND_RESPONSE unless consumer_and_provider_headers_match?(env)
          delegate env
        end

        def shutdown
          @app.shutdown
        end

        private

        def consumer_and_provider_headers_match? env
          env[HTTP_X_PACT_CONSUMER] == @consumer_name && env[HTTP_X_PACT_PROVIDER] == @provider_name
        end

        def delegate env
          add_location_header_to_response(call_app(env))
        end

        def call_app env
          @app.call(env.merge(PACT_MOCK_SERVICE_HEADER))
        end

        def add_location_header_to_response response
          [response.first, response[1].merge(@location_header), response.last]
        end
      end
    end
  end
end
