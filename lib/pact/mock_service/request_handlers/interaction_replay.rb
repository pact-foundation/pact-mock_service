require 'pact/matchers'
require 'pact/consumer/request'
require 'pact/mock_service/interactions/interaction_mismatch'
require 'pact/consumer_contract'
require 'pact/mock_service/response_decorator'
require 'pact/mock_service/interaction_decorator'
require 'pact/mock_service/request_handlers/base_request_handler'

module Pact
  module MockService
    module RequestHandlers

      module PrettyGenerate
        #Doesn't seem to reliably pretty generate unless we go to JSON and back again :(
        def pretty_generate object
          JSON.pretty_generate(JSON.parse(object.to_json))
        end
      end

      class InteractionReplay < BaseRequestHandler
        include Pact::Matchers
        include PrettyGenerate

        attr_accessor :name, :logger, :expected_interactions, :actual_interactions, :verified_interactions

        def initialize name, logger, session, cors_enabled=false
          @name = name
          @logger = logger
          @expected_interactions = session.expected_interactions
          @actual_interactions = session.actual_interactions
          @verified_interactions = session.verified_interactions
          @cors_enabled = cors_enabled
        end

        def match? env
          true # default handler
        end

        def respond env
          find_response request_as_hash_from(env)
        end

        private

        def find_response request_hash
          actual_request = Pact::Consumer::Request::Actual.from_hash(request_hash)
          logger.info "Received request #{actual_request.method_and_path}"
          logger.debug pretty_generate request_hash
          candidate_interactions = expected_interactions.find_candidate_interactions actual_request
          matching_interactions = candidate_interactions.matching_interactions actual_request

          case matching_interactions.size
          when 0 then handle_unrecognised_request actual_request, candidate_interactions
          when 1 then handle_matched_interaction matching_interactions.first
          else
            handle_more_than_one_matching_interaction actual_request, matching_interactions
          end
        end

        def handle_matched_interaction interaction
          HandleMatchedInteraction.call(interaction, verified_interactions, actual_interactions, logger)
        end

        def handle_more_than_one_matching_interaction actual_request, matching_interactions
          HandleMultipleInteractionsFound.call(actual_request, matching_interactions, logger)
        end

        def handle_unrecognised_request actual_request, candidate_interactions
          HandleUnrecognisedInteraction.call(actual_request, candidate_interactions, actual_interactions, logger)
        end

        def logger_info_ap msg
          logger.info msg
        end

      end

      class HandleMultipleInteractionsFound

        extend PrettyGenerate

        def self.call actual_request, matching_interactions, logger
          logger.error "Multiple interactions found for #{actual_request.method_and_path}:"
          matching_interactions.each do | interaction |
            logger.debug pretty_generate(Pact::MockService::InteractionDecorator.new(interaction))
          end
          response actual_request, matching_interactions
        end

        def self.response actual_request, matching_interactions
          response = {
            message: "Multiple interaction found for #{actual_request.method_and_path}",
            matching_interactions:  matching_interactions.collect{ | interaction | request_summary_for(interaction) }
          }
          [500, {'Content-Type' => 'application/json'}, [response.to_json]]
        end

        def self.request_summary_for interaction
          summary = {:description => interaction.description}
          summary[:provider_state] if interaction.provider_state
          summary[:request] = Pact::MockService::RequestDecorator.new(interaction.request)
          summary
        end
      end

      class HandleUnrecognisedInteraction

        def self.call actual_request, candidate_interactions, actual_interactions, logger
          interaction_mismatch = interaction_mismatch(actual_request, candidate_interactions)
          if candidate_interactions.any?
            actual_interactions.register_interaction_mismatch interaction_mismatch
          else
            actual_interactions.register_unexpected_request actual_request
          end
          log interaction_mismatch, logger
          response interaction_mismatch
        end

        def self.response interaction_mismatch
          response = {
            message: "No interaction found for #{interaction_mismatch.actual_request.method_and_path}",
            interaction_diffs:  interaction_mismatch.to_hash
          }
          [500, {'Content-Type' => 'application/json'}, [response.to_json]]
        end

        def self.interaction_mismatch actual_request, candidate_interactions
          Pact::MockService::Interactions::InteractionMismatch.new(candidate_interactions, actual_request)
        end

        def self.log interaction_mismatch, logger
          logger.error "No matching interaction found for #{interaction_mismatch.actual_request.method_and_path}"
          logger.error 'Interaction diffs for that route:'
          logger.error(interaction_mismatch.to_s)
        end

      end

      class HandleMatchedInteraction

        extend PrettyGenerate

        def self.call interaction, verified_interactions, actual_interactions, logger
          actual_interactions.register_matched interaction
          verified_interactions << interaction
          response = response_from(interaction.response)
          logger.info "Found matching response for #{interaction.request.method_and_path}"
          logger.debug pretty_generate(Pact::MockService::ResponseDecorator.new(interaction.response))
          response
        end

        def self.response_from response
          [response.status, (Pact::Reification.from_term(response.headers) || {}).to_hash, [render_body(Pact::Reification.from_term(response.body))]]
        end

        def self.render_body body
          return '' unless body
          body.kind_of?(String) ? body.force_encoding('utf-8') : body.to_json
        end
      end
    end
  end
end
