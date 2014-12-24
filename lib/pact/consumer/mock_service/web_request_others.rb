require 'pact/consumer/mock_service/rack_request_helper'
require 'pact/consumer/mock_service/mock_service_administration_endpoint'

module Pact
  module Consumer

    # Regular web requests (GET, DELETE, POST, PUT, etc.)
    class WebRequestOthers < MockServiceAdministrationEndpoint

      def request_path
        raise NotImplementedError
      end

      def request_method
        raise NotImplementedError
      end

      private
      def request_header_match? env
        headers_from(env)['X-Pact-Mock-Service']
      end

    end
  end
end
