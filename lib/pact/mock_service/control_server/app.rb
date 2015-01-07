require 'pact/consumer/mock_service/rack_request_helper'
require 'pact/mock_service/control_server/header_checker'
require 'pact/mock_service/control_server/mock_service_creator'


module Pact
  module MockService
    module ControlServer
      class App

        include Pact::Consumer::RackRequestHelper

        def initialize options = {}
          @mock_services = ShutdownableCascade.new([])
          mock_service_creator = MockServiceCreator.new(@mock_services, options)
          @app = HeaderChecker.new(Rack::Cascade.new([@mock_services, mock_service_creator]))
        end

        def call env
          @app.call(env)
        end

        def shutdown
          @mock_services.shutdown
        end

        private

        class ShutdownableCascade < Rack::Cascade

          def add app
            to_shutdown << app
            super
          end

          def shutdown
            to_shutdown.collect(&:shutdown)
          end

          private

          def to_shutdown
            @to_shutdown ||= []
          end
        end

      end
    end
  end
end
