require 'pact/mock_service/interactions/expected_interactions'
require 'pact/mock_service/interactions/actual_interactions'
require 'pact/mock_service/interactions/verified_interactions'
require 'pact/mock_service/request_handlers/interaction_post'
require 'pact/mock_service/request_handlers/index_get'
require 'pact/mock_service/request_handlers/interaction_delete'
require 'pact/mock_service/request_handlers/interaction_replay'
require 'pact/mock_service/request_handlers/log_get'
require 'pact/mock_service/request_handlers/options'
require 'pact/mock_service/request_handlers/missing_interactions_get'
require 'pact/mock_service/request_handlers/pact_post'
require 'pact/mock_service/request_handlers/verification_get'
require 'pact/consumer/request'
require 'pact/support'

module Pact
  module MockService
    module RequestHandlers

      def self.new *args
        App.new(*args)
      end

      class App
        def initialize name, logger, expected_interactions, actual_interactions, verified_interactions, options
          @handlers = [
            Pact::MockService::RequestHandlers::Options.new(name, logger, options[:cors_enabled]),
            Pact::MockService::RequestHandlers::MissingInteractionsGet.new(name, logger, expected_interactions, actual_interactions),
            Pact::MockService::RequestHandlers::VerificationGet.new(name, logger, expected_interactions, actual_interactions, options[:log_description]),
            Pact::MockService::RequestHandlers::InteractionPost.new(name, logger, expected_interactions, verified_interactions),
            Pact::MockService::RequestHandlers::InteractionDelete.new(name, logger, expected_interactions, actual_interactions),
            Pact::MockService::RequestHandlers::LogGet.new(name, logger),
            Pact::MockService::RequestHandlers::PactPost.new(name, logger, verified_interactions, options[:pact_dir], options[:consumer_contract_details]),
            Pact::MockService::RequestHandlers::IndexGet.new(name, logger),
            Pact::MockService::RequestHandlers::InteractionReplay.new(name, logger, expected_interactions, actual_interactions, verified_interactions, options[:cors_enabled])
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
