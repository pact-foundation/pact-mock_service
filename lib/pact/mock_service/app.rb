require 'rack'
require 'uri'
require 'json'
require 'pact/mock_service/logger'
require 'pact/consumer/mock_service/cors_origin_header_middleware'
require 'pact/mock_service/request_handlers'
require 'pact/consumer/mock_service/error_handler'
require 'pact/mock_service/session'

module Pact
  module MockService

    def self.new *args
      App.new(*args)
    end

    class App

      def initialize options = {}
        logger = Logger.from_options(options)
        @name = options.fetch(:name, "MockService")
        @session = Session.new(options.merge(logger: logger))
        setup_stub(options[:stub_pactfile_paths]) if options[:stub_pactfile_paths]
        request_handlers = RequestHandlers.new(@name, logger, @session, options)
        @app = Rack::Builder.app do
          use Pact::Consumer::MockService::ErrorHandler, logger
          use Pact::Consumer::CorsOriginHeaderMiddleware, options[:cors_enabled]
          run request_handlers
        end
      end

      def call env
        @app.call env
      end

      def shutdown
        write_pact_if_configured
      end

      def setup_stub stub_pactfile_paths
        interactions = stub_pactfile_paths.collect do | pactfile_path |
          $stdout.puts "INFO: Loading interactions from #{pactfile_path}"
          hash_interactions = JSON.parse(Pact::PactFile.read(pactfile_path))['interactions']
          hash_interactions.collect { | hash | Interaction.from_hash(hash) }
        end.flatten
        @session.set_expected_interactions interactions
      end

      def write_pact_if_configured
        consumer_contract_writer = ConsumerContractWriter.new(@session.consumer_contract_details, StdoutLogger.new)
        if consumer_contract_writer.can_write? && !@session.pact_written?
          $stdout.puts "INFO: Writing pact before shutting down"
          consumer_contract_writer.write
        end
      end

      def to_s
        "#{@name} #{super.to_s}"
      end
    end

    # Can't write to a file in a TRAP, might deadlock
    # Not sure why we can still write to the pact file though
    class StdoutLogger
      def info message
        $stdout.puts "\n#{message}"
      end
    end
  end
end
