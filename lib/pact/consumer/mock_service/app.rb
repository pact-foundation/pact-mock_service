require 'rack'
require 'uri'
require 'json'
require 'logger'
require 'awesome_print'
require 'pact/consumer/request'
require 'pact/consumer/mock_service/expected_interactions'
require 'pact/consumer/mock_service/actual_interactions'
require 'pact/consumer/mock_service/verified_interactions'
require 'pact/consumer/mock_service/interaction_delete'
require 'pact/consumer/mock_service/interaction_post'
require 'pact/consumer/mock_service/interaction_replay'
require 'pact/consumer/mock_service/missing_interactions_get'
require 'pact/consumer/mock_service/verification_get'
require 'pact/consumer/mock_service/log_get'
require 'pact/consumer/mock_service/pact_post'
require 'pact/support'

AwesomePrint.defaults = {
  indent: -2,
  plain: true,
  index: false
}

module Pact
  module Consumer

    class MockService

      def initialize options = {}
        log_description = configure_logger options

        @name = options.fetch(:name, "MockService")
        pact_dir = options[:pact_dir]
        expected_interactions = ExpectedInteractions.new
        actual_interactions = ActualInteractions.new
        verified_interactions = VerifiedInteractions.new

        @handlers = [
          MissingInteractionsGet.new(@name, @logger, expected_interactions, actual_interactions),
          VerificationGet.new(@name, @logger, expected_interactions, actual_interactions, log_description),
          InteractionPost.new(@name, @logger, expected_interactions, verified_interactions),
          InteractionDelete.new(@name, @logger, expected_interactions, actual_interactions),
          LogGet.new(@name, @logger),
          PactPost.new(@name, @logger, verified_interactions, pact_dir),
          InteractionReplay.new(@name, @logger, expected_interactions, actual_interactions, verified_interactions)
        ]
      end

      def configure_logger options
        options = {log_file: $stdout}.merge options
        log_stream = options[:log_file]
        @logger = Logger.new log_stream
        @logger.formatter = options[:log_formatter] if options[:log_formatter]
        @logger.level = Pact.configuration.logger.level

        if log_stream.is_a? File
           File.absolute_path(log_stream).gsub(Dir.pwd + "/", '')
        else
          "standard out/err"
        end
      end

      def to_s
        "#{@name} #{super.to_s}"
      end

      def call env
        response = []
        begin
          relevant_handler = @handlers.detect { |handler| handler.match? env }
          response = relevant_handler.respond(env)
        rescue StandardError => e
          @logger.error "Error ocurred in mock service: #{e.class} - #{e.message}"
          @logger.error e.backtrace.join("\n")
          response = [500, {'Content-Type' => 'application/json'}, [{message: e.message, backtrace: e.backtrace}.to_json]]
        rescue Exception => e
          @logger.error "Exception ocurred in mock service: #{e.class} - #{e.message}"
          @logger.error e.backtrace.join("\n")
          raise e
        end
        response
      end

    end
  end
end
