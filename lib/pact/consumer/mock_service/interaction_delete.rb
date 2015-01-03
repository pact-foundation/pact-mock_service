require 'pact/consumer/mock_service/rack_request_helper'
require 'pact/consumer/mock_service/mock_service_administration_endpoint'

module Pact
  module Consumer

    class InteractionDelete < MockServiceAdministrationEndpoint

      include RackRequestHelper

      attr_accessor :expected_interactions, :actual_interactions

      def initialize name, logger, expected_interactions, actual_interactions
        super name, logger
        @expected_interactions = expected_interactions
        @actual_interactions = actual_interactions
      end

      def request_path
        '/interactions'
      end

      def request_method
        'DELETE'
      end

      def respond env
        expected_interactions.clear
        actual_interactions.clear
        logger.info "Cleared interactions before example \"#{example_description(env)}\""
        [200, {}, ['Deleted interactions']]
      end

      def example_description env
        params_hash(env).fetch('example_description', [])[0]
      end
    end
  end
end