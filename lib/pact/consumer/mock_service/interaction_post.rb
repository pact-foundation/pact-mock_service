require 'pact/consumer/mock_service/mock_service_administration_endpoint'

module Pact
  module Consumer
    class InteractionPost < MockServiceAdministrationEndpoint

      def initialize name, logger, interaction_list, verified_interactions
        super name, logger
        @interaction_list = interaction_list
        @verified_interactions = verified_interactions
      end

      def request_path
        '/interactions'
      end

      def request_method
        'POST'
      end

      def respond env
        request_body = env['rack.input'].string
        interaction = Interaction.from_hash(JSON.load(request_body))
        if interaction_already_verified_with_same_description_and_provider_state_but_not_equal? interaction
          message = "An interaction with same description (#{interaction.description.inspect}) and provider state (#{interaction.provider_state.inspect}) has already been used. Please use a different description or provider state."
          logger.error message
          [500, {}, [message]]
        else
          interaction_list.add interaction
          logger.info "Registered expected interaction #{interaction.request.method_and_path}"
          logger.debug JSON.pretty_generate JSON.parse(request_body)
          [200, {}, ['Added interaction']]
        end
      end

      private

      attr_accessor :interaction_list, :verified_interactions

      def interaction_already_verified_with_same_description_and_provider_state_but_not_equal? interaction
        other = verified_interactions.find_matching_description_and_provider_state interaction
        other && other != interaction
      end
    end
  end
end
