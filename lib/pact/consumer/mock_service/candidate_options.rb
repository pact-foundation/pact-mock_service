require 'pact/consumer/mock_service/web_request_options'

module Pact
  module Consumer

    # Need good explanation here
    # Allow web preflight requests to the intaractions setup by the user
    # This is only needed in a CORS setup, where the
    # Browsers typically do a OPTIONS before a POST for cross domain requests
    class CandidateOptions < WebRequestOptions
      def initialize name, logger, cors
        super(name,logger)
        @cors = cors
      end

      # Will match all requests to OPTIONS when in CORS mode
      def request_path_match? env
        @cors
      end
    end
  end
end
