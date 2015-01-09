require 'pact/consumer/mock_service/rack_request_helper'
require 'pact/consumer/mock_service/mock_service_administration_endpoint'

module Pact
  module Consumer

    class Options

      include RackRequestHelper

      attr_reader :name, :logger, :cors_enabled

      def initialize name, logger, cors_enabled
        @name = name
        @logger = logger
        @cors_enabled = cors_enabled
      end

      def match? env
         is_options_request?(env) && (cors_enabled || is_administration_request?(env))
      end

      def respond env
        logger.info "Received OPTIONS request for #{env['HTTP_ACCESS_CONTROL_REQUEST_METHOD']} #{env['PATH_INFO']}. Returning CORS headers."
        [200,
         {
           'Access-Control-Allow-Origin' => '*',
           'Access-Control-Allow-Headers' => headers_from(env)["Access-Control-Request-Headers"],
           'Access-Control-Allow-Methods' => 'DELETE, POST, GET, HEAD, PUT, TRACE, CONNECT'
          },
         []
        ]
      end

      # Access-Control-Domain does not work on OPTIONs requests.
      def enable_cors?
        false
      end

      def is_options_request? env
        env['REQUEST_METHOD'] == 'OPTIONS'
      end

      def is_administration_request? env
        env["HTTP_ACCESS_CONTROL_REQUEST_HEADERS"].match(/x-pact-mock-service/i)
      end

    end
  end
end
