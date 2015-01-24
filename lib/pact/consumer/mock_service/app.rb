require 'rack'
require 'uri'
require 'json'
require 'logger'
require 'pact/consumer/mock_service/cors_origin_header_middleware'
require 'pact/consumer/mock_service/request_handlers'

module Pact
  module Consumer
    class MockService
      class App

        def initialize options = {}
          @name = options.fetch(:name, "MockService")
          @logger = options.fetch(:logger)
          expected_interactions = ExpectedInteractions.new
          actual_interactions = ActualInteractions.new
          verified_interactions = VerifiedInteractions.new
          @consumer_contact_details = {
            pact_dir: options[:pact_dir],
            consumer: {name: options[:consumer]},
            provider: {name: options[:provider]},
            interactions: verified_interactions
          }

          @request_handlers = Pact::Consumer::MockService::RequestHandlers.new(@name, @logger, expected_interactions, actual_interactions, verified_interactions, options)
        end

        def call env
          @request_handlers.call(env)
        end

        def shutdown
          write_pact_if_configured
        end

        private

        def write_pact_if_configured
          consumer_contract_writer = ConsumerContractWriter.new(@consumer_contact_details, StdoutLogger.new)
          consumer_contract_writer.write if consumer_contract_writer.can_write?
        end

        def to_s
          "#{@name} #{super.to_s}"
        end

      end

      class StdoutLogger
        def info message
          $stdout.puts "\n#{message}"
        end
      end
    end
  end
end
