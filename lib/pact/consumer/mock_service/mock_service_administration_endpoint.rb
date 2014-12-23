require 'pact/consumer/mock_service/rack_request_helper'
module Pact
  module Consumer
    class MockServiceAdministrationEndpoint

      attr_accessor :logger, :name

      def initialize name, logger
        @name = name
        @logger = logger
      end

      include RackRequestHelper

      def match? env
        # 'X-Pact-Mock-Service' header is set as a normal header in regular requests (PUT, GET, POST, etc.)
        # However, browsers set it within Access-Control-Request-Headers in case of OPTIONS request
        # (web browsers make an OPTIONS request prior to the normal request in case of CORS request)
        ( (headers_from(env)["Access-Control-Request-Headers"].nil? ? false
          : headers_from(env)["Access-Control-Request-Headers"].match(/x-pact-mock-service/)
        )  || headers_from(env)['X-Pact-Mock-Service'] ) &&
            env['PATH_INFO'] == request_path &&
            env['REQUEST_METHOD'] == request_method
      end

      def request_path
        raise NotImplementedError
      end

      def request_method
        raise NotImplementedError
      end

    end
  end
end