require 'logger'

module Pact
  module MockService
    class Logger < ::Logger

      attr_reader :description

      def initialize stream
        super stream
        @description = if stream.is_a? File
           File.absolute_path(stream).gsub(Dir.pwd + "/", '')
        else
          "standard out/err"
        end
      end

      def self.from_options options
        log_stream = options[:log_file] || $stdout
        logger = new log_stream
        logger.formatter = options[:log_formatter] if options[:log_formatter]
        logger.level = ::Logger::DEBUG
        logger
      end
    end
  end
end
