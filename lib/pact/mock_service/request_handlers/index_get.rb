require 'pact/consumer/mock_service/rack_request_helper'
require 'pact/mock_service/request_handlers/mock_service_administration_endpoint'

module Pact
  module MockService
    module RequestHandlers

      class IndexGet < MockServiceAdministrationEndpoint

        def request_path
          ''
        end

        def request_method
          'GET'
        end

        def respond env
          [200, {'Content-Type' => 'text/plain'}, ['Mock service running']]
        end
      end
    end
  end
end
