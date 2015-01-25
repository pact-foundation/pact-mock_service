require 'rack'
require 'uri'
require 'json'
require 'logger'
require 'pact/consumer/mock_service/cors_origin_header_middleware'
require 'pact/mock_service/request_handlers'

require 'pact/mock_service/app'
require 'pact/consumer/mock_service/error_handler'
require 'pact/mock_service/session'

module Pact
  module MockService

    def self.new *args
      App.new(*args)
    end

    class App

      def initialize options = {}
        @name = options.fetch(:name, "MockService")
        logger, log_description = configure_logger(options)
        app_options = options.merge(logger: logger, log_description: log_description)
        @session = Session.new(options)
        request_handlers = Pact::MockService::RequestHandlers.new(@name, logger, @session, app_options)
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

      def write_pact_if_configured
        consumer_contract_writer = ConsumerContractWriter.new(@session.consumer_contract_details, StdoutLogger.new)
        consumer_contract_writer.write if consumer_contract_writer.can_write?
      end

      def configure_logger options
        options = {log_file: $stdout}.merge options
        log_stream = options[:log_file]
        logger = Logger.new log_stream
        logger.formatter = options[:log_formatter] if options[:log_formatter]
        logger.level = Pact.configuration.logger.level

        log_description = if log_stream.is_a? File
           File.absolute_path(log_stream).gsub(Dir.pwd + "/", '')
        else
          "standard out/err"
        end
        return logger, log_description
      end

      def to_s
        "#{@name} #{super.to_s}"
      end
    end

    # Can't write to a file in a TRAP, might deadlock
    class StdoutLogger
      def info message
        $stdout.puts "\n#{message}"
      end
    end
  end
end
