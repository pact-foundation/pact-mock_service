# Delegates the incoming request for the control server
# to the underlying mock service for the given consumer and provider

module Pact
  module MockService
    module ControlServer

      class Delegator

        def initialize app, base_url, consumer_name, provider_name
          @app = app
          @base_url = base_url
          @consumer_name = consumer_name
          @provider_name = provider_name
        end

        def call env
          return [404, {}, []] unless consumer_and_provider_headers_match?(env)
          delegate env
        end

        def shutdown
          @app.shutdown
        end

        private

        def consumer_and_provider_headers_match? env
          env['HTTP_X_PACT_CONSUMER'] == @consumer_name && env['HTTP_X_PACT_PROVIDER'] == @provider_name
        end

        def delegate env
          response = @app.call(env.merge('HTTP_X_PACT_MOCK_SERVICE' => 'true'))
          mock_service_location_header = {'X-Pact-Mock-Service-Location' => @base_url}
          [response.first, response[1].merge(mock_service_location_header), response.last]
        end
      end
    end
  end
end
