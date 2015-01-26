require 'pact/mock_service/request_handlers/base_request_handler'

module Pact
  module MockService
    module RequestHandlers

      class Options < BaseRequestHandler

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
          cors_headers = {
           'Access-Control-Allow-Origin' => env.fetch('HTTP_ORIGIN','*'),
           'Access-Control-Allow-Headers' => headers_from(env)["Access-Control-Request-Headers"],
           'Access-Control-Allow-Methods' => 'DELETE, POST, GET, HEAD, PUT, TRACE, CONNECT'
          }
          logger.info "Received OPTIONS request for mock service administration endpoint #{env['HTTP_ACCESS_CONTROL_REQUEST_METHOD']} #{env['PATH_INFO']}. Returning CORS headers: #{cors_headers.to_json}."
          [200, cors_headers, []]
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
end
