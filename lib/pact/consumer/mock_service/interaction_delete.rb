require 'pact/consumer/mock_service/rack_request_helper'
require 'pact/consumer/mock_service/web_request_administration'

module Pact
  module Consumer

    class InteractionDelete < WebRequestAdministration

      include RackRequestHelper

      attr_accessor :interaction_list

      def initialize name, logger, interaction_list
        super name, logger
        @interaction_list = interaction_list
      end

      def request_path
        '/interactions'
      end

      def request_method
        'DELETE'
      end

      def respond env
        interaction_list.clear
        logger.info "Cleared interactions before example \"#{example_description(env)}\""
        [200, {}, ['Deleted interactions']]
      end

      def example_description env
        params_hash(env).fetch('example_description', [])[0]
      end
    end
  end
end