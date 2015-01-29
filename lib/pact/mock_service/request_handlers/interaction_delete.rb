require 'pact/mock_service/request_handlers/base_administration_request_handler'

module Pact
  module MockService
    module RequestHandlers

      class InteractionDelete < BaseAdministrationRequestHandler

        attr_accessor :session

        def initialize name, logger, session
          super name, logger
          @session = session
        end

        def request_path
          '/interactions'
        end

        def request_method
          'DELETE'
        end

        def respond env
          session.clear_expected_and_actual_interactions
          logger.info "Cleared interactions before example \"#{example_description(env)}\""
          [200, {}, ['Deleted interactions']]
        end

        def example_description env
          params_hash(env).fetch('example_description', [])[0]
        end
      end
    end
  end
end
