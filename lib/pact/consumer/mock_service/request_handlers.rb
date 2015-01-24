require 'pact/consumer/mock_service/expected_interactions'
require 'pact/consumer/mock_service/actual_interactions'
require 'pact/consumer/mock_service/verified_interactions'
require 'pact/consumer/mock_service/interaction_delete'
require 'pact/consumer/mock_service/interaction_post'
require 'pact/consumer/mock_service/interaction_replay'
require 'pact/consumer/mock_service/missing_interactions_get'
require 'pact/consumer/mock_service/verification_get'
require 'pact/consumer/mock_service/log_get'
require 'pact/consumer/mock_service/pact_post'
require 'pact/consumer/mock_service/index_get'
require 'pact/consumer/mock_service/options'
require 'pact/consumer/request'
require 'pact/support'

module Pact
  module Consumer
    class MockService
      class RequestHandlers
        def initialize name, logger, expected_interactions, actual_interactions, verified_interactions, options
          @handlers = [
            Options.new(name, logger, options[:cors_enabled]),
            MissingInteractionsGet.new(name, logger, expected_interactions, actual_interactions),
            VerificationGet.new(name, logger, expected_interactions, actual_interactions, options[:log_description]),
            InteractionPost.new(name, logger, expected_interactions, verified_interactions),
            InteractionDelete.new(name, logger, expected_interactions, actual_interactions),
            LogGet.new(name, logger),
            PactPost.new(name, logger, verified_interactions, options[:pact_dir], options[:consumer_contract_details]),
            IndexGet.new(name, logger),
            InteractionReplay.new(name, logger, expected_interactions, actual_interactions, verified_interactions, options[:cors_enabled])
          ]
        end

        def call env
          relevant_handler = @handlers.detect { |handler| handler.match? env }
          response = relevant_handler.respond(env)
        end
      end
    end
  end
end
