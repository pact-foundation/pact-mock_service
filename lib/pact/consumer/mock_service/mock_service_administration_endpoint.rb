require 'pact/consumer/mock_service/rack_request_helper'
module Pact
  module Consumer
    class MockServiceAdministrationEndpoint

      include RackRequestHelper

      attr_accessor :logger, :name

      def initialize name, logger
        @name = name
        @logger = logger
      end

      def match? env
        (request_header_match? env) && (request_path_match? env) && (request_method_match? env)
      end

      def request_path
        raise NotImplementedError
      end

      def request_method
        raise NotImplementedError
      end

      private

      def request_header_match? env
        raise NotImplementedError
      end

      def request_path_match? env
        env['PATH_INFO'] == request_path
      end

      def request_method_match? env
        env['REQUEST_METHOD'] == request_method
      end
    end
  end
end
