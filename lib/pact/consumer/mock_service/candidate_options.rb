require 'pact/consumer/mock_service/web_request_options'

module Pact
  module Consumer

    # Need good explanation here
    # Allow web preflight requests to the intaractions setup by the user
    # This is only needed in a CORS setup, where the
    # Browsers typically do a OPTIONS before a POST for cross domain requests
    class CandidateOptions < WebRequestOptions
      def request_path_match? env
        true
      end
      def match?
        puts headers_from(env)
        puts "Headers match are :#{request_header_match?}"
        puts "Request path are :#{request_path_match?}"
        puts "Request method :#{request_method_match?}"
        res= super
        puts "Result is #{res}"
        res
      end
    end
  end
end
