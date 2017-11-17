require 'pact/mock_service/request_handlers/interaction_post'
require 'pact/mock_service/request_handlers/interactions_put'
require 'pact/mock_service/request_handlers/index_get'
require 'pact/mock_service/request_handlers/interaction_delete'
require 'pact/mock_service/request_handlers/interaction_replay'
require 'pact/mock_service/request_handlers/log_get'
require 'pact/mock_service/request_handlers/options'
require 'pact/mock_service/request_handlers/missing_interactions_get'
require 'pact/mock_service/request_handlers/pact_post'
require 'pact/mock_service/request_handlers/session_delete'
require 'pact/mock_service/request_handlers/verification_get'
require 'pact/consumer/request'
require 'pact/support'
require 'rack/reverse_proxy'
require 'rack'

module Pact
  module ProviderProxy
    module RequestHandlers

      def self.new *args
        App.new(*args)
      end

      class App < ::Rack::Cascade
        def initialize name, logger, session, options, app
          super [
            MockService::RequestHandlers::Options.new(name, logger, options[:cors_enabled]),
            MockService::RequestHandlers::SessionDelete.new(name, logger, session),
            MockService::RequestHandlers::MissingInteractionsGet.new(name, logger, session),
            MockService::RequestHandlers::InteractionPost.new(name, logger, session),
            MockService::RequestHandlers::InteractionsPut.new(name, logger, session),
            MockService::RequestHandlers::InteractionDelete.new(name, logger, session),
            MockService::RequestHandlers::LogGet.new(name, logger),
            MockService::RequestHandlers::PactPost.new(name, logger, session),
            MockService::RequestHandlers::IndexGet.new(name, logger),
            app
          ]
        end
      end
    end
  end
end
