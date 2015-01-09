require 'pact/consumer/mock_service/web_request_options'

module Pact
  module Consumer

    # Allow web preflight requests to Pact infrastructure
    # Browsers typically do a OPTIONS before a POST for cross domain requests
    class PactOptions < WebRequestOptions
      def request_path
        '/pact'
      end
    end
  end
end
