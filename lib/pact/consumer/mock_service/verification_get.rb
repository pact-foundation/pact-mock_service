require 'pact/consumer/mock_service/web_request_administration'

module Pact
  module Consumer
    class VerificationGet < WebRequestAdministration

      include RackRequestHelper

      def initialize name, logger, expected_interactions, actual_interactions, log_description
        super name, logger
        @expected_interactions = expected_interactions
        @actual_interactions = actual_interactions
        @log_description = log_description
      end

      def request_path
        '/interactions/verification'
      end

      def request_method
        'GET'
      end

      def respond env
        verification = Verification.new(expected_interactions, actual_interactions)
        if verification.all_matched?
          logger.info "Verifying - interactions matched for example \"#{example_description(env)}\""
          [200, {'Content-Type' => 'text/plain'}, ['Interactions matched']]
        else
          error_message = FailureMessage.new(verification).to_s
          logger.warn "Verifying - actual interactions do not match expected interactions for example \"#{example_description(env)}\". \n#{error_message}"
          logger.warn error_message
          [500, {'Content-Type' => 'text/plain'}, ["Actual interactions do not match expected interactions for mock #{name}.\n\n#{error_message}See #{log_description} for details."]]
        end
      end

      private

      attr_accessor :expected_interactions, :actual_interactions, :log_description

      def example_description env
        params_hash(env).fetch("example_description", [])[0]
      end

      class FailureMessage

        def initialize verification
          @verification = verification
        end

        def to_s
          titles_and_summaries.collect do | title, summaries |
            "#{title}:\n\t#{summaries.join("\n\t")}\n\n" if summaries.any?
          end.compact.join

        end

        private

        attr_reader :verification

        def titles_and_summaries
          {
            "Incorrect requests" => verification.interaction_mismatches_summaries,
            "Missing requests" => verification.missing_interactions_summaries,
            "Unexpected requests" => verification.unexpected_requests_summaries,
          }
        end

      end
    end
  end
end
