require 'pact/consumer/mock_service/mock_service_administration_endpoint'
require 'pact/consumer_contract/consumer_contract_writer'

module Pact
  module Consumer
    class PactOptions < MockServiceAdministrationEndpoint

      attr_accessor :consumer_contract, :interactions

      def request_path
        '/pact'
      end

      def request_method
        'OPTIONS'
      end

      def respond env
        [200,
         {
             'Access-Control-Allow-Origin' => '*',
             # '*' is not allowed for 'Access-Control-Allow-Headers. We need to echo back what was provided!
             'Access-Control-Allow-Headers' => headers_from(env)["Access-Control-Request-Headers"],
             'Access-Control-Allow-Methods' => 'DELETE, POST, GET, HEAD, PUT, TRACE, CONNECT'},
         ["Browser, go ahead and send the actual request"]
        ]

      end
    end
  end
end
