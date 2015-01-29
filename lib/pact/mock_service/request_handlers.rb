require 'pact/mock_service/request_handlers/interaction_post'
require 'pact/mock_service/request_handlers/interactions_put'
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

      class App < ::Rack::Cascade
        def initialize name, logger, session, options
          super [
            Options.new(name, logger, options[:cors_enabled]),
            MissingInteractionsGet.new(name, logger, session.expected_interactions, session.actual_interactions),
            VerificationGet.new(name, logger, session.expected_interactions, session.actual_interactions),
            InteractionPost.new(name, logger, session),
            InteractionsPut.new(name, logger, session),
            InteractionDelete.new(name, logger, session),
            LogGet.new(name, logger),
            PactPost.new(name, logger, session.verified_interactions, session.consumer_contract_details),
            IndexGet.new(name, logger),
            InteractionReplay.new(name, logger, session.expected_interactions, session.actual_interactions, session.verified_interactions, options[:cors_enabled])
          ]
        end
      end
    end
  end
end
