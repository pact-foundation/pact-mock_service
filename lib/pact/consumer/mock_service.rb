require 'pact/consumer/mock_service/app'
require 'pact/consumer/mock_service/error_handler'

module Pact
  module Consumer

    class MockService

      def initialize options = {}
        logger, log_description = configure_logger(options)
        app_options = options.merge(logger: logger, log_description: log_description)
        @app = Rack::Builder.app do
          use ErrorHandler, logger
          use CorsOriginHeaderMiddleware, options[:cors_enabled]
          run App.new(app_options)
        end
      end

      def call env
        @app.call env
      end

      def shutdown
        @app.shutdown
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
    end
  end
end
