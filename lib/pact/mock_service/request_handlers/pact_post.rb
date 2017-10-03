require 'pact/mock_service/request_handlers/base_administration_request_handler'
require 'pact/consumer_contract/consumer_contract_writer'

module Pact
  module MockService
    module RequestHandlers
      class PactPost < BaseAdministrationRequestHandler

        attr_accessor :consumer_contract, :verified_interactions, :default_options

        def initialize name, logger, session
          super name, logger
          @verified_interactions = session.verified_interactions
          @default_options = {}
          @default_options.merge!(session.consumer_contract_details)
        end

        def request_path
          '/pact'
        end

        def request_method
          'POST'
        end

        def respond env
          consumer_contract_details = JSON.parse(env['rack.input'].string, symbolize_names: true)
          consumer_contract_params = default_options.merge(consumer_contract_details.merge(interactions: verified_interactions))
          consumer_contract_writer = ConsumerContractWriter.new(consumer_contract_params, logger)
          json_response(consumer_contract_writer.write)
        end
      end
    end
  end
end
