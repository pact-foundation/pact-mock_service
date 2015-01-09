require 'pact/consumer/mock_service/web_request_administration'

module Pact
  module Consumer
    class LogGet < WebRequestAdministration

      include RackRequestHelper

      def request_path
        '/log'
      end

      def request_method
        'GET'
      end


      def respond env
        logger.info "Debug message from client - #{message(env)}"
        [200, {}, []]
      end

      def message env
        params_hash(env).fetch('msg', [])[0]
      end
    end
  end
end
