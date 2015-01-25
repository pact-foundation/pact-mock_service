require 'pact/mock_service/request_handlers/mock_service_administration_endpoint'
require 'pact/mock_service/interactions/verification'

module Pact
  module MockService
    module RequestHandlers

      class MissingInteractionsGet < MockServiceAdministrationEndpoint

        def initialize name, logger, expected_interactions, actual_interactions
          super name, logger
          @expected_interactions = expected_interactions
          @actual_interactions = actual_interactions
        end

        def request_path
          '/interactions/missing'
        end

        def request_method
          'GET'
        end

        def respond env
          verification = Pact::MockService::Interactions::Verification.new(@expected_interactions, @actual_interactions)
          number_of_missing_interactions = verification.missing_interactions.size
          logger.info "Number of missing interactions for mock \"#{name}\" = #{number_of_missing_interactions}"
          [200, {}, [{size: number_of_missing_interactions}.to_json]]
        end
      end
    end
  end
end
