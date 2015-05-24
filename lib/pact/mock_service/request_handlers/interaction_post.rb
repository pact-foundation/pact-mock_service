require 'pact/mock_service/request_handlers/base_administration_request_handler'
require 'pact/mock_service/session'

module Pact
  module MockService
    module RequestHandlers
      class InteractionPost < BaseAdministrationRequestHandler

        def initialize name, logger, session
          super name, logger
          @session = session
        end

        def request_path
          '/interactions'
        end

        def request_method
          'POST'
        end

        def respond env
          request_body = env['rack.input'].string
          interaction = Interaction.from_hash(JSON.load(request_body)) # Load creates the Pact::XXX classes

          begin
            session.add_expected_interaction interaction
            [200, {}, ['Set interactions']]
          rescue AlmostDuplicateInteractionError => e
            [500, {}, [e.message]]
          end

        end

        private

        attr_accessor :session
      end
    end
  end
end
