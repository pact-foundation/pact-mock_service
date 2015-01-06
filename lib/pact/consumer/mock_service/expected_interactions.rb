require 'pact/consumer/mock_service/candidate_interactions'

module Pact
  module Consumer
    class ExpectedInteractions < Array

      def find_candidate_interactions actual_request
        CandidateInteractions.new(
          select do | interaction |
            interaction.request.matches_route? actual_request
          end
        )
      end

    end
  end
end
