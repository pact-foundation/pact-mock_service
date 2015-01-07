require 'pact/consumer/mock_service/app'
require 'pact/consumer/server'
require 'ostruct'

module Pact
  module MockService
    module ControlServer
      class MockServices

        def initialize options = {}
          @options = options
          @delegators = Delegators.new
        end

        def delegate env, consumer, provider
          delegator_for(consumer, provider).call(env)
        end

        def shutdown
          delegators.delegate :shutdown
        end

        private

        attr_reader :delegators, :options

        def delegator_for consumer, provider
          delegators.get(consumer, provider) || register_and_start_new_mock_service(consumer, provider)
        end

        def register_and_start_new_mock_service consumer, provider
          mock_service = create_mock_service consumer, provider
          port = FindAPort.available_port
          start_mock_service mock_service, port
          puts "Started mock service for #{provider} on #{port}"
          delegators.register(consumer, provider, mock_service, port)
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

        class Delegators

          def initialize
            @delegators = Hash.new { |h, k| h[k] = { } }
          end

          def get consumer, provider
            @delegators[consumer][provider]
          end

          def register consumer, provider, mock_service, port
            delegator = Delegator.new(mock_service, "http://localhost:#{port}")
            @delegators[consumer][provider] = delegator
            delegator
          end

          def delegate method
            @delegators.values.collect(&:values).flatten.collect{ | delegator | delegator.send(method) }
          end
        end

        class Delegator

          def initialize app, base_url
            @app = app
            @base_url = base_url
          end

          def call env
            response = @app.call(env.merge('HTTP_X_PACT_MOCK_SERVICE' => 'true'))
            mock_service_location_header = {'X-Pact-Mock-Service-Location' => @base_url}
            [response.first, response[1].merge(mock_service_location_header), response.last]
          end

          def shutdown
            @app.shutdown
          end

        end

      end
    end
  end
end
