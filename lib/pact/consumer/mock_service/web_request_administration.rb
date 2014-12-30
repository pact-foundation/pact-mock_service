require 'pact/consumer/mock_service/rack_request_helper'
require 'pact/consumer/mock_service/mock_service_administration_endpoint'

module Pact
  module Consumer

    # Administration web requests (GET, DELETE, POST, PUT, etc.)
    class WebRequestAdministration < MockServiceAdministrationEndpoint

      def request_path
        raise NotImplementedError
      end

      def request_method
        raise NotImplementedError
      end

      def enable_cors?
        true
      end

      private
      def request_header_match? env
        headers_from(env)['X-Pact-Mock-Service']
      end

    end

  end
end
