require 'pact/consumer/mock_service/rack_request_helper'
require 'pact/mock_service/control_server/mock_services'

module Pact
  module MockService
    module ControlServer
      class App

        include Pact::Consumer::RackRequestHelper

        def initialize options = {}
          @mock_services = MockServices.new(options)
        end

        def call env
          headers = headers_from(env)
          consumer = headers['X-Pact-Consumer']
          provider = headers['X-Pact-Provider']

          unless consumer && provider
            return [500, {}, ["Please specify the consumer and the provider by setting the X-Pact-Consumer and X-Pact-Provider headers"]]
          end

          @mock_services.delegate env, consumer, provider
        end

        def shutdown
          @mock_services.shutdown
        end

      end
    end
  end
end
