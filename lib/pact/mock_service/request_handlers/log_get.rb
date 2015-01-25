require 'pact/mock_service/request_handlers/mock_service_administration_endpoint'

module Pact
  module MockService
    module RequestHandlers
      class LogGet < MockServiceAdministrationEndpoint

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
end
