require 'pact/consumer/mock_service/web_request_options'

module Pact
  module Consumer

    # Allow web preflight requests to the interactions setup by the user
    # This is only needed in a CORS setup, where the browsers do
    # an OPTIONS call before a DELETE, POST (for most request), etc. in a cross domain requests
    class InteractionReplayOptions < WebRequestOptions

      def initialize name, logger, cors_enabled
        super(name,logger)
        @cors_enabled = cors_enabled
      end

      # Will match all requests to OPTIONS when in CORS mode
      def request_path_match? env
        @cors_enabled
      end
    end
  end
end
