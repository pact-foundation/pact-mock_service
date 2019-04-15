require 'pact/mock_service/request_handlers/base_administration_request_handler'
require 'json'

module Pact
  module MockService
    module RequestHandlers
      class MatchesGet < BaseAdministrationRequestHandler

        def initialize name, logger, session
          super name, logger
          @expected_interactions = session.expected_interactions
          @actual_interactions = session.actual_interactions
        end

        def request_path
          '/interactions/matches'
        end

        def request_method
          'GET'
        end

        def respond env
          result = expected_interactions.map{|x| {
              :description    => x.description,
              :request        => x.request.to_hash,
              :number_matches => actual_interactions.matched_interactions.
                        select{ |y| y.description == x.description }.
                        count

          }}
          json_response(result.to_json)
        end

        private

        attr_accessor :expected_interactions, :actual_interactions
      end
    end
  end
end
