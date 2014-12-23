require 'pact/consumer/mock_service/rack_request_helper'
require 'pact/consumer/mock_service/mock_service_administration_endpoint'

module Pact
  module Consumer

    class InteractionOptions < MockServiceAdministrationEndpoint

      include RackRequestHelper

      def request_path
        '/interactions'
      end

      def request_method
        'OPTIONS'
      end

      def respond env
        logger.info "CORS OPTIONS check before sending data"
        [200,
         {
             'Access-Control-Allow-Origin' => '*',
             # '*' is not allowed for 'Access-Control-Allow-Headers. We need to echo back what was provided!
             'Access-Control-Allow-Headers' => headers_from(env)["Access-Control-Request-Headers"],
             'Access-Control-Allow-Methods' => 'DELETE, POST, GET, HEAD, PUT, TRACE, CONNECT'},
         ["Browser, go ahead and send the actual request"]
        ]
      end
    end
  end
end