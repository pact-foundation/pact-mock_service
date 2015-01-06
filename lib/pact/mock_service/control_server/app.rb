require 'pact/consumer/app_manager'
require 'pact/consumer/mock_service/rack_request_helper'
require 'ostruct'
require 'pact/consumer/server'

module Pact
  module MockService
    module ControlServer
      class App

        include Pact::Consumer::RackRequestHelper

        def initialize options = {}
          @options = options
          @mock_service_registrations = Hash.new { |h, k| h[k] = { } }
        end

        def call env
          headers = headers_from(env)
          consumer = headers['X-Pact-Consumer']
          provider = headers['X-Pact-Provider']
          # error if not both provided
          unless consumer && provider
            return [500, {}, ["Please specify the consumer and the provider by setting the X-Pact-Consumer and X-Pact-Provider headers"]]
          end
          mock_service_registration = mock_service_registration_for consumer, provider
          response = mock_service_registration.app.call(env.merge('HTTP_X_PACT_MOCK_SERVICE' => 'true'))
          mock_service_location_header = {'X-Pact-Mock-Service-Location' => "http://localhost:#{mock_service_registration.port}"}
          [response.first, response[1].merge(mock_service_location_header), response.last]
        end

        def shutdown
          mock_services.each(&:shutdown)
        end

        private

        attr_reader :mock_service_registrations, :options

        def mock_service_registration_for consumer, provider
          mock_service_registration = mock_service_registrations[consumer][provider]
          unless mock_service_registration
            mock_service = create_mock_service consumer, provider
            port = FindAPort.available_port
            start_mock_service mock_service, port
            mock_service_registration = OpenStruct.new(port: port, app: mock_service)
            mock_service_registrations[consumer][provider] = mock_service_registration
            puts "Started mock service for #{provider} on #{port}"
          end
          mock_service_registration
        end

        def create_mock_service consumer, provider
          name = "#{provider} mock service"
          Pact::Consumer::MockService.new(
            log_file: create_log_file(name),
            name: name,
            consumer: consumer,
            provider: provider,
            pact_dir: options[:pact_dir] || "."
          )
        end

        def start_mock_service app, port
          Pact::Server.new(app, port).boot
        end

        def create_log_file service_name
          FileUtils::mkdir_p options[:log_dir]
          log = File.open(log_file_path(service_name), 'w')
          log.sync = true
          log
        end

        def log_file_name service_name
          lower_case_name = service_name.downcase.gsub(/\s+/, '_')
          if lower_case_name.include?('_service')
            lower_case_name.gsub('_service', '_mock_service')
          else
            lower_case_name + '_mock_service'
          end
        end

        def log_file_path service_name
          File.join(options[:log_dir], "#{log_file_name(service_name)}.log")
        end

        def mock_services
          mock_service_registrations.values.collect(&:values).flatten.collect(&:app)
        end
      end
    end
  end
end
