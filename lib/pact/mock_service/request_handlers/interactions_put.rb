require 'pact/mock_service/request_handlers/base_administration_request_handler'
require 'pact/mock_service/interaction_decorator'
require 'pact/shared/json_differ'
require 'pact/mock_service/request_handlers/interaction_post' #Refactor diff message

module Pact
  module MockService
    module RequestHandlers
      class InteractionsPut < BaseAdministrationRequestHandler

        def initialize name, logger, session
          super name, logger
          @session = session
        end

        def request_path
          '/interactions'
        end

        def request_method
          'PUT'
        end

        def respond env
          request_body = JSON.load(env['rack.input'].string)
          interactions = request_body['interactions'].collect { | hash | Interaction.from_hash(hash) }
          begin
            session.set_expected_interactions interactions
            [200, {}, ['Set interactions']]
          rescue AlmostDuplicateInteractionError => e
            [500, {}, e.message]
          end
        end

        private

        attr_accessor :session

      end
    end
  end
end
