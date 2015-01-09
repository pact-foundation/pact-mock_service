require 'rack'
require 'uri'
require 'json'
require 'logger'
require 'pact/consumer/request'
require 'pact/consumer/mock_service/expected_interactions'
require 'pact/consumer/mock_service/actual_interactions'
require 'pact/consumer/mock_service/verified_interactions'
require 'pact/consumer/mock_service/interaction_delete'
require 'pact/consumer/mock_service/interaction_post'
require 'pact/consumer/mock_service/interaction_options'
require 'pact/consumer/mock_service/interaction_replay'
require 'pact/consumer/mock_service/missing_interactions_get'
require 'pact/consumer/mock_service/verification_get'
require 'pact/consumer/mock_service/log_get'
require 'pact/consumer/mock_service/pact_post'
require 'pact/consumer/mock_service/pact_options'
require 'pact/consumer/mock_service/interaction_replay_options'
require 'pact/support'

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
        @consumer_contact_details = {
          pact_dir: options[:pact_dir],
          consumer: {name: options[:consumer]},
          provider: {name: options[:provider]},
          interactions: verified_interactions
        }

        @handlers = [
          MissingInteractionsGet.new(@name, @logger, expected_interactions, actual_interactions),
          VerificationGet.new(@name, @logger, expected_interactions, actual_interactions, log_description),
          InteractionPost.new(@name, @logger, expected_interactions, verified_interactions),
          InteractionDelete.new(@name, @logger, expected_interactions, actual_interactions),
          InteractionOptions.new(@name, @logger),
          LogGet.new(@name, @logger),
          PactPost.new(@name, @logger, verified_interactions, pact_dir, options[:consumer_contract_details]),
          PactOptions.new(@name, @logger),
          InteractionReplayOptions.new(@name, @logger, options[:cors_enabled]),
          InteractionReplay.new(@name, @logger, expected_interactions, actual_interactions, verified_interactions, options[:cors_enabled])
        ]
      end

      def call env
        response = []
        begin
          relevant_handler = @handlers.detect { |handler| handler.match? env }
          res = relevant_handler.respond(env)
          response = relevant_handler.enable_cors? ? add_cors_header(res) : res
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

      def write_pact_if_configured
        consumer_contract_writer = ConsumerContractWriter.new(@consumer_contact_details, StdoutLogger.new)
        consumer_contract_writer.write if consumer_contract_writer.can_write?
      end

      private

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

      class StdoutLogger
        def info message
          $stdout.puts "\n#{message}"
        end
      end

      def add_cors_header response
        [response[0], response[1].merge('Access-Control-Allow-Origin' => '*'), response[2]]
      end

    end
  end
end
