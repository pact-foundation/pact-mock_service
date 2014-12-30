require 'pact/consumer/mock_service/rack_request_helper'
require 'pact/consumer/mock_service/mock_service_administration_endpoint'

module Pact
  module Consumer

    # Web Request is OPTIONS, which is a preflight brower request made
    # before sending the actual POST, DELETE, etc. in CORS cases
    class WebRequestOptions < MockServiceAdministrationEndpoint

      include RackRequestHelper

      def request_path
        raise NotImplementedError
      end

      def request_method
        'OPTIONS'
      end

      def respond env
        logger.info "Preflight browser CORS check before sending data okayed (OPTIONS request)"
        [200,
         {
             'Access-Control-Allow-Origin' => '*',
             # '*' is not allowed for 'Access-Control-Allow-Headers. We need to echo back what was provided!
             'Access-Control-Allow-Headers' => headers_from(env)["Access-Control-Request-Headers"],
             'Access-Control-Allow-Methods' => 'DELETE, POST, GET, HEAD, PUT, TRACE, CONNECT'},
         ["Browser, go ahead and send the actual request"]
        ]
      end

      # Access-Control-Domain does not work on OPTIONs requests.
      def enable_cors?
        false
      end

      private
      # 'X-Pact-Mock-Service' header is set as a normal header in regular requests (PUT, GET, POST, etc.)
      # However, browsers set it within Access-Control-Request-Headers in case of OPTIONS request
      # (web browsers make an OPTIONS request prior to the normal request in case of CORS request)
      # For OPTIONS request, headers are different
      def request_header_match? env
        headers_from(env)["Access-Control-Request-Headers"].nil? ? false
        : headers_from(env)["Access-Control-Request-Headers"].match(/x-pact-mock-service/)
      end

    end

  end
end