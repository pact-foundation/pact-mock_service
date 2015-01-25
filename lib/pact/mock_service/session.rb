require 'pact/mock_service/interactions/expected_interactions'
require 'pact/mock_service/interactions/actual_interactions'
require 'pact/mock_service/interactions/verified_interactions'

module Pact
  module MockService
    class Session

      attr_reader :expected_interactions, :actual_interactions, :verified_interactions, :consumer_contract_details

      def initialize options
        @expected_interactions = Interactions::ExpectedInteractions.new
        @actual_interactions = Interactions::ActualInteractions.new
        @verified_interactions = Interactions::VerifiedInteractions.new
        @consumer_contract_details = {
          pact_dir: options[:pact_dir],
          consumer: {name: options[:consumer]},
          provider: {name: options[:provider]},
          interactions: verified_interactions
        }
      end

    end
  end
end
