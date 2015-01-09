require 'pact/consumer/mock_service/web_request_administration'
require 'pact/mock_service/interaction_decorator'
require 'pact/shared/json_differ'

module Pact
  module Consumer
    class InteractionPost < WebRequestAdministration

      def initialize name, logger, expected_interactions, verified_interactions
        super name, logger
        @expected_interactions = expected_interactions
        @verified_interactions = verified_interactions
      end

      def request_path
        '/interactions'
      end

      def request_method
        'POST'
      end

      def respond env
        request_body = env['rack.input'].string
        interaction = Interaction.from_hash(JSON.load(request_body)) # Load creates the Pact::XXX classes

        if (previous_interaction = interaction_already_verified_with_same_description_and_provider_state_but_not_equal(interaction))
          handle_almost_duplicate_interaction previous_interaction, interaction
        else
          add_expected_interaction request_body, interaction
        end
      end

      private

      attr_accessor :expected_interactions, :verified_interactions

      def add_expected_interaction request_body, interaction
        expected_interactions << interaction
        logger.info "Registered expected interaction #{interaction.request.method_and_path}"
        logger.debug JSON.pretty_generate JSON.parse(request_body)
        [200, {}, ['Added interaction']]
      end

      def handle_almost_duplicate_interaction previous_interaction, interaction
        message = InteractionDiffMessage.new(previous_interaction, interaction).to_s
        logger.error message
        [500, {}, [message]]
      end

      def interaction_already_verified_with_same_description_and_provider_state_but_not_equal interaction
        other = verified_interactions.find_matching_description_and_provider_state interaction
        other && other != interaction ? other : nil
      end

      class InteractionDiffMessage

        def initialize previous_interaction, new_interaction
          @previous_interaction = previous_interaction
          @new_interaction = new_interaction
        end

        def to_s
          "An interaction with same description (#{new_interaction.description.inspect}) and provider state (#{new_interaction.provider_state.inspect}) but a different #{differences} has already been used. Please use a different description or provider state."
        end

        private

        attr_reader :previous_interaction, :new_interaction

        def differences
          diff = Pact::JsonDiffer.call(previous_interaction_hash, new_interaction_hash, allow_unexpected_keys: false)
          diff.keys.collect do | parent_key |
            diff[parent_key].keys.collect do | child_key |
              "#{parent_key} #{child_key}"
            end
          end.flatten.join(", ").reverse.sub(",", "dna ").reverse
        end

        def previous_interaction_hash
          raw_hash previous_interaction
        end

        def new_interaction_hash
          raw_hash new_interaction
        end

        def raw_hash interaction
          JSON.parse(Pact::MockService::InteractionDecorator.new(interaction).to_json)
        end

      end
    end
  end
end
