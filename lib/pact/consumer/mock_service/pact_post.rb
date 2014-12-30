require 'pact/consumer_contract/consumer_contract_writer'
require 'pact/consumer/mock_service/web_request_administration'

module Pact
  module Consumer
    class PactPost < WebRequestAdministration

      attr_accessor :consumer_contract, :interactions, :default_options

      def initialize name, logger, interactions, pact_dir
        super name, logger
        @interactions = interactions
        @default_options = {pact_dir: pact_dir}
      end

      def request_path
        '/pact'
      end

      def request_method
        'POST'
      end

      def respond env
        consumer_contract_details = JSON.parse(env['rack.input'].string, symbolize_names: true)
        logger.info "Writing pact with details #{consumer_contract_details}"
        consumer_contract_params = default_options.merge(consumer_contract_details.merge(interactions: interactions))
        consumer_contract_writer = ConsumerContractWriter.new(consumer_contract_params, logger)
        json = consumer_contract_writer.write

        [200, {'Content-Type' =>'application/json'}, [json]]
      end
    end
  end
end
