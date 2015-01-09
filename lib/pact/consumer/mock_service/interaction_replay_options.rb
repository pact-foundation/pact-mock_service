require 'pact/consumer/mock_service/web_request_options'

module Pact
  module Consumer

    # Allow web preflight requests to the interactions setup by the user
    # This is only needed in a CORS setup, where the browsers do
    # an OPTIONS call before a DELETE, POST (for most request), etc. in a cross domain requests
    # TODO: This should not extend WebRequestOptions because WebRequestOptions extends
    # MockServiceAdministrationEndpoint, and this is not an Administration endpoint.
    # Find a better way of sharing the response
    class InteractionReplayOptions < WebRequestOptions

      def initialize name, logger, cors_enabled
        super(name,logger)
        @cors_enabled = cors_enabled
      end

      def match? env
        @cors_enabled && env['REQUEST_METHOD'] == 'OPTIONS'
      end
    end
  end
end
